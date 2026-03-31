import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/password_reset_response_model.dart';
import '../models/user_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// AUTH REMOTE DATA SOURCE
// ═══════════════════════════════════════════════════════════════════════════

abstract class AuthRemoteDataSource {
  /// POST /auth/login
  Future<UserModel> login({
    required String email,
    required String password,
    required String role,
  });

  /// POST /auth/register
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
    required String role,
  });

  /// POST /auth/otp/send  body: { email }
  Future<void> sendOtp({required String email});

  /// POST /auth/otp/verify  body: { email, code, purpose: verify_email }
  Future<UserModel> verifyOtp({
    required String email,
    required String code,
  });

  /// POST /auth/password/verify-otp  body: { email, code }
  /// Returns the server-generated reset_token from response.
  Future<String> verifyResetCode({
    required String email,
    required String code,
  });

  /// POST /auth/password/forgot  body: { email }
  Future<PasswordResetResponseModel> sendResetCode({required String email});

  /// POST /auth/password/resend-otp  body: { email }
  Future<PasswordResetResponseModel> resendResetCode({required String email});

  /// POST /auth/password/reset  body: { email, reset_token, password, password_confirmation }
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  });

  /// POST /auth/refresh
  Future<UserModel> refreshToken(String refreshToken);

  /// POST /auth/logout
  Future<void> logout();

  /// POST /auth/fcm-token
  Future<void> updateFcmToken({required String fcmToken});
}

