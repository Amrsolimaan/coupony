import 'package:dartz/dartz.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/storage/local_cache_service.dart';
import '../../../../../core/constants/storage_keys.dart';
import '../../../../../features/auth/data/datasources/auth_local_data_source.dart';
import '../models/seller_preferences_model.dart';

/// Local data source for seller onboarding preferences.
/// All Hive keys are scoped per-user (prefixed with userId) to prevent data
/// leakage between different accounts on the same device.
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

  /// Required to resolve the current user's ID before every cache operation.
  final AuthLocalDataSource authLocalDataSource;

  SellerOnboardingLocalDataSourceImpl({
    required this.cacheService,
    required this.authLocalDataSource,
  });

  // ── Key helpers ──────────────────────────────────────────────────────────

  /// Centralised user-scoped key builder — mirrors the logic in
  /// [AuthLocalDataSourceImpl] so the DRY principle is enforced per layer.
  String _getUserKey(String baseKey, String userId) => '${userId}_$baseKey';

  /// Retrieves the authenticated userId or throws [CacheException] so every
  /// caller fails loudly instead of silently writing to a shared key.
  Future<String> _requireUserId() async {
    final id = await authLocalDataSource.getUserId();
    if (id == null) {
      throw const CacheException(
        'No authenticated user found — cannot access seller onboarding cache.',
      );
    }
    return id;
  }

  // ── Operations ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> savePreferences(
    SellerPreferencesModel preferences,
  ) async {
    try {
      final userId = await _requireUserId();
      await cacheService.put<SellerPreferencesModel>(
        boxName: StorageKeys.sellerOnboardingPreferencesBox,
        key: _getUserKey(StorageKeys.sellerOnboardingPreferencesKey, userId),
        value: preferences,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        CacheFailure('Failed to save seller preferences: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, SellerPreferencesModel?>> getPreferences() async {
    try {
      final userId = await _requireUserId();
      final preferences = await cacheService.get<SellerPreferencesModel>(
        boxName: StorageKeys.sellerOnboardingPreferencesBox,
        key: _getUserKey(StorageKeys.sellerOnboardingPreferencesKey, userId),
      );
      return Right(preferences);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        CacheFailure('Failed to get seller preferences: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearPreferences() async {
    try {
      final userId = await _requireUserId();
      await cacheService.delete(
        boxName: StorageKeys.sellerOnboardingPreferencesBox,
        key: _getUserKey(StorageKeys.sellerOnboardingPreferencesKey, userId),
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        CacheFailure('Failed to clear seller preferences: ${e.toString()}'),
      );
    }
  }

  @override
  Future<bool> hasPreferences() async {
    try {
      final userId = await _requireUserId();
      return await cacheService.containsKey(
        boxName: StorageKeys.sellerOnboardingPreferencesBox,
        key: _getUserKey(StorageKeys.sellerOnboardingPreferencesKey, userId),
      );
    } catch (_) {
      return false;
    }
  }
}
