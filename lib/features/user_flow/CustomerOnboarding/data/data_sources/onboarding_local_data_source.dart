import 'package:coupony/core/constants/storage_keys.dart';
import 'package:coupony/core/errors/exceptions.dart';
import 'package:coupony/core/errors/failures.dart';
import 'package:coupony/core/storage/local_cache_service.dart';
import 'package:coupony/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:dartz/dartz.dart';
import '../models/user_preferences_model.dart';

/// Local data source for customer onboarding preferences.
/// All Hive keys are scoped per-user (prefixed with userId) to prevent data
/// leakage between different accounts on the same device.
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

  /// Required to resolve the current user's ID before every cache operation.
  final AuthLocalDataSource authLocalDataSource;

  OnboardingLocalDataSourceImpl({
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
        'No authenticated user found — cannot access customer onboarding cache.',
      );
    }
    return id;
  }

  // ── Operations ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> savePreferences(
    UserPreferencesModel preferences,
  ) async {
    try {
      final userId = await _requireUserId();
      await cacheService.put<UserPreferencesModel>(
        boxName: StorageKeys.onboardingPreferencesBox,
        key: _getUserKey(StorageKeys.onboardingPreferencesKey, userId),
        value: preferences,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to save preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserPreferencesModel?>> getPreferences() async {
    try {
      final userId = await _requireUserId();
      final preferences = await cacheService.get<UserPreferencesModel>(
        boxName: StorageKeys.onboardingPreferencesBox,
        key: _getUserKey(StorageKeys.onboardingPreferencesKey, userId),
      );
      return Right(preferences);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearPreferences() async {
    try {
      final userId = await _requireUserId();
      await cacheService.delete(
        boxName: StorageKeys.onboardingPreferencesBox,
        key: _getUserKey(StorageKeys.onboardingPreferencesKey, userId),
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        CacheFailure('Failed to clear preferences: ${e.toString()}'),
      );
    }
  }

  @override
  Future<bool> hasPreferences() async {
    try {
      final userId = await _requireUserId();
      return await cacheService.containsKey(
        boxName: StorageKeys.onboardingPreferencesBox,
        key: _getUserKey(StorageKeys.onboardingPreferencesKey, userId),
      );
    } catch (_) {
      return false;
    }
  }
}
