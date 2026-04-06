import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  /// Returns the currently authenticated user's ID from secure storage.
  /// Used by other data sources (e.g. onboarding) to scope their cache keys.
  Future<String?> getUserId();

  /// Persist whether the user is browsing as a guest.
  /// Stored in SharedPreferences (non-sensitive plain flag).
  Future<void> cacheGuestStatus(bool isGuest);

  /// Returns [true] if the user has explicitly entered as a guest.
  Future<bool> getGuestStatus();

  /// Persist the onboarding-completed flag received from the backend.
  /// Stored under a user-specific key to prevent leakage between accounts.
  /// Written after a successful POST /api/v1/on-boarding/{role} call.
  Future<void> cacheOnboardingCompleted(bool completed);

  /// Returns [true] if the backend has previously acknowledged this user's
  /// onboarding preferences (i.e., the flag was cached after a 200 OK).
  Future<bool> getOnboardingCompleted();

  /// Persist whether the seller has created their store.
  /// Stored under a user-specific key to prevent leakage between accounts.
  /// Written after a successful POST /api/v1/stores call.
  Future<void> cacheStoreCreated(bool created);

  /// Returns [true] if the seller has already submitted a store for review.
  Future<bool> getStoreCreated();

  /// Wipe ALL non-secure session flags from SharedPreferences.
  /// MUST be called BEFORE [clearUser] during logout so the userId is still
  /// available to resolve user-scoped keys.
  Future<void> clearSessionFlags();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;
  final SharedPreferences sharedPrefs;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPrefs,
  });

  // ── Key helpers ──────────────────────────────────────────────────────────

  /// Centralised user-scoped key builder. All per-user SharedPreferences
  /// flags MUST be stored under this key to prevent data leakage between
  /// different accounts on the same device.
  String _getUserKey(String baseKey, String userId) => '${userId}_$baseKey';

  /// Reads the current userId from SecureStorage.
  /// Throws [CacheException] when no authenticated user is present so callers
  /// fail loudly rather than silently writing to the wrong key.
  Future<String> _requireUserId() async {
    final id = await secureStorage.read(StorageKeys.userId);
    if (id == null) {
      throw const CacheException(
        'No authenticated user found — cannot resolve user-scoped cache key.',
      );
    }
    return id;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      print('💾 AuthLocalDataSource.cacheUser - Starting cache for user:');
      print('  - ID: ${user.id}');
      print('  - Email: ${user.email}');
      print('  - Role: ${user.role}');
      print('  - isOnboardingCompleted: ${user.isOnboardingCompleted}');
      print('  - Has Access Token: ${user.accessToken != null}');
      
      if (user.accessToken != null) {
        await secureStorage.write(StorageKeys.authToken, user.accessToken!);
        print('✅ Access token cached');
      }
      if (user.refreshToken != null) {
        await secureStorage.write(StorageKeys.refreshToken, user.refreshToken!);
        print('✅ Refresh token cached');
      }
      if (user.fcmToken != null) {
        await secureStorage.write(StorageKeys.fcmToken, user.fcmToken!);
        print('✅ FCM token cached');
      }
      // Use email as the stable unique scope key.
      // The backend returns UUIDs so user.id is always 0 in UserModel.fromJson.
      // Email is unique per account and prevents cache leakage between accounts
      // on the same device.
      final scopedId = user.email.isNotEmpty ? user.email : user.id.toString();
      await secureStorage.write(StorageKeys.userId, scopedId);
      await secureStorage.write(StorageKeys.userRole, user.role);

      // Sync onboarding and store-created flags from the backend response so
      // the Splash routing decision is always based on the server's source of truth,
      // not stale local state from a previous session.
      print('💾 Syncing onboarding status from backend: ${user.isOnboardingCompleted}');
      await cacheOnboardingCompleted(user.isOnboardingCompleted);
      print('💾 Syncing store-created status from backend: ${user.isStoreCreated}');
      await cacheStoreCreated(user.isStoreCreated);

      print('✅ AuthLocalDataSource.cacheUser - All data cached successfully');
    } catch (e) {
      print('❌ AuthLocalDataSource.cacheUser - Error: $e');
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final accessToken = await secureStorage.read(StorageKeys.authToken);
      final userId      = await secureStorage.read(StorageKeys.userId);
      final role        = await secureStorage.read(StorageKeys.userRole);

      if (accessToken == null || userId == null) return null;

      return UserModel(
        id:           int.tryParse(userId) ?? 0,
        firstName:    '',
        lastName:     '',
        email:        '',
        phoneNumber:  '',
        role:         role ?? 'user',
        accessToken:  accessToken,
        refreshToken: await secureStorage.read(StorageKeys.refreshToken),
        fcmToken:     await secureStorage.read(StorageKeys.fcmToken),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await secureStorage.delete(StorageKeys.authToken);
    await secureStorage.delete(StorageKeys.refreshToken);
    await secureStorage.delete(StorageKeys.userId);
    await secureStorage.delete(StorageKeys.userRole);
    await secureStorage.delete(StorageKeys.fcmToken);
  }

  @override
  Future<String?> getAccessToken() => secureStorage.read(StorageKeys.authToken);

  @override
  Future<String?> getRefreshToken() => secureStorage.read(StorageKeys.refreshToken);

  @override
  Future<String?> getUserId() => secureStorage.read(StorageKeys.userId);

  @override
  Future<void> cacheGuestStatus(bool isGuest) async {
    await sharedPrefs.setBool(StorageKeys.isGuest, isGuest);
  }

  @override
  Future<bool> getGuestStatus() async {
    return sharedPrefs.getBool(StorageKeys.isGuest) ?? false;
  }

  // ── Per-user session flags ───────────────────────────────────────────────
  // Each flag is stored under "${userId}_<baseKey>" so that a second user
  // logging in on the same device never inherits a previous user's state.

  @override
  Future<void> cacheOnboardingCompleted(bool completed) async {
    final userId = await _requireUserId();
    await sharedPrefs.setBool(
      _getUserKey(StorageKeys.onboardingCompletedKey, userId),
      completed,
    );
  }

  @override
  Future<bool> getOnboardingCompleted() async {
    final userId = await _requireUserId();
    return sharedPrefs.getBool(
          _getUserKey(StorageKeys.onboardingCompletedKey, userId),
        ) ??
        false;
  }

  @override
  Future<void> cacheStoreCreated(bool created) async {
    final userId = await _requireUserId();
    await sharedPrefs.setBool(
      _getUserKey(StorageKeys.storeCreatedKey, userId),
      created,
    );
  }

  @override
  Future<bool> getStoreCreated() async {
    final userId = await _requireUserId();
    return sharedPrefs.getBool(
          _getUserKey(StorageKeys.storeCreatedKey, userId),
        ) ??
        false;
  }

  /// Clears all session flags for the current user.
  ///
  /// IMPORTANT: This MUST be called BEFORE [clearUser] during logout because
  /// it needs the userId from SecureStorage to resolve user-scoped keys.
  /// Also removes any legacy flat keys left over from a previous app version.
  @override
  Future<void> clearSessionFlags() async {
    final userId = await secureStorage.read(StorageKeys.userId);

    await sharedPrefs.remove(StorageKeys.isGuest);

    if (userId != null) {
      await sharedPrefs.remove(
        _getUserKey(StorageKeys.onboardingCompletedKey, userId),
      );
      await sharedPrefs.remove(
        _getUserKey(StorageKeys.storeCreatedKey, userId),
      );
    }

    // Remove legacy flat keys so old data from pre-refactor builds is cleaned.
    await sharedPrefs.remove(StorageKeys.onboardingCompletedKey);
    await sharedPrefs.remove(StorageKeys.storeCreatedKey);
  }
}
