import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_preferences_entity.dart';

/// Repository interface for onboarding preferences
abstract class OnboardingRepository {
  /// Save preferences locally (before authentication)
  ///
  /// [selectedCategories] - Required: Categories from Step 1
  /// [budgetPreference] - Optional: Budget option from Step 2
  /// [budgetSliderValue] - Optional: Slider value from Step 2
  /// [shoppingStyles] - Optional: Shopping styles from Step 3
  Future<Either<Failure, void>> savePreferencesLocally(
    List<String> selectedCategories, {
    String? budgetPreference,
    double? budgetSliderValue,
    List<String>? shoppingStyles,
  });

  /// Get local preferences
  Future<Either<Failure, UserPreferencesEntity?>> getLocalPreferences();

  /// Clear local preferences
  Future<Either<Failure, void>> clearLocalPreferences();

  /// Check if preferences exist locally
  Future<bool> hasLocalPreferences();

  /// Sync preferences to backend (after authentication)
  /// ⚠️ TODO: Implement when API is available
  Future<Either<Failure, void>> syncPreferencesToBackend(String authToken);
}
