import 'package:coupony/core/errors/exceptions.dart';
import 'package:coupony/core/network/dio_client.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/entities/onboarding_user_type.dart';
import 'package:dio/dio.dart';
import '../models/user_preferences_model.dart';

abstract class OnboardingRemoteDataSource {
  /// POST /on-boarding/{customer|seller}  (base URL already includes /api/v1)
  ///
  /// Throws [ServerException] on any network / server error.
  /// Callers (the repository) should NOT wrap this in try/catch —
  /// [BaseRepository.executeOnlineOperation] handles it via [_handleError].
  Future<void> submitOnboarding({
    required UserPreferencesModel preferences,
    required OnboardingUserType userType,
  });

  /// GET /on-boarding/{customer|seller}
  ///
  /// Returns the user's server-stored preferences as a raw JSON map.
  /// Throws [ServerException] on any network / server error.
  Future<Map<String, dynamic>> fetchPreferences({
    required OnboardingUserType userType,
  });
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final DioClient client;

  OnboardingRemoteDataSourceImpl({required this.client});

  @override
  Future<void> submitOnboarding({
    required UserPreferencesModel preferences,
    required OnboardingUserType userType,
  }) async {
    // AuthInterceptor injects the Bearer token automatically — no Options needed.
    try {
      final apiData = preferences.toApiJson();
      print('🚀 OnboardingRemoteDataSource.submitOnboarding');
      print('  - Endpoint: /on-boarding/${userType.apiSegment}');
      print('  - API Data: $apiData');
      print('  - User Type: ${userType.name}');

      await client.post(
        '/on-boarding/${userType.apiSegment}',
        data: apiData,
      );
      
      print('✅ Onboarding submission successful');
    } on DioException catch (e) {
      // ═══════════════════════════════════════════════════════════════════
      // 🔍 TEMPORARY DEBUG LOGGING - REMOVE AFTER FIXING THE ISSUE
      // ═══════════════════════════════════════════════════════════════════
      print('❌ DioException caught in submitOnboarding:');
      print('  - Type: ${e.type}');
      print('  - Message: ${e.message}');
      print('  - Status Code: ${e.response?.statusCode}');
      print('  - Response Data: ${e.response?.data}');
      print('  - Response Headers: ${e.response?.headers}');
      print('  - Request Path: ${e.requestOptions.path}');
      print('  - Request Data: ${e.requestOptions.data}');
      print('  - Error Object: ${e.error}');
      print('═══════════════════════════════════════════════════════════════════');
      // ═══════════════════════════════════════════════════════════════════
      
      final error = e.error;
      if (error is ServerException) throw error;
      if (error is UnauthorizedException) throw error;
      throw ServerException(e.message ?? 'Network error during onboarding submission');
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> fetchPreferences({
    required OnboardingUserType userType,
  }) async {
    try {
      print('📥 OnboardingRemoteDataSource.fetchPreferences');
      print('  - Endpoint: /on-boarding/${userType.apiSegment}');

      final response = await client.get(
        '/on-boarding/${userType.apiSegment}',
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      print('✅ Onboarding preferences fetched: $data');
      return data;
    } on DioException catch (e) {
      // ═══════════════════════════════════════════════════════════════════
      // 🔍 TEMPORARY DEBUG LOGGING - REMOVE AFTER FIXING THE ISSUE
      // ═══════════════════════════════════════════════════════════════════
      print('❌ DioException caught in fetchPreferences:');
      print('  - Type: ${e.type}');
      print('  - Message: ${e.message}');
      print('  - Status Code: ${e.response?.statusCode}');
      print('  - Response Data: ${e.response?.data}');
      print('  - Response Headers: ${e.response?.headers}');
      print('  - Request Path: ${e.requestOptions.path}');
      print('  - Error Object: ${e.error}');
      print('═══════════════════════════════════════════════════════════════════');
      // ═══════════════════════════════════════════════════════════════════
      
      // e.error is set by ErrorInterceptor (ServerException / UnauthorizedException).
      // Fall back to e.message for raw Dio errors that bypass the interceptor.
      final error = e.error;
      if (error is ServerException) throw error;
      if (error is UnauthorizedException) throw error;
      throw ServerException(e.message ?? 'Network error during onboarding submission');
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
