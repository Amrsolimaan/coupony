import 'package:coupony/features/user_flow/CustomerOnboarding/domain/repositories/onboarding_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:coupony/core/errors/failures.dart';

class SaveOnboardingPreferencesUseCase {
  final OnboardingRepository repository;

  SaveOnboardingPreferencesUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required List<String> selectedCategories,
    String? budgetPreference,
    double? budgetSliderValue,
    List<String>? shoppingStyles,
  }) {
    return repository.savePreferencesLocally(
      selectedCategories,
      budgetPreference: budgetPreference,
      budgetSliderValue: budgetSliderValue,
      shoppingStyles: shoppingStyles,
    );
  }
}
