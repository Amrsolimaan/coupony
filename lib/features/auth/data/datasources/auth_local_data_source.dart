import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  Future<String?> getToken();
  Future<String?> getRefreshToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      if (user.token != null) {
        await secureStorage.write(StorageKeys.authToken, user.token!);
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
      final token  = await secureStorage.read(StorageKeys.authToken);
      final userId = await secureStorage.read(StorageKeys.userId);
      final role   = await secureStorage.read(StorageKeys.userRole);

      if (token == null || userId == null) return null;

      return UserModel(
        id:           int.tryParse(userId) ?? 0,
        name:         '',
        email:        '',
        phone:        '',
        role:         role ?? 'user',
        token:        token,
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
  Future<String?> getToken() => secureStorage.read(StorageKeys.authToken);

  @override
  Future<String?> getRefreshToken() =>
      secureStorage.read(StorageKeys.refreshToken);
}
