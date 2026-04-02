import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../repositories/onboarding_Seller_repository.dart';

class SaveSellerOnboardingPreferencesUseCase {
  final SellerOnboardingRepository repository;

  SaveSellerOnboardingPreferencesUseCase(this.repository);

  Future<Either<Failure, void>> call({
    String? priceCategory,
    String? customerReachMethod,
    String? bestOfferTime,
    String? targetAudience,
  }) {
    return repository.savePreferencesLocally(
      priceCategory: priceCategory,
      customerReachMethod: customerReachMethod,
      bestOfferTime: bestOfferTime,
      targetAudience: targetAudience,
    );
  }
}
