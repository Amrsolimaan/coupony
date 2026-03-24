import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// POST /auth/login  body: { email, password, role }
  Future<UserModel> login({
    required String email,
    required String password,
    required String role,
  });

  /// POST /auth/register
  /// body: { first_name, last_name, email, phone_number, password, password_confirmation }
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
  });

  /// POST /auth/otp/send  body: { email, purpose }
  Future<void> sendOtp({
    required String email,
    String purpose = 'verify_email',
  });

  /// POST /auth/otp/verify  body: { email, code, purpose }
  Future<UserModel> verifyOtp({
    required String email,
    required String code,
    String purpose = 'verify_email',
  });

  /// POST /auth/refresh  body: { refresh_token }
  Future<UserModel> refreshToken(String refreshToken);

  /// POST /auth/logout  (Bearer token in header via AuthInterceptor)
  Future<void> logout();

  /// POST /auth/fcm-token  body: { fcm_token }
  Future<void> updateFcmToken({required String fcmToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await client.post(
        ApiConstants.login,
        data: {
          'email':    email,
          'password': password,
          'role':     role,
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
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await client.post(
        ApiConstants.register,
        data: {
          'first_name':             firstName,
          'last_name':              lastName,
          'email':                  email,
          'phone_number':           phoneNumber,
          'password':               password,
          'password_confirmation':  passwordConfirmation,
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
  Future<void> sendOtp({
    required String email,
    String purpose = 'verify_email',
  }) async {
    try {
      await client.post(
        ApiConstants.sendOtp,
        data: {
          'email':   email,
          'purpose': purpose,
        },
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String email,
    required String code,
    String purpose = 'verify_email',
  }) async {
    try {
      final response = await client.post(
        ApiConstants.verifyOtp,
        data: {
          'email':   email,
          'code':    code,
          'purpose': purpose,
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
  Future<void> logout() async {
    try {
      await client.post(ApiConstants.logout);
    } catch (_) {
      // Best-effort — local state is always cleared regardless
    }
  }

  @override
  Future<void> updateFcmToken({required String fcmToken}) async {
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
