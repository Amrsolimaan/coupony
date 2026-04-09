import 'dart:io';
import 'dart:convert';
import 'package:coupony/core/errors/failures.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/data/models/user_preferences_model.dart';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:dartz/dartz.dart';
import '../constants/app_constants.dart';
import '../constants/storage_keys.dart';

/// Production-grade local cache service with:
/// - Single-time box opening (kept in memory)
/// - Media files stored in file system (only paths in Hive)
/// - Automatic cleanup (TTL + Quota management)
/// - Offline-first strategy support
/// - Interest tracking with decay mechanism
class LocalCacheService {
  // Singleton pattern
  static final LocalCacheService _instance = LocalCacheService._internal();
  factory LocalCacheService() => _instance;
  LocalCacheService._internal();

  final Logger _logger = Logger();

  // ✅ CRITICAL: Boxes opened once and kept in memory (no re-opening)
  final Map<String, Box> _openBoxes = {};

  // Media storage directory
  late Directory _mediaDirectory;
  late Directory _cacheDirectory;

  bool _isInitialized = false;

  // ═══════════════════════════════════════════════════════════
  // INTEREST TRACKING CONSTANTS
  // ═══════════════════════════════════════════════════════════
  static const int initialCategoryScore = 50;
  static const int productClickScore = 1;
  static const int viewDetailsScore = 5;
  static const int addToFavoritesScore = 15;
  static const int conversionScore = 20;
  static const double decayFactor = 0.95;

