import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/repositories/base_repository.dart';
import '../data_sources/onboarding_local_data_source.dart';
import '../data_sources/onboarding_remote_data_source.dart';
import '../models/user_preferences_model.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/entities/user_preferences_entity.dart';

/// Onboarding Repository Implementation
/// 
/// Extends BaseRepository for network/cache strategies and centralized error handling.
/// Handles user preferences storage (local) and syncing (remote).
class OnboardingRepositoryImpl extends BaseRepository
    implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required super.networkInfo,
    required super.cacheService,
  });

  @override
  Future<Either<Failure, void>> savePreferencesLocally(
    List<String> selectedCategories, {
    String? budgetPreference,
    double? budgetSliderValue,
    List<String>? shoppingStyles,
  }) async {
    try {
      // Create preferences model with all data
      final preferences = UserPreferencesModel(
        selectedCategories: selectedCategories,
        budgetPreference: budgetPreference,
        budgetSliderValue: budgetSliderValue,
        shoppingStyles: shoppingStyles,
        timestamp: DateTime.now(),
        isSynced: false, // Not synced yet (pre-auth)
      );

      // Save to local storage
      return await localDataSource.savePreferences(preferences);
    } catch (e) {
      return Left(CacheFailure('Failed to save preferences: $e'));
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity?>> getLocalPreferences() async {
    final result = await localDataSource.getPreferences();
    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model?.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> clearLocalPreferences() async {
    return await localDataSource.clearPreferences();
  }

  @override
  Future<bool> hasLocalPreferences() async {
    return await localDataSource.hasPreferences();
  }

  @override
  Future<Either<Failure, void>> syncPreferencesToBackend(
    String authToken,
  ) async {
    try {
      // Check if online
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(
          NetworkFailure('No internet connection to sync preferences'),
        );
      }

      // Get local preferences
      final preferencesResult = await getLocalPreferences();

      return preferencesResult.fold((failure) => Left(failure), (
        preferences,
      ) async {
        if (preferences == null) {
          return const Left(CacheFailure('No local preferences to sync'));
        }

        // Already synced? Skip
        if (preferences.isSynced) {
          return const Right(null);
        }

        // Sync to backend
        // ══════════════════════════════════════════════════════
        // TODO: Uncomment when API is available
        // ══════════════════════════════════════════════════════
        // final syncResult = await remoteDataSource.syncPreferences(
        //   preferences,
        //   authToken,
        // );
        //
        // return syncResult.fold(
        //   (failure) => Left(failure),
        //   (_) async {
        //     // Mark as synced in local storage
        //     final updatedPreferences = preferences.copyWith(isSynced: true);
        //     await localDataSource.savePreferences(updatedPreferences);
        //     return const Right(null);
        //   },
        // );
        // ══════════════════════════════════════════════════════

        // Placeholder: Mark as synced without API call
        final updatedEntity = preferences.copyWith(isSynced: true);
        final updatedModel = UserPreferencesModel.fromEntity(updatedEntity);
        await localDataSource.savePreferences(updatedModel);
        return const Right(null);
      });
    } catch (e) {
      return Left(ServerFailure('Sync failed: $e'));
    }
  }
}
