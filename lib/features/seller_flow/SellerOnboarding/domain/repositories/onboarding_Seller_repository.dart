import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/onboarding_Seller_type.dart';
import '../entities/seller_preferences_entity.dart';

/// Repository interface for seller onboarding preferences
abstract class SellerOnboardingRepository {
  // ── Local persistence ───────────────────────────────────────────────────

  /// Save all 4 wizard steps locally (used as in-progress draft before API call).
  Future<Either<Failure, void>> savePreferencesLocally({
    String? priceCategory,
    String? customerReachMethod,
    String? bestOfferTime,
    String? targetAudience,
  });

  /// Get locally cached seller preferences (may be incomplete/un-synced).
  Future<Either<Failure, SellerPreferencesEntity?>> getLocalPreferences();

  /// Delete all local seller preferences (e.g. on logout).
  Future<Either<Failure, void>> clearLocalPreferences();

  /// Quick existence check — does not deserialize the model.
  Future<bool> hasLocalPreferences();

  // ── Backend submission ───────────────────────────────────────────────────

  /// POST the completed seller onboarding to the seller endpoint.
  ///
  /// Reads the locally saved [SellerPreferencesEntity], serializes it with
  /// [toApiJson()], and sends it to `/on-boarding/seller`.
  ///
  /// On success: marks the local model as `isSynced: true`.
  /// The caller (SellerOnboardingFlowCubit) is responsible for persisting the
  /// account-level "completed" flag via [AuthLocalDataSource].
  Future<Either<Failure, void>> submitOnboardingToApi({
    required OnboardingSellerType userType,
    required String authToken,
  });

  // ── Server sync ─────────────────────────────────────────────────────────

  /// GET the seller's server-stored preferences and write them to Hive.
  ///
  /// Merges server values with any existing local data so signals accumulated
  /// on this device are not lost.
  ///
  /// Returns [Right(unit)] on success or [Left(Failure)] if the network
  /// call fails.  Callers may treat this as fire-and-forget.
  Future<Either<Failure, void>> fetchAndCacheFromServer({
    required OnboardingSellerType userType,
  });
}