  /// Initialize Hive and create media directories
  /// MUST be called in main() before runApp()
  Future<void> init() async {
    if (_isInitialized) {
      _logger.w('LocalCacheService already initialized');
      return;
    }

    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Get application directories
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory('${appDir.path}/cache');
      _mediaDirectory = Directory('${appDir.path}/media');

      // Create directories if they don't exist
      if (!await _cacheDirectory.exists()) {
        await _cacheDirectory.create(recursive: true);
      }
      if (!await _mediaDirectory.exists()) {
        await _mediaDirectory.create(recursive: true);
      }

      _isInitialized = true;
      _logger.i('✅ LocalCacheService initialized successfully');

      // Run initial cleanup on app start
      await _performAutomaticCleanup();

      // Apply decay on app start if needed
      await applyInterestDecay();
    } catch (e) {
      _logger.e('❌ LocalCacheService initialization failed: $e');
      rethrow;
    }
  }

  /// Register Hive adapters for custom models
  /// Call this after init() in main.dart
  void registerAdapters() {
    // Example: Hive.registerAdapter(UserModelAdapter());
    // Will be implemented when we create models
  }

  /// Get or open a box (opens once, reuses from memory).
  ///
  /// **Type-collision guard**: Each box must always be opened with the same
  /// type parameter [T]. Calling `_getBox<String>('foo')` after a prior
  /// `_getBox<int>('foo')` in the same session is a programming error — the
  /// assert below catches it in debug mode. In production the cast on the
  /// return line will throw a [TypeError] rather than silently corrupting data.
  Future<Box<T>> _getBox<T>(String boxName) async {
    if (_openBoxes.containsKey(boxName)) {
      assert(
        _openBoxes[boxName] is Box<T>,
        '_getBox<$T>("$boxName") conflicts with an already-open '
        'Box<${_openBoxes[boxName].runtimeType}>. '
        'Each box must use a single, consistent type parameter.',
      );
      return _openBoxes[boxName] as Box<T>;
    }

    final box = await Hive.openBox<T>(boxName);
    _openBoxes[boxName] = box;
    _logger.d('📦 Opened box: $boxName');
    return box;
  }

  // ═══════════════════════════════════════════════════════════
  // INTEREST TRACKING SYSTEM
  // ═══════════════════════════════════════════════════════════

  /// Initialize category scores from onboarding selections
  /// Called after onboarding completion
  Future<Either<Failure, Unit>> initializeCategoryScores(
    List<String> selectedCategories,
  ) async {
    try {
      final box = await _getBox<UserPreferencesModel>(
        StorageKeys.onboardingPreferencesBox,
      );

      final preferences =
          box.get(StorageKeys.onboardingPreferencesKey) ??
          UserPreferencesModel.empty();

      // Create initial scores map with +50 for each selected category
      final initialScores = <String, int>{};
      for (final categoryId in selectedCategories) {
        initialScores[categoryId] = initialCategoryScore;
      }

      final updatedPreferences = preferences.copyWith(
        categoryScores: initialScores,
        lastDecayDate: DateTime.now(),
      );

      await box.put(StorageKeys.onboardingPreferencesKey, updatedPreferences);

      _logger.i('✅ Initialized category scores: $initialScores');
      return right(unit);
    } catch (e) {
      _logger.e('❌ Error initializing category scores: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  /// Update category score (non-blocking, thread-safe)
  /// Called when user interacts with products
  Future<Either<Failure, Unit>> updateCategoryScore({
    required String categoryId,
    required int points,
  }) async {
    try {
      final box = await _getBox<UserPreferencesModel>(
        StorageKeys.onboardingPreferencesBox,
      );

      final preferences = box.get(StorageKeys.onboardingPreferencesKey);

      if (preferences == null) {
        return left(CacheFailure('Preferences not found'));
      }

      // Create mutable copy of scores
      final updatedScores = Map<String, int>.from(preferences.categoryScores);

      // Update score
      updatedScores[categoryId] = (updatedScores[categoryId] ?? 0) + points;

      // Save updated preferences
      final updatedPreferences = preferences.copyWith(
        categoryScores: updatedScores,
      );

      await box.put(StorageKeys.onboardingPreferencesKey, updatedPreferences);

      _logger.d('✅ Updated score for $categoryId: +$points');
      return right(unit);
    } catch (e) {
      _logger.e('❌ Error updating category score: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  /// Apply decay factor to all category scores (0.95x)
  /// Called daily or on app start
  Future<Either<Failure, Unit>> applyInterestDecay() async {
    try {
      final box = await _getBox<UserPreferencesModel>(
        StorageKeys.onboardingPreferencesBox,
      );

      final preferences = box.get(StorageKeys.onboardingPreferencesKey);

      if (preferences == null || preferences.categoryScores.isEmpty) {
        return right(unit); // No scores to decay
      }

      // Check if decay should be applied
      if (!preferences.shouldApplyDecay()) {
        _logger.d('⏭️ Decay not needed yet');
        return right(unit);
      }

      // Apply decay factor
      final decayedScores = <String, int>{};
      for (final entry in preferences.categoryScores.entries) {
        final decayedValue = (entry.value * decayFactor).round();
        // Keep minimum score of 1 to prevent categories from disappearing
        decayedScores[entry.key] = decayedValue > 0 ? decayedValue : 1;
      }

      // Save updated preferences
      final updatedPreferences = preferences.copyWith(
        categoryScores: decayedScores,
        lastDecayDate: DateTime.now(),
      );

      await box.put(StorageKeys.onboardingPreferencesKey, updatedPreferences);

      _logger.i(
        '✅ Applied interest decay to ${decayedScores.length} categories',
      );
      return right(unit);
    } catch (e) {
      _logger.e('❌ Error applying interest decay: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  /// Get top 3 interests for API requests
  Future<Either<Failure, List<String>>> getTopThreeInterests() async {
    try {
      final box = await _getBox<UserPreferencesModel>(
        StorageKeys.onboardingPreferencesBox,
      );

      final preferences = box.get(StorageKeys.onboardingPreferencesKey);

      if (preferences == null) {
        return left(CacheFailure('Preferences not found'));
      }

      final topInterests = preferences.getTopThreeInterests();
      _logger.d('📊 Top 3 interests: $topInterests');
      return right(topInterests);
    } catch (e) {
      _logger.e('❌ Error getting top interests: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  /// Track seen product (for infinite novelty feed)
  Future<Either<Failure, Unit>> trackSeenProduct(String productId) async {
    try {
      final box = await _getBox<UserPreferencesModel>(
        StorageKeys.onboardingPreferencesBox,
      );

      final preferences = box.get(StorageKeys.onboardingPreferencesKey);

      if (preferences == null) {
        return left(CacheFailure('Preferences not found'));
      }

      // Add product to seen list if not already present
      if (!preferences.seenProductIds.contains(productId)) {
        final updatedSeenProducts = List<String>.from(
          preferences.seenProductIds,
        )..add(productId);

        final updatedPreferences = preferences.copyWith(
          seenProductIds: updatedSeenProducts,
        );

        await box.put(StorageKeys.onboardingPreferencesKey, updatedPreferences);

        _logger.d('✅ Tracked seen product: $productId');
      }

      return right(unit);
    } catch (e) {
      _logger.e('❌ Error tracking seen product: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  /// Get list of seen product IDs for API filtering
  Future<Either<Failure, List<String>>> getSeenProductIds() async {
    try {
      final box = await _getBox<UserPreferencesModel>(
        StorageKeys.onboardingPreferencesBox,
      );

      final preferences = box.get(StorageKeys.onboardingPreferencesKey);

      if (preferences == null) {
        return right([]);
      }

      return right(preferences.seenProductIds);
    } catch (e) {
      _logger.e('❌ Error getting seen product IDs: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  /// Clear seen products list (reset novelty feed)
  Future<Either<Failure, Unit>> clearSeenProducts() async {
    try {
      final box = await _getBox<UserPreferencesModel>(
        StorageKeys.onboardingPreferencesBox,
      );

      final preferences = box.get(StorageKeys.onboardingPreferencesKey);

      if (preferences == null) {
        return left(CacheFailure('Preferences not found'));
      }

      final updatedPreferences = preferences.copyWith(seenProductIds: []);

      await box.put(StorageKeys.onboardingPreferencesKey, updatedPreferences);

      _logger.i('✅ Cleared seen products list');
      return right(unit);
    } catch (e) {
      _logger.e('❌ Error clearing seen products: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BASIC CACHE OPERATIONS (TEXT/JSON DATA)
  // ═══════════════════════════════════════════════════════════

  /// Generic get with automatic TTL validation and type safety
  Future<T?> get<T>({
    required String boxName,
    required String key,
    Duration? maxAge,
  }) async {
    try {
      final box = await _getBox<T>(boxName);

      // Check if key exists
      if (!box.containsKey(key)) {
        return null;
      }

      // Validate TTL if maxAge is provided
      if (maxAge != null) {
        final isValid = await _isCacheValid(boxName, key, maxAge);
        if (!isValid) {
          _logger.d('🗑️ Cache expired for key: $key');
          await delete(boxName: boxName, key: key);
          return null;
        }
      }

      final value = box.get(key);

      // ✅ PHASE 1 FIX: Type safety validation
      if (value != null) {
        // Check if the value is of the expected type T
        try {
          final typedValue = value as T;
          return typedValue;
        } catch (e) {
          _logger.w(
            '⚠️ Type mismatch for key $key: expected $T, got ${value.runtimeType}',
          );
          // Clean up the invalid entry
          await delete(boxName: boxName, key: key);
          return null;
        }
      }

      return value;
    } catch (e) {
      _logger.e('❌ Error getting cache for key $key: $e');
      return null;
    }
  }

  /// Generic put with automatic timestamp
  /// [skipTimestamp] - Skip timestamp storage (useful for typed boxes like PermissionStatusModel)
  Future<void> put<T>({
    required String boxName,
    required String key,
    required T value,
    bool skipTimestamp = false,
  }) async {
    try {
      final box = await _getBox<T>(boxName);
      await box.put(key, value);

      // Store timestamp for TTL validation (only if not skipped)
      if (!skipTimestamp) {
        await _setCacheTimestamp(boxName, key);
      }

      _logger.d('💾 Cached data for key: $key');
    } catch (e) {
      _logger.e('❌ Error caching data for key $key: $e');
      rethrow;
    }
  }

  /// Delete specific key with timestamp cleanup
  Future<void> delete({required String boxName, required String key}) async {
    try {
      final box = await _getBox(boxName);
      await box.delete(key);

      // Also delete timestamp from separate timestamp box
      try {
        final timestampBox = await _getBox<String>('${boxName}_timestamps');
        final timestampKey = '${key}_timestamp';
        await timestampBox.delete(timestampKey);
      } catch (e) {
        // Timestamp deletion is not critical, just log
        _logger.d('Note: Could not delete timestamp for $key: $e');
      }

      _logger.d('🗑️ Deleted cache for key: $key');
    } catch (e) {
      _logger.e('❌ Error deleting cache for key $key: $e');
    }
  }

  /// Clear entire box
  Future<void> clearBox(String boxName) async {
    try {
      final box = await _getBox(boxName);
      await box.clear();
      _logger.i('🗑️ Cleared entire box: $boxName');
    } catch (e) {
      _logger.e('❌ Error clearing box $boxName: $e');
    }
  }

  /// Get all values from box
  Future<List<T>> getAll<T>(String boxName) async {
    try {
      final box = await _getBox<T>(boxName);
      return box.values.toList();
    } catch (e) {
      _logger.e('❌ Error getting all values from $boxName: $e');
      return [];
    }
  }

  /// Check if key exists
  Future<bool> containsKey({
    required String boxName,
    required String key,
  }) async {
    try {
      final box = await _getBox(boxName);
      return box.containsKey(key);
    } catch (e) {
      _logger.e('❌ Error checking key existence: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // MEDIA FILE MANAGEMENT (Images/Videos)
  // ═══════════════════════════════════════════════════════════

  /// Save media file to file system and store path in Hive
  /// Returns the file path if successful
  Future<String?> saveMediaFile({
    required String url,
    required List<int> bytes,
    required MediaType type,
  }) async {
    try {
      // Generate unique filename from URL hash (using MD5 for uniqueness)
      final fileName = _generateFileNameFromUrl(url);
      final extension = _getExtensionFromUrl(url);

      // Determine subfolder based on media type
      final subfolder = type == MediaType.image ? 'images' : 'videos';
      final mediaSubDir = Directory('${_mediaDirectory.path}/$subfolder');

      if (!await mediaSubDir.exists()) {
        await mediaSubDir.create(recursive: true);
      }

      // Save file to file system
      final filePath = '${mediaSubDir.path}/$fileName$extension';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Store metadata in Hive (NOT the file itself)
      await _storeMediaMetadata(
        url: url,
        path: filePath,
        type: type,
        size: bytes.length,
      );

      _logger.i('💾 Saved media file: $fileName ($type)');
      return filePath;
    } catch (e) {
      _logger.e('❌ Error saving media file: $e');
      return null;
    }
  }

  /// Get media file path from cache
  /// Returns null if not cached or expired
  Future<String?> getMediaFilePath({
    required String url,
    Duration maxAge = AppConstants.mediaCacheDuration,
  }) async {
    try {
      final box = await _getBox<Map>(StorageKeys.mediaMetadataBox);
      final metadata = box.get(url);

      if (metadata == null) return null;

      // Check TTL
      final timestamp = DateTime.tryParse(metadata['timestamp'] as String);
      if (timestamp == null) return null;

      final age = DateTime.now().difference(timestamp);
      if (age > maxAge) {
        _logger.d('🗑️ Media cache expired for: $url');
        await deleteMediaFile(url);
        return null;
      }

      // Check if file still exists
      final filePath = metadata['path'] as String;
      final file = File(filePath);

      if (!await file.exists()) {
        _logger.w('⚠️ Media file missing: $filePath');
        await deleteMediaFile(url);
        return null;
      }

      return filePath;
    } catch (e) {
      _logger.e('❌ Error getting media file path: $e');
      return null;
    }
  }

  /// Delete media file from both file system and Hive
  Future<void> deleteMediaFile(String url) async {
    try {
      final box = await _getBox<Map>(StorageKeys.mediaMetadataBox);
      final metadata = box.get(url);

      if (metadata != null) {
        // Delete file from file system
        final filePath = metadata['path'] as String;
        final file = File(filePath);

        if (await file.exists()) {
          await file.delete();
        }

        // Delete metadata from Hive
        await box.delete(url);
        _logger.d('🗑️ Deleted media file: $url');
      }
    } catch (e) {
      _logger.e('❌ Error deleting media file: $e');
    }
  }

  /// Store media metadata in Hive
  Future<void> _storeMediaMetadata({
    required String url,
    required String path,
    required MediaType type,
    required int size,
  }) async {
    final box = await _getBox<Map>(StorageKeys.mediaMetadataBox);
    await box.put(url, {
      'url': url,
      'path': path,
      'type': type.toString(),
      'size': size,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ═══════════════════════════════════════════════════════════
  // TTL MANAGEMENT (Time-To-Live)
  // ═══════════════════════════════════════════════════════════

  /// Set timestamp for cache entry with type safety
  Future<void> _setCacheTimestamp(String boxName, String key) async {
    try {
      // Use a separate timestamp box to avoid type conflicts
      final timestampBox = await _getBox<String>('${boxName}_timestamps');
      final timestampKey = '${key}_timestamp';
      await timestampBox.put(timestampKey, DateTime.now().toIso8601String());
    } catch (e) {
      _logger.e('⛔ ❌ Error setting cache timestamp: $e');
    }
  }

  /// Check if cache is still valid based on TTL with type safety
  Future<bool> _isCacheValid(
    String boxName,
    String key,
    Duration maxAge,
  ) async {
    try {
      // Use the separate timestamp box
      final timestampBox = await _getBox<String>('${boxName}_timestamps');
      final timestampKey = '${key}_timestamp';
      final timestampStr = timestampBox.get(timestampKey);

      if (timestampStr == null) return false;

      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) return false;

      final age = DateTime.now().difference(timestamp);
      return age <= maxAge;
    } catch (e) {
      _logger.e('❌ Error checking cache validity: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // AUTOMATIC CLEANUP (Background Task)
  // ═══════════════════════════════════════════════════════════

  /// Perform automatic cleanup on app start
  /// Runs in background without blocking UI
  Future<void> _performAutomaticCleanup() async {
    try {
      final lastCleanupBox = await _getBox(StorageKeys.settingsBox);
      final lastCleanupStr = lastCleanupBox.get(StorageKeys.lastCleanupDate);

      // Check if cleanup is needed (once per day)
      if (lastCleanupStr != null) {
        final lastCleanup = DateTime.tryParse(lastCleanupStr as String);
        if (lastCleanup != null) {
          final hoursSinceCleanup = DateTime.now()
              .difference(lastCleanup)
              .inHours;
          if (hoursSinceCleanup < 24) {
            _logger.d('⏭️ Cleanup not needed yet');
            return;
          }
        }
      }

      _logger.i('🧹 Starting automatic cleanup...');

      // Run cleanup tasks
      await _cleanExpiredDataCaches();
      await _cleanExpiredMediaFiles();
      await _enforceMediaQuota();

      // Update last cleanup timestamp
      await lastCleanupBox.put(
        StorageKeys.lastCleanupDate,
        DateTime.now().toIso8601String(),
      );

      _logger.i('✅ Automatic cleanup completed');
    } catch (e) {
      _logger.e('❌ Error during automatic cleanup: $e');
    }
  }

  /// Clean expired data caches
  Future<void> _cleanExpiredDataCaches() async {
    try {
      // Clean coupons cache
      await _cleanBoxByTTL(
        boxName: StorageKeys.couponsBox,
        maxAge: AppConstants.couponsCacheDuration,
      );

      // Clean stores cache
      await _cleanBoxByTTL(
        boxName: StorageKeys.storesBox,
        maxAge: AppConstants.storesCacheDuration,
      );

      // Clean public product details + page-1 cache
      await _cleanBoxByTTL(
        boxName: StorageKeys.publicProductsBox,
        maxAge: AppConstants.productDetailCacheDuration,
      );

      // Clean categories cache
      await _cleanBoxByTTL(
        boxName: StorageKeys.categoriesBox,
        maxAge: AppConstants.categoriesCacheDuration,
      );
    } catch (e) {
      _logger.e('❌ Error cleaning expired data caches: $e');
    }
  }

  /// Clean expired items from a specific box
  Future<void> _cleanBoxByTTL({
    required String boxName,
    required Duration maxAge,
  }) async {
    try {
      final box = await _getBox(boxName);
      final keysToDelete = <String>[];

      for (final key in box.keys) {
        // Skip timestamp keys
        if (key.toString().endsWith('_timestamp')) continue;

        final isValid = await _isCacheValid(boxName, key.toString(), maxAge);
        if (!isValid) {
          keysToDelete.add(key.toString());
        }
      }

      // Delete expired keys
      for (final key in keysToDelete) {
        await delete(boxName: boxName, key: key);
      }

      if (keysToDelete.isNotEmpty) {
        _logger.i(
          '🗑️ Cleaned ${keysToDelete.length} expired items from $boxName',
        );
      }
    } catch (e) {
      _logger.e('❌ Error cleaning box $boxName: $e');
    }
  }

  /// Clean expired media files
  Future<void> _cleanExpiredMediaFiles() async {
    try {
      final box = await _getBox<Map>(StorageKeys.mediaMetadataBox);
      final urlsToDelete = <String>[];

      for (final key in box.keys) {
        final metadata = box.get(key);
        if (metadata == null) continue;

        final timestamp = DateTime.tryParse(metadata['timestamp'] as String);
        if (timestamp == null) {
          urlsToDelete.add(key.toString());
          continue;
        }

        final age = DateTime.now().difference(timestamp);
        if (age > AppConstants.mediaCacheDuration) {
          urlsToDelete.add(key.toString());
        }
      }

      // Delete expired media files
      for (final url in urlsToDelete) {
        await deleteMediaFile(url);
      }

      if (urlsToDelete.isNotEmpty) {
        _logger.i('🗑️ Cleaned ${urlsToDelete.length} expired media files');
      }
    } catch (e) {
      _logger.e('❌ Error cleaning expired media files: $e');
    }
  }

  /// Enforce media storage quota (delete oldest files if exceeded)
  Future<void> _enforceMediaQuota() async {
    try {
      final totalSize = await _calculateMediaDirectorySize();
      final maxSizeBytes = AppConstants.maxMediaCacheSizeMB * 1024 * 1024;

      if (totalSize <= maxSizeBytes) {
        _logger.d(
          '📊 Media cache size OK: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB',
        );
        return;
      }

      _logger.w(
        '⚠️ Media cache exceeded quota: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      // Get all media files sorted by timestamp (oldest first)
      final box = await _getBox<Map>(StorageKeys.mediaMetadataBox);
      final mediaList = <Map<String, dynamic>>[];

      for (final key in box.keys) {
        final metadata = box.get(key);
        if (metadata != null) {
          mediaList.add(Map<String, dynamic>.from(metadata));
        }
      }

      // Sort by timestamp (oldest first)
      mediaList.sort((a, b) {
        final timeA = DateTime.parse(a['timestamp'] as String);
        final timeB = DateTime.parse(b['timestamp'] as String);
        return timeA.compareTo(timeB);
      });

      // Delete oldest files until under quota
      int currentSize = totalSize;
      int deletedCount = 0;

      for (final metadata in mediaList) {
        if (currentSize <= maxSizeBytes) break;

        final url = metadata['url'] as String;
        final size = metadata['size'] as int;

        await deleteMediaFile(url);
        currentSize -= size;
        deletedCount++;
      }

      _logger.i('🗑️ Deleted $deletedCount old media files to enforce quota');
    } catch (e) {
      _logger.e('❌ Error enforcing media quota: $e');
    }
  }

  /// ✅ FIXED: Now uses Async Stream (list()) to prevent UI Lag
  Future<int> _calculateMediaDirectorySize() async {
    int totalSize = 0;

    try {
      // Using .list() instead of .listSync() for non-blocking execution
      await for (final entity in _mediaDirectory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      _logger.e('❌ Error calculating media directory size: $e');
    }

    return totalSize;
  }

  // ═══════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════

  /// ✅ FIXED: Using MD5 Hash to ensure uniqueness and prevent collision
  String _generateFileNameFromUrl(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }

  /// Extract file extension from URL
  String _getExtensionFromUrl(String url) {
    final uri = Uri.parse(url);
    final path = uri.path;
    final lastDot = path.lastIndexOf('.');

    if (lastDot == -1) return '.jpg'; // Default

    return path.substring(lastDot);
  }

  /// Manual cleanup trigger (can be called from settings)
  Future<void> performManualCleanup() async {
    _logger.i('🧹 Manual cleanup triggered by user');
    await _performAutomaticCleanup();
  }

  /// Get cache statistics for UI display
  Future<CacheStatistics> getCacheStatistics() async {
    try {
      final mediaSize = await _calculateMediaDirectorySize();
      final box = await _getBox<Map>(StorageKeys.mediaMetadataBox);
      final mediaCount = box.length;

      return CacheStatistics(
        mediaSizeMB: mediaSize / 1024 / 1024,
        mediaFileCount: mediaCount,
        maxQuotaMB: AppConstants.maxMediaCacheSizeMB.toDouble(),
      );
    } catch (e) {
      _logger.e('❌ Error getting cache statistics: $e');
      return CacheStatistics(
        mediaSizeMB: 0,
        mediaFileCount: 0,
        maxQuotaMB: AppConstants.maxMediaCacheSizeMB.toDouble(),
      );
    }
  }

  /// Clear ALL cache (nuclear option)
  Future<void> clearAllCache() async {
    _logger.w('🗑️ CLEARING ALL CACHE (user requested)');

    try {
      // Clear all Hive boxes
      for (final box in _openBoxes.values) {
        await box.clear();
      }

      // Delete all media files
      if (await _mediaDirectory.exists()) {
        await _mediaDirectory.delete(recursive: true);
        await _mediaDirectory.create(recursive: true);
      }

      _logger.i('✅ All cache cleared');
    } catch (e) {
      _logger.e('❌ Error clearing all cache: $e');
    }
  }

  /// Close all boxes (call on app termination)
  Future<void> dispose() async {
    for (final box in _openBoxes.values) {
      await box.close();
    }
    _openBoxes.clear();
    _logger.i('👋 LocalCacheService disposed');
  }
}

// ═══════════════════════════════════════════════════════════
// HELPER CLASSES
// ═══════════════════════════════════════════════════════════

enum MediaType { image, video }

class CacheStatistics {
  final double mediaSizeMB;
  final int mediaFileCount;
  final double maxQuotaMB;

  CacheStatistics({
    required this.mediaSizeMB,
    required this.mediaFileCount,
    required this.maxQuotaMB,
  });

  double get usagePercentage => (mediaSizeMB / maxQuotaMB) * 100;
  bool get isNearLimit => usagePercentage > 80;
}
