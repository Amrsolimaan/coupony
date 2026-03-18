/// Budget preferences constants for onboarding Step 2
/// Keys are language-agnostic — used for storage & API
class BudgetConstants {
  BudgetConstants._();

  // ════════════════════════════════════════════════════════
  // BUDGET OPTION KEYS (Language-Agnostic)
  // ════════════════════════════════════════════════════════
  static const String low = 'low';
  static const String medium = 'medium';
  static const String bestValue = 'best_value';

  // ════════════════════════════════════════════════════════
  // ALL BUDGET OPTIONS LIST (Ordered as in design)
  // ════════════════════════════════════════════════════════
  static const List<String> allBudgetOptions = [low, medium, bestValue];

  // ════════════════════════════════════════════════════════
  // SLIDER MAPPING (Slider value → Budget option)
  // ════════════════════════════════════════════════════════
  /// Maps slider percentage (0.0 - 1.0) to budget option
  /// 0.0 - 0.33 → low
  /// 0.34 - 0.66 → medium
  /// 0.67 - 1.0 → bestValue
  static String getBudgetFromSlider(double sliderValue) {
    if (sliderValue <= 0.33) return low;
    if (sliderValue <= 0.66) return medium;
    return bestValue;
  }

  /// Maps budget option to slider value (for initialization)
  static double getSliderFromBudget(String budgetOption) {
    switch (budgetOption) {
      case low:
        return 0.17; // Middle of 0.0-0.33
      case medium:
        return 0.50; // Middle of 0.34-0.66 (default)
      case bestValue:
        return 0.83; // Middle of 0.67-1.0
      default:
        return 0.50; // Default to medium
    }
  }

  // ════════════════════════════════════════════════════════
  // DEFAULT VALUES
  // ════════════════════════════════════════════════════════
  static const String defaultBudget = medium;
  static const double defaultSliderValue = 0.50;

  // ════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════

  /// Validate if a key is a valid budget option
  static bool isValidBudget(String key) {
    return allBudgetOptions.contains(key);
  }

  /// Get localized name for budget option
  /// Note: UI will handle localization using AppLocalizations
  static String getBudgetKey(String budgetOption) {
    switch (budgetOption) {
      case low:
        return 'budgetLow'; // Key in l10n files
      case medium:
        return 'budgetMedium';
      case bestValue:
        return 'budgetBestValue';
      default:
        return budgetOption;
    }
  }
}
