import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/seller_preferences_entity.dart';
import '../repositories/onboarding_Seller_repository.dart';

class GetSellerOnboardingPreferencesUseCase {
  final SellerOnboardingRepository repository;

  GetSellerOnboardingPreferencesUseCase(this.repository);

  Future<Either<Failure, SellerPreferencesEntity?>> call() {
    return repository.getLocalPreferences();
  }
}
