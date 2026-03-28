import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/onboarding_user_type.dart';
import '../repositories/onboarding_repository.dart';

/// Fetches the user's onboarding preferences from the server and writes them
/// to Hive, merging with any existing local interest-tracking data.
///
/// Call this after a successful login / OTP verification when the server
/// reports [is_onboarding_completed == true], so the device always reflects
/// the account's true preferences regardless of which device was used to
/// originally complete onboarding.
class FetchServerPreferencesUseCase {
  final OnboardingRepository repository;

  const FetchServerPreferencesUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required OnboardingUserType userType,
  }) {
    return repository.fetchAndCacheFromServer(userType: userType);
  }
}