// ═══════════════════════════════════════════════════════════════════════════
// IMPLEMENTATION
// ═══════════════════════════════════════════════════════════════════════════

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;
  final Logger logger;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.logger,
  });

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      logger.i('🔐 LOGIN REQUEST - Email: $email, Role: $role');
      
      final response = await client.post(
        ApiConstants.login,
        data: {
          'email':    email,
          'password': password,
          'role':     role,
        },
      );
      
      final data = response.data as Map<String, dynamic>? ?? {};
      
      // 🔍 DETAILED LOGGING للتأكد من وجود is_onboarding_completed
      logger.i('📥 LOGIN RESPONSE - Full Response:');
      logger.i('Raw Response Data: $data');
      
      // فحص البيانات المتداخلة
      final nestedData = data['data'] as Map<String, dynamic>? ?? data;
      logger.i('Nested Data: $nestedData');
      
      // فحص وجود is_onboarding_completed بالتفصيل
      final onboardingCompleted = nestedData['is_onboarding_completed'];
      logger.i('🎯 is_onboarding_completed field:');
      logger.i('  - Value: $onboardingCompleted');
      logger.i('  - Type: ${onboardingCompleted.runtimeType}');
      logger.i('  - Is null: ${onboardingCompleted == null}');
      
      // عرض جميع المفاتيح الموجودة
      logger.i('📋 All available keys in response:');
      nestedData.keys.forEach((key) {
        logger.i('  - $key: ${nestedData[key]} (${nestedData[key].runtimeType})');
      });
      
      final userModel = UserModel.fromJson(data);
      logger.i('✅ UserModel created - isOnboardingCompleted: ${userModel.isOnboardingCompleted}');
      
      return userModel;
    } on DioException catch (e) {
      logger.e('❌ LOGIN ERROR - DioException: ${e.response?.statusCode} - ${e.response?.data}');
      _rethrowAs422Or(e);
    } catch (e) {
      logger.e('❌ LOGIN ERROR - General Exception: $e');
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
    required String role,
  }) async {
    try {
      logger.i('📝 REGISTER REQUEST - Email: $email, Role: $role');
      
      final response = await client.post(
        ApiConstants.register,
        data: {
          'first_name':            firstName,
          'last_name':             lastName,
          'email':                 email,
          'phone_number':          phoneNumber,
          'password':              password,
          'password_confirmation': passwordConfirmation,
          'role':                  role,
        },
      );
      
      final data = response.data as Map<String, dynamic>? ?? {};
      
      // 🔍 DETAILED LOGGING للتأكد من وجود is_onboarding_completed
      logger.i('📥 REGISTER RESPONSE - Full Response:');
      logger.i('Raw Response Data: $data');
      
      // فحص البيانات المتداخلة
      final nestedData = data['data'] as Map<String, dynamic>? ?? data;
      logger.i('Nested Data: $nestedData');
      
      // فحص وجود is_onboarding_completed بالتفصيل
      final onboardingCompleted = nestedData['is_onboarding_completed'];
      logger.i('🎯 is_onboarding_completed field:');
      logger.i('  - Value: $onboardingCompleted');
      logger.i('  - Type: ${onboardingCompleted.runtimeType}');
      logger.i('  - Is null: ${onboardingCompleted == null}');
      
      // عرض جميع المفاتيح الموجودة
      logger.i('📋 All available keys in response:');
      nestedData.keys.forEach((key) {
        logger.i('  - $key: ${nestedData[key]} (${nestedData[key].runtimeType})');
      });
      
      final userModel = UserModel.fromJson(data);
      logger.i('✅ UserModel created - isOnboardingCompleted: ${userModel.isOnboardingCompleted}');
      
      return userModel;
    } on DioException catch (e) {
      logger.e('❌ REGISTER ERROR - DioException: ${e.response?.statusCode} - ${e.response?.data}');
      _rethrowAs422Or(e);
    } catch (e) {
      logger.e('❌ REGISTER ERROR - General Exception: $e');
      throw ServerException(e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // OTP OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> sendOtp({required String email}) async {
    try {
      await client.post(
        ApiConstants.sendOtp,
        data: {
          'email': email,
          'purpose': 'verify_email',
        },
      );
    } on DioException catch (e) {
      _rethrowAs422Or(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await client.post(
        ApiConstants.verifyOtp,
        data: {
          'email':   email,
          'code':    code,
          'purpose': 'verify_email',
        },
      );
      final data = response.data as Map<String, dynamic>? ?? {};
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      _rethrowAs422Or(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await client.post(
        ApiConstants.verifyResetOtp,
        data: {
          'email': email,
          'code':  code,
        },
      );
      
      logger.i('Verify reset code response: ${response.data}');
      
      final data = response.data as Map<String, dynamic>? ?? {};
      final nested = data['data'] as Map<String, dynamic>? ?? data;
      
      // Extract reset_token from response
      final resetToken = nested['reset_token'] as String?;
      
      if (resetToken == null || resetToken.isEmpty) {
        logger.e('No reset_token in response. Response data: $nested');
        throw const ServerException('No reset_token in response');
      }
      
      logger.i('Reset token extracted successfully: ${resetToken.substring(0, 10)}...');
      return resetToken;
    } on DioException catch (e) {
      logger.e('Verify reset code DioException: ${e.response?.statusCode} - ${e.response?.data}');
      _rethrowAs422Or(e);
    } catch (e) {
      logger.e('Verify reset code error: $e');
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PASSWORD RESET OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<PasswordResetResponseModel> sendResetCode({required String email}) async {
    try {
      final response = await client.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      final data = response.data as Map<String, dynamic>? ?? {};
      return PasswordResetResponseModel.fromJson(data);
    } on DioException catch (e) {
      _rethrowAs422Or(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PasswordResetResponseModel> resendResetCode({required String email}) async {
    try {
      final response = await client.post(
        ApiConstants.resendResetCode,
        data: {'email': email},
      );
      final data = response.data as Map<String, dynamic>? ?? {};
      return PasswordResetResponseModel.fromJson(data);
    } on DioException catch (e) {
      _rethrowAs422Or(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      logger.i('Sending reset password request - email: $email, token: ${token.substring(0, 3)}***, token_length: ${token.length}');
      await client.post(
        ApiConstants.resetPassword,
        data: {
          'email':                 email,
          'reset_token':           token,
          'password':              password,
          'password_confirmation': passwordConfirmation,
        },
      );
      logger.i('Reset password successful');
    } on DioException catch (e) {
      logger.e('Reset password DioException: ${e.response?.statusCode} - ${e.response?.data}');
      _rethrowAs422Or(e);
    } catch (e) {
      logger.e('Reset password error: $e');
      throw ServerException(e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TOKEN & SESSION OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<UserModel> refreshToken(String refreshToken) async {
    try {
      final response = await client.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      final data = response.data as Map<String, dynamic>? ?? {};
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      _rethrowAs422Or(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.post(ApiConstants.logout);
    } catch (_) {
      // Best-effort — always clear local state regardless
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

  // ══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Rethrows DioException based on status code:
  /// - 422 with token-related message → InvalidTokenException
  /// - Other 422 errors are already handled by ErrorInterceptor as ValidationException
  /// - Other errors → ServerException
  Never _rethrowAs422Or(DioException e) {
    // Check if ErrorInterceptor already wrapped this as ValidationException
    if (e.error is ValidationException) {
      throw e.error as ValidationException;
    }
    
    final data = e.response?.data;
    String backendMessage(String fallback) {
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? fallback;
      }
      return fallback;
    }

    final statusCode = e.response?.statusCode;
    final message = backendMessage(e.message ?? 'Network error');

    // Handle 422 - check if it's a token-related error
    if (statusCode == 422) {
      final lowerMsg = message.toLowerCase();
      if (lowerMsg.contains('token') && 
          (lowerMsg.contains('invalid') || lowerMsg.contains('expired'))) {
        throw InvalidTokenException(message);
      }
    }
    
    // All other errors
    throw ServerException(message);
  }
}
