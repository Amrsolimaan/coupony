import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/onboarding_repository.dart';

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
