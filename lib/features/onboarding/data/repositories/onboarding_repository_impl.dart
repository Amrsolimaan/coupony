import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/repositories/base_repository.dart';
import '../data_sources/onboarding_local_data_source.dart';
import '../data_sources/onboarding_remote_data_source.dart';
import '../models/user_preferences_model.dart';
import '../../domain/entities/onboarding_user_type.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/entities/user_preferences_entity.dart';

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

  // ── Local persistence ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> savePreferencesLocally(
    List<String> selectedCategories, {
    String? budgetPreference,
    double? budgetSliderValue,
    List<String>? shoppingStyles,
  }) async {
    try {
      final preferences = UserPreferencesModel(
        selectedCategories: selectedCategories,
        budgetPreference: budgetPreference,
        budgetSliderValue: budgetSliderValue,
        shoppingStyles: shoppingStyles,
        timestamp: DateTime.now(),
        isSynced: false,
      );
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

  // ── Backend submission ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> submitOnboardingToApi({
    required OnboardingUserType userType,
    required String authToken,
  }) {
    return executeOnlineOperation(
      operation: () async {
        // 1. Read the locally saved preferences (must exist at this point)
        final preferencesResult = await localDataSource.getPreferences();

        final model = preferencesResult.fold(
          (failure) => throw CacheException(failure.message),
          (m) {
            if (m == null) throw const CacheException('No local preferences to submit');
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
    required OnboardingUserType userType,
  }) {
    return executeOnlineOperation(
      operation: () async {
        // 1. GET preferences from server
        final json = await remoteDataSource.fetchPreferences(
          userType: userType,
        );

        // 2. Read existing local data so we can preserve interest-tracking
        //    fields (categoryScores, seenProductIds, lastDecayDate) that the
        //    server does not store.
        final localResult = await localDataSource.getPreferences();
        final existing = localResult.fold((_) => null, (m) => m);

        // 3. Build merged model: server owns the preference fields,
        //    the device owns the behavioural tracking fields.
        final merged = UserPreferencesModel.fromApiGetJson(
          json,
          existingScores:       existing?.categoryScores   ?? const {},
          existingSeenIds:      existing?.seenProductIds   ?? const [],
          existingLastDecayDate: existing?.lastDecayDate,
        );

        // 4. Persist to Hive
        await localDataSource.savePreferences(merged);
      },
    );
  }
}
