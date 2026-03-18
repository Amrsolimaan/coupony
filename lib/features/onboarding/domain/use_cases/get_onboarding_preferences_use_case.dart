import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_preferences_entity.dart';
import '../repositories/onboarding_repository.dart';

class GetOnboardingPreferencesUseCase {
  final OnboardingRepository repository;

  GetOnboardingPreferencesUseCase(this.repository);

  Future<Either<Failure, UserPreferencesEntity?>> call() {
    return repository.getLocalPreferences();
  }
}
