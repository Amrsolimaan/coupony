import 'package:coupony/core/errors/failures.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/entities/onboarding_user_type.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/repositories/onboarding_repository.dart';
import 'package:dartz/dartz.dart';


/// Submits completed onboarding preferences to the backend.
///
/// The auth token is injected automatically by [AuthInterceptor] — the use
/// case only needs to know the user's role to target the correct endpoint.
class SubmitOnboardingUseCase {
  final OnboardingRepository repository;

  const SubmitOnboardingUseCase(this.repository);

  Future<Either<Failure, void>> call({required OnboardingUserType userType}) {
    return repository.submitOnboardingToApi(
      userType: userType,
      authToken:
          '', // kept for contract compatibility; interceptor injects real token
    );
  }
}
