import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/onboarding_user_type.dart';
import '../entities/user_preferences_entity.dart';

/// Repository interface for onboarding preferences
abstract class OnboardingRepository {
  // ── Local persistence ───────────────────────────────────────────────────

  /// Save all 3 wizard steps locally (used as in-progress draft before API call).
  Future<Either<Failure, void>> savePreferencesLocally(
    List<String> selectedCategories, {
    String? budgetPreference,
    double? budgetSliderValue,
    List<String>? shoppingStyles,
  });

  /// Get locally cached preferences (may be incomplete/un-synced).
  Future<Either<Failure, UserPreferencesEntity?>> getLocalPreferences();

  /// Delete all local preferences (e.g. on logout).
  Future<Either<Failure, void>> clearLocalPreferences();

  /// Quick existence check — does not deserialize the model.
  Future<bool> hasLocalPreferences();

  // ── Backend submission ───────────────────────────────────────────────────

  /// POST the completed onboarding to the correct role-based endpoint.
  ///
  /// Reads the locally saved [UserPreferencesModel], serializes it with
  /// [toApiJson()], and sends it to `/on-boarding/{customer|seller}`.
  ///
  /// On success: marks the local model as `isSynced: true`.
  /// The caller ([OnboardingFlowCubit]) is responsible for persisting the
  /// account-level "completed" flag via [AuthLocalDataSource].
  Future<Either<Failure, void>> submitOnboardingToApi({
    required OnboardingUserType userType,
    required String authToken,
  });

  // ── Server sync ─────────────────────────────────────────────────────────

  /// GET the user's server-stored preferences and write them to Hive.
  ///
  /// Merges server values (categories, shopping styles, budget) with any
  /// existing local interest-tracking data (categoryScores, seenProductIds)
  /// so behavioural signals accumulated on this device are not lost.
  ///
  /// Returns [Right(unit)] on success or [Left(Failure)] if the network
  /// call fails.  Callers may treat this as fire-and-forget.
  Future<Either<Failure, void>> fetchAndCacheFromServer({
    required OnboardingUserType userType,
  });
}
