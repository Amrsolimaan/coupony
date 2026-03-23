import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/storage_keys.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  AuthInterceptor(this.secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.read(key: StorageKeys.authToken);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Clear all stored credentials — forces re-login
      // GoRouter's redirect guard will detect the missing token
      // and redirect to /login on the next navigation event
      await secureStorage.delete(key: StorageKeys.authToken);
      await secureStorage.delete(key: StorageKeys.refreshToken);
      await secureStorage.delete(key: StorageKeys.userId);
      await secureStorage.delete(key: StorageKeys.userRole);
    }
    return handler.next(err);
  }
}
