import 'package:dio/dio.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../domain/entities/onboarding_Seller_type.dart';
import '../models/seller_preferences_model.dart';

abstract class SellerOnboardingRemoteDataSource {
  /// POST /on-boarding/seller  (base URL already includes /api/v1)
  ///
  /// Throws [ServerException] on any network / server error.
  /// Callers (the repository) should NOT wrap this in try/catch —
  /// [BaseRepository.executeOnlineOperation] handles it via [_handleError].
  Future<void> submitOnboarding({
    required SellerPreferencesModel preferences,
    required OnboardingSellerType userType,
  });

  /// GET /on-boarding/seller
  ///
  /// Returns the seller's server-stored preferences as a raw JSON map.
  /// Throws [ServerException] on any network / server error.
  Future<Map<String, dynamic>> fetchPreferences({
    required OnboardingSellerType userType,
  });
}

class SellerOnboardingRemoteDataSourceImpl
    implements SellerOnboardingRemoteDataSource {
  final DioClient client;

  SellerOnboardingRemoteDataSourceImpl({required this.client});

  @override
  Future<void> submitOnboarding({
    required SellerPreferencesModel preferences,
    required OnboardingSellerType userType,
  }) async {
    // AuthInterceptor injects the Bearer token automatically — no Options needed.
    try {
      final apiData = preferences.toApiJson();
      print('🚀 SellerOnboardingRemoteDataSource.submitOnboarding');
      print('  - Endpoint: /on-boarding/${userType.apiSegment}');
      print('  - API Data: $apiData');
      print('  - User Type: ${userType.name}');

      await client.post(
        '/on-boarding/${userType.apiSegment}',
        data: apiData,
      );

      print('✅ Seller onboarding submission successful');
    } on DioException catch (e) {
      print('❌ DioException caught:');
      print('  - Type: ${e.type}');
      print('  - Message: ${e.message}');
      print('  - Response: ${e.response?.data}');
      print('  - Status Code: ${e.response?.statusCode}');
      print('  - Error: ${e.error}');
      
      final error = e.error;
      if (error is ServerException) throw error;
      if (error is UnauthorizedException) throw error;
      
      // Provide more detailed error message
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      String errorMessage = 'Network error during seller onboarding submission';
      
      if (statusCode != null) {
        errorMessage = 'Server error ($statusCode)';
        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'];
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw ServerException(errorMessage);
    } catch (e) {
      print('❌ Unexpected exception: $e');
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> fetchPreferences({
    required OnboardingSellerType userType,
  }) async {
    try {
      print('📥 SellerOnboardingRemoteDataSource.fetchPreferences');
      print('  - Endpoint: /on-boarding/${userType.apiSegment}');

      final response = await client.get(
        '/on-boarding/${userType.apiSegment}',
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      print('✅ Seller onboarding preferences fetched: $data');
      return data;
    } on DioException catch (e) {
      // e.error is set by ErrorInterceptor (ServerException / UnauthorizedException).
      // Fall back to e.message for raw Dio errors that bypass the interceptor.
      final error = e.error;
      if (error is ServerException) throw error;
      if (error is UnauthorizedException) throw error;
      throw ServerException(e.message ?? 'Network error during seller onboarding fetch');
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
