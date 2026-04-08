import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';
import '../models/user_store_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  /// Returns the currently authenticated user's ID from secure storage.
  /// Used by other data sources to scope their cache keys.
  Future<String?> getUserId();

  /// Persist whether the user is browsing as a guest.
  Future<void> cacheGuestStatus(bool isGuest);
  Future<bool> getGuestStatus();

  /// Persist the onboarding-completed flag from the backend.
  Future<void> cacheOnboardingCompleted(bool completed);
  Future<bool> getOnboardingCompleted();

  /// Persist whether the seller has created their store (legacy bool flag).
  Future<void> cacheStoreCreated(bool created);
  Future<bool> getStoreCreated();

  // ── Multi-store support ──────────────────────────────────────────────────

  /// Cache the full stores list returned by the login / OTP API response.
  /// Stored as a JSON string under a user-scoped SharedPreferences key.
  Future<void> cacheStores(List<UserStoreModel> stores);

  /// Returns the cached stores list. Returns [] when none are cached.
  Future<List<UserStoreModel>> getCachedStores();

  /// Persist the selected store ID to SecureStorage so the merchant
  /// dashboard can scope its API calls to the correct store on resume.
  Future<void> saveSelectedStoreId(String id);

  /// Returns the seller's currently selected store ID, or null if not set.
  Future<String?> getSelectedStoreId();

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

  String _getUserKey(String baseKey, String userId) => '${userId}_$baseKey';

  Future<String> _requireUserId() async {
    final id = await secureStorage.read(StorageKeys.userId);
    if (id == null) {
      throw const CacheException(
        'No authenticated user found — cannot resolve user-scoped cache key.',
      );
    }
    return id;
  }

  // ── cacheUser ────────────────────────────────────────────────────────────

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      print('💾 AuthLocalDataSource.cacheUser — email: ${user.email} role: ${user.role} stores: ${user.stores.length}');

      if (user.accessToken  != null) await secureStorage.write(StorageKeys.authToken,    user.accessToken!);
      if (user.refreshToken != null) await secureStorage.write(StorageKeys.refreshToken, user.refreshToken!);
      if (user.fcmToken     != null) await secureStorage.write(StorageKeys.fcmToken,     user.fcmToken!);

      final scopedId = user.email.isNotEmpty ? user.email : user.id.toString();
      await secureStorage.write(StorageKeys.userId,   scopedId);
      
      // 🎯 PRESERVE USER'S TOGGLE SELECTION
      // Only write backend role if user hasn't selected a role via toggle yet
      // This ensures the UI/theme respects the user's explicit choice
      final currentToggleRole = await secureStorage.read(StorageKeys.userRole);
      if (currentToggleRole == null || currentToggleRole.isEmpty) {
        // First time (e.g., after OTP verification) - use backend role
        await secureStorage.write(StorageKeys.userRole, user.role);
        print('💾 First login - using backend role: ${user.role}');
      } else {
        // User already selected a role via toggle - preserve it
        print('✅ Preserving user toggle selection: $currentToggleRole (backend sent: ${user.role})');
      }

      // Sync flags from the backend source of truth
      await cacheOnboardingCompleted(user.isOnboardingCompleted);
      await cacheStoreCreated(user.isStoreCreated);
      await cacheStores(user.stores);

      print('✅ AuthLocalDataSource.cacheUser — all data cached');
    } catch (e) {
      print('❌ AuthLocalDataSource.cacheUser — $e');
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  // ── getCachedUser ────────────────────────────────────────────────────────

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final accessToken = await secureStorage.read(StorageKeys.authToken);
      final userId      = await secureStorage.read(StorageKeys.userId);
      final role        = await secureStorage.read(StorageKeys.userRole);

      if (accessToken == null || userId == null) return null;

      return UserModel(
        id:          int.tryParse(userId) ?? 0,
        firstName:   '',
        lastName:    '',
        email:       '',
        phoneNumber: '',
        role:        role ?? 'user',
        accessToken: accessToken,
        refreshToken: await secureStorage.read(StorageKeys.refreshToken),
        fcmToken:    await secureStorage.read(StorageKeys.fcmToken),
      );
    } catch (_) {
      return null;
    }
  }

  // ── clearUser ────────────────────────────────────────────────────────────

  @override
  Future<void> clearUser() async {
    await secureStorage.delete(StorageKeys.authToken);
    await secureStorage.delete(StorageKeys.refreshToken);
    await secureStorage.delete(StorageKeys.userId);
    await secureStorage.delete(StorageKeys.userRole);
    await secureStorage.delete(StorageKeys.fcmToken);
    await secureStorage.delete(StorageKeys.selectedStoreId);
  }

  // ── Token getters ────────────────────────────────────────────────────────

  @override
  Future<String?> getAccessToken() => secureStorage.read(StorageKeys.authToken);

  @override
  Future<String?> getRefreshToken() => secureStorage.read(StorageKeys.refreshToken);

  @override
  Future<String?> getUserId() => secureStorage.read(StorageKeys.userId);

  // ── Guest flag ───────────────────────────────────────────────────────────

  @override
  Future<void> cacheGuestStatus(bool isGuest) async =>
      sharedPrefs.setBool(StorageKeys.isGuest, isGuest);

  @override
  Future<bool> getGuestStatus() async =>
      sharedPrefs.getBool(StorageKeys.isGuest) ?? false;

  // ── Per-user session flags ───────────────────────────────────────────────

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

  // ── Multi-store support ──────────────────────────────────────────────────

  @override
  Future<void> cacheStores(List<UserStoreModel> stores) async {
    final userId = await _requireUserId();
    final key    = _getUserKey(StorageKeys.cachedStoresKey, userId);
    await sharedPrefs.setString(key, UserStoreModel.encodeList(stores));
    print('💾 cacheStores — stored ${stores.length} store(s) under key "$key"');
  }

  @override
  Future<List<UserStoreModel>> getCachedStores() async {
    try {
      final userId = await _requireUserId();
      final json   = sharedPrefs.getString(
        _getUserKey(StorageKeys.cachedStoresKey, userId),
      );
      if (json == null) return [];
      return UserStoreModel.decodeList(json);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveSelectedStoreId(String id) async {
    await secureStorage.write(StorageKeys.selectedStoreId, id);
    print('💾 saveSelectedStoreId — $id');
  }

  @override
  Future<String?> getSelectedStoreId() =>
      secureStorage.read(StorageKeys.selectedStoreId);

  // ── clearSessionFlags ────────────────────────────────────────────────────

  @override
  Future<void> clearSessionFlags() async {
    final userId = await secureStorage.read(StorageKeys.userId);

    await sharedPrefs.remove(StorageKeys.isGuest);

    if (userId != null) {
      await sharedPrefs.remove(_getUserKey(StorageKeys.onboardingCompletedKey, userId));
      await sharedPrefs.remove(_getUserKey(StorageKeys.storeCreatedKey, userId));
      await sharedPrefs.remove(_getUserKey(StorageKeys.cachedStoresKey, userId));
    }

    // Remove legacy flat keys from pre-refactor builds.
    await sharedPrefs.remove(StorageKeys.onboardingCompletedKey);
    await sharedPrefs.remove(StorageKeys.storeCreatedKey);
  }
}
