import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/storage/local_cache_service.dart';
import '../../../../../core/constants/storage_keys.dart';
import '../models/seller_preferences_model.dart';

/// Local data source for seller onboarding preferences
/// Handles all Hive operations — isolated from Customer onboarding storage
abstract class SellerOnboardingLocalDataSource {
  /// Save seller preferences to local storage
  Future<Either<Failure, void>> savePreferences(
    SellerPreferencesModel preferences,
  );

  /// Get seller preferences from local storage
  Future<Either<Failure, SellerPreferencesModel?>> getPreferences();

  /// Clear seller preferences from local storage
  Future<Either<Failure, void>> clearPreferences();

  /// Check if seller preferences exist
  Future<bool> hasPreferences();
}

class SellerOnboardingLocalDataSourceImpl
    implements SellerOnboardingLocalDataSource {
  final LocalCacheService cacheService;

  SellerOnboardingLocalDataSourceImpl({required this.cacheService});

  @override
  Future<Either<Failure, void>> savePreferences(
    SellerPreferencesModel preferences,
  ) async {
    try {
      await cacheService.put<SellerPreferencesModel>(
        boxName: StorageKeys.sellerOnboardingPreferencesBox,
        key: StorageKeys.sellerOnboardingPreferencesKey,
        value: preferences,
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save seller preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SellerPreferencesModel?>> getPreferences() async {
    try {
      final preferences = await cacheService.get<SellerPreferencesModel>(
        boxName: StorageKeys.sellerOnboardingPreferencesBox,
        key: StorageKeys.sellerOnboardingPreferencesKey,
      );

      return Right(preferences);
    } catch (e) {
      return Left(CacheFailure('Failed to get seller preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearPreferences() async {
    try {
      await cacheService.delete(
        boxName: StorageKeys.sellerOnboardingPreferencesBox,
        key: StorageKeys.sellerOnboardingPreferencesKey,
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear seller preferences: ${e.toString()}'));
    }
  }

  @override
  Future<bool> hasPreferences() async {
    try {
      return await cacheService.containsKey(
        boxName: StorageKeys.sellerOnboardingPreferencesBox,
        key: StorageKeys.sellerOnboardingPreferencesKey,
      );
    } catch (e) {
      return false;
    }
  }
}
