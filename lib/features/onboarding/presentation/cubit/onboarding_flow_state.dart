import 'package:equatable/equatable.dart';
import '../../../../core/constants/budget_constants.dart';

/// Navigation signals for onboarding flow
enum OnboardingNavigation {
  none,
  toBudget,
  toShoppingStyle,
  toPermissions,
  toLogin,
}

/// Unified state for onboarding flow (Steps 1, 2, 3)
class OnboardingFlowState extends Equatable {
  // ════════════════════════════════════════════════════════
  // CURRENT STEP TRACKING
  // ════════════════════════════════════════════════════════
  final int currentStep; // 1, 2, or 3
  final OnboardingNavigation navigationSignal;

  // ════════════════════════════════════════════════════════
  // STEP 1: CATEGORY SELECTION
  // ... (rest of the fields)
  final List<String> selectedCategories;
  final bool isStep1Valid;

  // ════════════════════════════════════════════════════════
  // STEP 2: BUDGET SELECTION
  // ════════════════════════════════════════════════════════
  final String? budgetPreference; // 'low', 'medium', 'best_value'
  final double budgetSliderValue; // 0.0 to 1.0
  final bool isStep2Valid;

  // ════════════════════════════════════════════════════════
  // STEP 3: SHOPPING STYLE SELECTION
  // ════════════════════════════════════════════════════════
  final List<String> shoppingStyles;
  final bool isStep3Valid;

  // ════════════════════════════════════════════════════════
  // FLOW STATE
  // ════════════════════════════════════════════════════════
  final bool isSaving; // Loading state during save
  final String? errorMessageKey; // Error message key for localization
  final String? successMessageKey; // Success message key for localization
  final bool isCompleted; // All steps completed and saved
  final bool isSkipped; // User skipped onboarding
  final bool hasChanges; // Track if user made any changes

  const OnboardingFlowState({
    this.currentStep = 1,
    this.navigationSignal = OnboardingNavigation.none,
    // Step 1
    this.selectedCategories = const [],
    this.isStep1Valid = false,
    // Step 2
    this.budgetPreference,
    this.budgetSliderValue = BudgetConstants.defaultSliderValue,
    this.isStep2Valid = false,
    // Step 3
    this.shoppingStyles = const [],
    this.isStep3Valid = false,
    // Flow
    this.isSaving = false,
    this.errorMessageKey,
    this.successMessageKey,
    this.isCompleted = false,
    this.isSkipped = false,
    this.hasChanges = false,
  });

  /// Copy with method for immutable state updates
  OnboardingFlowState copyWith({
    int? currentStep,
    OnboardingNavigation? navigationSignal,
    // Step 1
    List<String>? selectedCategories,
    bool? isStep1Valid,
    // Step 2
    String? budgetPreference,
    double? budgetSliderValue,
    bool? isStep2Valid,
    // Step 3
    List<String>? shoppingStyles,
    bool? isStep3Valid,
    // Flow
    bool? isSaving,
    String? errorMessageKey,
    String? successMessageKey,
    bool? isCompleted,
    bool? isSkipped,
    bool? hasChanges,
  }) {
    return OnboardingFlowState(
      currentStep: currentStep ?? this.currentStep,
      navigationSignal: navigationSignal ?? this.navigationSignal,
      // Step 1
      selectedCategories: selectedCategories ?? this.selectedCategories,
      isStep1Valid: isStep1Valid ?? this.isStep1Valid,
      // Step 2
      budgetPreference: budgetPreference ?? this.budgetPreference,
      budgetSliderValue: budgetSliderValue ?? this.budgetSliderValue,
      isStep2Valid: isStep2Valid ?? this.isStep2Valid,
      // Step 3
      shoppingStyles: shoppingStyles ?? this.shoppingStyles,
      isStep3Valid: isStep3Valid ?? this.isStep3Valid,
      // Flow
      isSaving: isSaving ?? this.isSaving,
      errorMessageKey: errorMessageKey,
      successMessageKey: successMessageKey,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  // ════════════════════════════════════════════════════════
  // COMPUTED PROPERTIES
  // ════════════════════════════════════════════════════════

  /// Check if all steps are valid
  bool get isAllStepsValid => isStep1Valid && isStep2Valid && isStep3Valid;

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    int completed = 0;
    if (isStep1Valid) completed++;
    if (isStep2Valid) completed++;
    if (isStep3Valid) completed++;
    return completed / 3.0;
  }

  /// Check if user can proceed from current step
  bool get canProceed {
    switch (currentStep) {
      case 1:
        return isStep1Valid;
      case 2:
        return isStep2Valid;
      case 3:
        return isStep3Valid;
      default:
        return false;
    }
  }

  /// Check if user can submit (all steps completed)
  bool get canSubmit => isAllStepsValid;

  @override
  List<Object?> get props => [
    currentStep,
    selectedCategories,
    isStep1Valid,
    budgetPreference,
    budgetSliderValue,
    isStep2Valid,
    shoppingStyles,
    isStep3Valid,
    isSaving,
    errorMessageKey,
    successMessageKey,
    isCompleted,
    isSkipped,
    hasChanges,
  ];

  @override
  String toString() =>
      'OnboardingFlowState('
      'step: $currentStep, '
      'categories: ${selectedCategories.length}, '
      'budget: $budgetPreference, '
      'styles: ${shoppingStyles.length}, '
      'completed: $isCompleted)';
}
