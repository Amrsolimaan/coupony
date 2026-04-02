import 'package:coupony/core/constants/storage_keys.dart';
import 'package:coupony/core/errors/failures.dart';
import 'package:coupony/core/storage/local_cache_service.dart';
import 'package:dartz/dartz.dart';
import '../models/user_preferences_model.dart';

/// Local data source for onboarding preferences
/// Handles all Hive operations
abstract class OnboardingLocalDataSource {
  /// Save preferences to local storage
  Future<Either<Failure, void>> savePreferences(
    UserPreferencesModel preferences,
  );

  /// Get preferences from local storage
  Future<Either<Failure, UserPreferencesModel?>> getPreferences();

  /// Clear preferences from local storage
  Future<Either<Failure, void>> clearPreferences();

  /// Check if preferences exist
  Future<bool> hasPreferences();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final LocalCacheService cacheService;

  OnboardingLocalDataSourceImpl({required this.cacheService});

  @override
  Future<Either<Failure, void>> savePreferences(
    UserPreferencesModel preferences,
  ) async {
    try {
      await cacheService.put<UserPreferencesModel>(
        boxName: StorageKeys.onboardingPreferencesBox,
        key: StorageKeys.onboardingPreferencesKey,
        value: preferences,
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserPreferencesModel?>> getPreferences() async {
    try {
      final preferences = await cacheService.get<UserPreferencesModel>(
        boxName: StorageKeys.onboardingPreferencesBox,
        key: StorageKeys.onboardingPreferencesKey,
      );

      return Right(preferences);
    } catch (e) {
      return Left(CacheFailure('Failed to get preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearPreferences() async {
    try {
      await cacheService.delete(
        boxName: StorageKeys.onboardingPreferencesBox,
        key: StorageKeys.onboardingPreferencesKey,
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear preferences: ${e.toString()}'));
    }
  }

  @override
  Future<bool> hasPreferences() async {
    try {
      return await cacheService.containsKey(
        boxName: StorageKeys.onboardingPreferencesBox,
        key: StorageKeys.onboardingPreferencesKey,
      );
    } catch (e) {
      return false;
    }
  }
}
