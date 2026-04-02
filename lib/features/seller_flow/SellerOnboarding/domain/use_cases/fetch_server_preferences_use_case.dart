import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/onboarding_Seller_type.dart';
import '../repositories/onboarding_Seller_repository.dart';

/// Fetches the seller's onboarding preferences from the server and writes them
/// to Hive, merging with any existing local data.
///
/// Call this after a successful login / OTP verification when the server
/// reports [is_onboarding_completed == true], so the device always reflects
/// the account's true preferences regardless of which device was used to
/// originally complete onboarding.
class FetchSellerPreferencesUseCase {
  final SellerOnboardingRepository repository;

  const FetchSellerPreferencesUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required OnboardingSellerType userType,
  }) {
    return repository.fetchAndCacheFromServer(userType: userType);
  }
}
