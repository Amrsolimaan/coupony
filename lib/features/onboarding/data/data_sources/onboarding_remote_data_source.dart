import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/onboarding_user_type.dart';
import '../models/user_preferences_model.dart';

abstract class OnboardingRemoteDataSource {
  /// POST /api/v1/on-boarding/{customer|seller}
  ///
  /// Throws [ServerException] on any network / server error.
  /// Callers (the repository) should NOT wrap this in try/catch —
  /// [BaseRepository.executeOnlineOperation] handles it via [_handleError].
  Future<void> submitOnboarding({
    required UserPreferencesModel preferences,
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
      await client.post(
        '/api/v1/on-boarding/${userType.apiSegment}',
        data: preferences.toApiJson(),
      );
    } on DioException catch (e) {
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
