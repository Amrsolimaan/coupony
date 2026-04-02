import 'package:dartz/dartz.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/repositories/base_repository.dart';
import '../data_sources/onboarding_Seller_local_data_source.dart';
import '../data_sources/onboarding_Seller_remote_data_source.dart';
import '../models/seller_preferences_model.dart';
import '../../domain/entities/onboarding_Seller_type.dart';
import '../../domain/entities/seller_preferences_entity.dart';
import '../../domain/repositories/onboarding_Seller_repository.dart';

class SellerOnboardingRepositoryImpl extends BaseRepository
    implements SellerOnboardingRepository {
  final SellerOnboardingLocalDataSource localDataSource;
  final SellerOnboardingRemoteDataSource remoteDataSource;

  SellerOnboardingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required super.networkInfo,
    required super.cacheService,
  });

  // ── Local persistence ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> savePreferencesLocally({
    String? priceCategory,
    String? customerReachMethod,
    String? bestOfferTime,
    String? targetAudience,
  }) async {
    try {
      final preferences = SellerPreferencesModel(
        priceCategory: priceCategory,
        customerReachMethod: customerReachMethod,
        bestOfferTime: bestOfferTime,
        targetAudience: targetAudience,
        timestamp: DateTime.now(),
        isSynced: false,
      );
      return await localDataSource.savePreferences(preferences);
    } catch (e) {
      return Left(CacheFailure('Failed to save seller preferences: $e'));
    }
  }

  @override
  Future<Either<Failure, SellerPreferencesEntity?>> getLocalPreferences() async {
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

  // ── Backend submission ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> submitOnboardingToApi({
    required OnboardingSellerType userType,
    required String authToken,
  }) {
    return executeOnlineOperation(
      operation: () async {
        // 1. Read the locally saved seller preferences (must exist at this point)
        final preferencesResult = await localDataSource.getPreferences();

        final model = preferencesResult.fold(
          (failure) => throw CacheException(failure.message),
          (m) {
            if (m == null) throw const CacheException('No local seller preferences to submit');
            return m;
          },
        );

        // 2. POST to backend — throws ServerException on failure,
        //    which executeOnlineOperation maps via _handleError.
        await remoteDataSource.submitOnboarding(
          preferences: model,
          userType: userType,
        );

        // 3. Mark as synced in Hive — cubit persists the account-level flag
        final synced = model.copyWith(isSynced: true);
        await localDataSource.savePreferences(synced);
      },
    );
  }

  // ── Server sync ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> fetchAndCacheFromServer({
    required OnboardingSellerType userType,
  }) {
    return executeOnlineOperation(
      operation: () async {
        // 1. GET seller preferences from server
        final json = await remoteDataSource.fetchPreferences(
          userType: userType,
        );

        // 2. Build model from server response — sellers have no local
        //    interest-tracking fields (no categoryScores / seenProductIds).
        final merged = SellerPreferencesModel.fromApiGetJson(json);

        // 3. Persist to Hive
        await localDataSource.savePreferences(merged);
      },
    );
  }
}
