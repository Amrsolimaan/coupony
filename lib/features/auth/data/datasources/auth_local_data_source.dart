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

  /// Cache user roles array (e.g., ['seller', 'customer'] or ['seller_pending', 'customer'])
  Future<void> cacheUserRoles(List<String> roles);

  /// Returns the cached user roles array. Returns [] when none are cached.
  Future<List<String>> getCachedUserRoles();

  /// Get primary role from roles array for UI/theme purposes.
  /// Returns 'seller' if user has seller or seller_pending role.
  /// Returns 'customer' otherwise.
  Future<String> getPrimaryRole();

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

      // ── userId ────────────────────────────────────────────────────────────
      // Only write if we have a meaningful value. An empty email AND id==0
      // (common from profile-only API responses) must NOT overwrite the login-
      // time userId, which would corrupt every user-scoped SharedPrefs key.
      final String? scopedId = user.email.isNotEmpty
          ? user.email
          : (user.id > 0 ? user.id.toString() : null);
      if (scopedId != null) {
        await secureStorage.write(StorageKeys.userId, scopedId);
      }

      // ── roles & active-seller flag ────────────────────────────────────────
      // CRITICAL GUARDS:
      //   1. Profile endpoints (GET /auth/me) return NO roles array — skip the
      //      write entirely so the login-time cache is never wiped.
      //   2. seller_pending users are NOT active sellers; cache them as
      //      'customer' so the theme, splash color, and routing are all correct.
      //   3. ✅ RESPECT USER PREFERENCE: Check preferredRole from SharedPreferences
      //      first. Only default to 'seller' if user has no saved preference.
      if (user.roles.isNotEmpty) {
        // Check if user has a saved preference
        final preferredRole = sharedPrefs.getString(StorageKeys.preferredRole);
        
        // isActiveSeller is a computed getter on UserModel (requires all 3 checks)
        final bool activeSeller = user.isActiveSeller;
        
        String effectiveRole;
        
        if (preferredRole != null && (preferredRole == 'customer' || preferredRole == 'seller')) {
          // User has a saved preference - validate it against backend roles
          if (preferredRole == 'seller' && activeSeller) {
            effectiveRole = 'seller';
          } else if (preferredRole == 'customer' && user.roles.contains('customer')) {
            effectiveRole = 'customer';
          } else {
            // Preference is invalid, fall back to backend default
            effectiveRole = activeSeller ? 'seller' : 'customer';
          }
          print('✅ Using user preference: $preferredRole → effective: $effectiveRole');
        } else {
          // No preference saved, use backend default (seller priority)
          effectiveRole = activeSeller ? 'seller' : 'customer';
          print('ℹ️ No user preference, using backend default: $effectiveRole');
        }

        await secureStorage.write(StorageKeys.userRole, effectiveRole);
        print(
          '💾 Saved effective role: $effectiveRole '
          '(isActiveSeller: $activeSeller, '
          'isStoreOwner: ${user.isStoreOwner}, '
          'roles: ${user.roles})',
        );
        await cacheUserRoles(user.roles);
      } else {
        print('⚠️ cacheUser — roles list empty, preserving cached roles from login');
      }

      // Sync flags from the backend source of truth
      await cacheOnboardingCompleted(user.isOnboardingCompleted);
      await cacheStoreCreated(user.isStoreCreated);
      if (user.stores.isNotEmpty) {
        await cacheStores(user.stores);
      }

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
        role:        role ?? 'customer',
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
    try {
      final userId = await _requireUserId();
      return sharedPrefs.getBool(
            _getUserKey(StorageKeys.onboardingCompletedKey, userId),
          ) ??
          false;
    } catch (e) {
      print('⚠️ getOnboardingCompleted failed (userId missing): $e');
      return false; // Safe default: treat as not completed
    }
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
    try {
      final userId = await _requireUserId();
      return sharedPrefs.getBool(
            _getUserKey(StorageKeys.storeCreatedKey, userId),
          ) ??
          false;
    } catch (e) {
      print('⚠️ getStoreCreated failed (userId missing): $e');
      return false; // Safe default: treat as not created
    }
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
    } catch (e) {
      print('⚠️ getCachedStores failed (userId missing or decode error): $e');
      return []; // Safe default: empty stores list
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

  // ── User roles support ───────────────────────────────────────────────────

  @override
  Future<void> cacheUserRoles(List<String> roles) async {
    final userId = await _requireUserId();
    final key    = _getUserKey(StorageKeys.userRolesKey, userId);
    await sharedPrefs.setString(key, roles.join(','));
    print('💾 cacheUserRoles — stored ${roles.length} role(s): $roles');
  }

  @override
  Future<List<String>> getCachedUserRoles() async {
    try {
      final userId = await _requireUserId();
      final rolesString = sharedPrefs.getString(
        _getUserKey(StorageKeys.userRolesKey, userId),
      );
      if (rolesString == null || rolesString.isEmpty) return [];
      return rolesString.split(',').where((r) => r.isNotEmpty).toList();
    } catch (e) {
      print('⚠️ getCachedUserRoles failed (userId missing): $e');
      return []; // Safe default: empty roles list
    }
  }

  // ── getPrimaryRole ───────────────────────────────────────────────────────

  /// Returns the user's effective UI role: 'seller' or 'customer'.
  ///
  /// Single source of truth: [StorageKeys.userRole] written by [cacheUser].
  /// That write is strict — it is set to 'seller' ONLY when the backend
  /// confirms [isStoreOwner] = true AND the roles list contains 'seller'
  /// WITHOUT 'seller_pending'.
  ///
  /// 'seller_pending' users are therefore always returned as 'customer' here,
  /// preventing them from receiving the seller theme or entering the seller flow.
  @override
  Future<String> getPrimaryRole() async {
    try {
      final savedRole = await secureStorage.read(StorageKeys.userRole);
      return (savedRole == 'seller') ? 'seller' : 'customer';
    } catch (e) {
      print('⚠️ getPrimaryRole failed, defaulting to customer: $e');
      return 'customer';
    }
  }

  // ── clearSessionFlags ────────────────────────────────────────────────────

  @override
  Future<void> clearSessionFlags() async {
    try {
      final userId = await secureStorage.read(StorageKeys.userId);

      await sharedPrefs.remove(StorageKeys.isGuest);

      if (userId != null) {
        await sharedPrefs.remove(_getUserKey(StorageKeys.onboardingCompletedKey, userId));
        await sharedPrefs.remove(_getUserKey(StorageKeys.storeCreatedKey, userId));
        await sharedPrefs.remove(_getUserKey(StorageKeys.cachedStoresKey, userId));
        await sharedPrefs.remove(_getUserKey(StorageKeys.userRolesKey, userId));
        print('✅ Cleared user-scoped flags for userId: $userId');
      } else {
        print('⚠️ clearSessionFlags: userId is null, skipping user-scoped cleanup');
      }

      // Remove legacy flat keys from pre-refactor builds.
      await sharedPrefs.remove(StorageKeys.onboardingCompletedKey);
      await sharedPrefs.remove(StorageKeys.storeCreatedKey);
      
      print('✅ clearSessionFlags completed successfully');
    } catch (e) {
      // ✅ CRITICAL: Log but don't throw - allow clearUser() to proceed
      // If we throw here, clearUser() won't run and userId won't be deleted,
      // which could cause data leakage between users
      print('⚠️ clearSessionFlags failed but continuing: $e');
    }
  }
}
