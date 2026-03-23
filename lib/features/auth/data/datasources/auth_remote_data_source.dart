import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String phone, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  });
  Future<void> sendOtp(String phone);
  Future<UserModel> verifyOtp({required String phone, required String otp});
  Future<UserModel> refreshToken(String refreshToken);
  Future<void> logout(String token);
  Future<void> updateFcmToken({
    required String token,
    required String fcmToken,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await client.post(
        ApiConstants.login,
        data: {'phone': phone, 'password': password},
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  }) async {
    try {
      final response = await client.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        },
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendOtp(String phone) async {
    try {
      await client.post(ApiConstants.sendOtp, data: {'phone': phone});
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await client.post(
        ApiConstants.verifyOtp,
        data: {'phone': phone, 'otp': otp},
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> refreshToken(String refreshToken) async {
    try {
      final response = await client.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await client.post(ApiConstants.logout);
    } catch (_) {
      // Best-effort — local state is always cleared regardless
    }
  }

  @override
  Future<void> updateFcmToken({
    required String token,
    required String fcmToken,
  }) async {
    try {
      await client.post(
        ApiConstants.updateFcmToken,
        data: {'fcm_token': fcmToken},
      );
    } catch (_) {
      // Non-critical — silent fail
    }
  }
}
