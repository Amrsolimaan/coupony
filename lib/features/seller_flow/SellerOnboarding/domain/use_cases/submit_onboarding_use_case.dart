import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/onboarding_Seller_type.dart';
import '../repositories/onboarding_Seller_repository.dart';

/// Submits completed seller onboarding preferences to the backend.
///
/// The auth token is injected automatically by [AuthInterceptor] — the use
/// case only needs to know the user's role to target the correct endpoint.
class SubmitSellerOnboardingUseCase {
  final SellerOnboardingRepository repository;

  const SubmitSellerOnboardingUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required OnboardingSellerType userType,
  }) {
    return repository.submitOnboardingToApi(
      userType: userType,
      authToken: '', // kept for contract compatibility; interceptor injects real token
    );
  }
}
