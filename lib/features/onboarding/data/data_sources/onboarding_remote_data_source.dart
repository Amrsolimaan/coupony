import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_preferences_model.dart';

/// Remote data source for syncing onboarding preferences to backend
/// ⚠️ TODO: Implement when API is available
abstract class OnboardingRemoteDataSource {
  /// Sync preferences to backend
  Future<Either<Failure, void>> syncPreferences(
    UserPreferencesModel preferences,
    String authToken,
  );
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final DioClient client;

  OnboardingRemoteDataSourceImpl({required this.client});

  @override
  Future<Either<Failure, void>> syncPreferences(
    UserPreferencesModel preferences,
    String authToken,
  ) async {
    // ════════════════════════════════════════════════════════
    // TODO: Implement when API endpoint is available
    // ════════════════════════════════════════════════════════
    //
    // Expected API:
    // POST /user/preferences
    // Headers: { "Authorization": "Bearer $authToken" }
    // Body: {
    //   "selected_categories": ["restaurants", "fashion", ...]
    // }
    //
    // Example Implementation:
    // ════════════════════════════════════════════════════════
    // try {
    //   final response = await client.post(
    //     '/user/preferences',
    //     data: {
    //       'selected_categories': preferences.selectedCategories,
    //     },
    //   );
    //
    //   if (response.statusCode == 200 || response.statusCode == 201) {
    //     return const Right(null);
    //   } else {
    //     return Left(ServerFailure('Failed to sync preferences'));
    //   }
    // } on DioException catch (e) {
    //   return Left(ServerFailure(e.message ?? 'Network error'));
    // } catch (e) {
    //   return Left(UnexpectedFailure(e.toString()));
    // }
    // ════════════════════════════════════════════════════════

    // Placeholder: Return success for now
    return const Right(null);
  }
}
