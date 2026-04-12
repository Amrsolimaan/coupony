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

      final scopedId = user.email.isNotEmpty ? user.email : user.id.toString();
      await secureStorage.write(StorageKeys.userId,   scopedId);
      
      // ✅ ALWAYS use backend role as source of truth
      // The backend determines the user's actual role based on their account status
      await secureStorage.write(StorageKeys.userRole, user.role);
      print('💾 Saved backend role: ${user.role}');

      // Sync flags from the backend source of truth
      await cacheOnboardingCompleted(user.isOnboardingCompleted);
      await cacheStoreCreated(user.isStoreCreated);
      await cacheStores(user.stores);
      await cacheUserRoles(user.roles);

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

  /// ✅ FIXED: Get primary role with user preference support
  /// 
  /// Logic:
  /// 1. Check if user has manually selected a role (via role_toggle)
  /// 2. If yes, validate it against backend roles and return it
  /// 3. If no, return backend's primary role (seller > customer)
  /// 
  /// This allows users with multiple roles to choose which one to use
  @override
  Future<String> getPrimaryRole() async {
    try {
      // Step 1: Get backend roles (source of truth for permissions)
      final backendRoles = await getCachedUserRoles();
      
      // Step 2: Get user's active role preference (from role_toggle)
      final userSelectedRole = await secureStorage.read(StorageKeys.userRole);
      
      // Step 3: If user has selected a role, validate it against backend roles
      if (userSelectedRole != null && userSelectedRole.isNotEmpty) {
        // Validate: user can only use roles they have from backend
        if (backendRoles.isEmpty) {
          // No backend roles cached yet, trust user selection
          return (userSelectedRole == 'seller') ? 'seller' : 'customer';
        }
        
        // Check if user's selection is valid
        if (userSelectedRole == 'seller') {
          // User wants seller role - check if they have it
          if (backendRoles.contains('seller') || backendRoles.contains('seller_pending')) {
            return 'seller';
          }
          // User doesn't have seller role, fallback to customer
          return 'customer';
        } else {
          // User wants customer role - always allowed if they have any role
          return 'customer';
        }
      }
      
      // Step 4: No user preference, use backend's primary role
      if (backendRoles.isEmpty) {
        // Fallback to single role storage for backward compatibility
        final savedRole = await secureStorage.read(StorageKeys.userRole);
        return (savedRole == 'seller') ? 'seller' : 'customer';
      }
      
      // Determine primary role from backend roles array
      if (backendRoles.contains('seller') || backendRoles.contains('seller_pending')) {
        return 'seller';
      }
      
      return 'customer';
    } catch (e) {
      print('⚠️ getPrimaryRole failed, defaulting to customer: $e');
      return 'customer'; // Safe default
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
