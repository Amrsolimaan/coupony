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

  /// Persist whether the user is browsing as a guest.
  /// Stored in SharedPreferences (non-sensitive plain flag).
  Future<void> cacheGuestStatus(bool isGuest);

  /// Returns [true] if the user has explicitly entered as a guest.
  Future<bool> getGuestStatus();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;
  final SharedPreferences sharedPrefs;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPrefs,
  });

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      if (user.accessToken != null) {
        await secureStorage.write(StorageKeys.authToken, user.accessToken!);
      }
      if (user.refreshToken != null) {
        await secureStorage.write(StorageKeys.refreshToken, user.refreshToken!);
      }
      if (user.fcmToken != null) {
        await secureStorage.write(StorageKeys.fcmToken, user.fcmToken!);
      }
      await secureStorage.write(StorageKeys.userId, user.id.toString());
      await secureStorage.write(StorageKeys.userRole, user.role);
    } catch (e) {
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
  Future<void> cacheGuestStatus(bool isGuest) async {
    await sharedPrefs.setBool(StorageKeys.isGuest, isGuest);
  }

  @override
  Future<bool> getGuestStatus() async {
    return sharedPrefs.getBool(StorageKeys.isGuest) ?? false;
  }
}
