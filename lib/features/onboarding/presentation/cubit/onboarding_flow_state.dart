import 'package:equatable/equatable.dart';
import '../../../../core/constants/budget_constants.dart';
import '../../domain/entities/onboarding_user_type.dart';

/// Navigation signals for onboarding flow
enum OnboardingNavigation {
  none,
  toBudget,
  toShoppingStyle,
  toLoading, // Navigate to loading page after onboarding completion
  toPermissions,
  toLogin,
}

/// Unified state for onboarding flow (Steps 1, 2, 3)
class OnboardingFlowState extends Equatable {
  // ════════════════════════════════════════════════════════
  // USER TYPE (SOURCE OF TRUTH FOR THEMING)
  // ════════════════════════════════════════════════════════
  final OnboardingUserType userType;
  
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
  final bool isSaving;           // Local Hive save in progress
  final bool isSubmittingToApi;  // API call in progress (Step 3 submit)
  final bool isApiSubmitted;     // API returned 200 OK
  final String? errorMessageKey;   // Localized error key
  final String? apiErrorKey;       // API-specific error (retryable)
  final String? successMessageKey; // Localized success key
  final bool isCompleted; // All steps completed and saved locally
  final bool isSkipped;   // User skipped onboarding for this session
  final bool hasChanges;  // Unsaved in-progress changes

  const OnboardingFlowState({
    this.userType = OnboardingUserType.customer, // Default to customer
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
    this.isSubmittingToApi = false,
    this.isApiSubmitted = false,
    this.errorMessageKey,
    this.apiErrorKey,
    this.successMessageKey,
    this.isCompleted = false,
    this.isSkipped = false,
    this.hasChanges = false,
  });

  /// Copy with method for immutable state updates
  OnboardingFlowState copyWith({
    OnboardingUserType? userType,
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
    bool? isSubmittingToApi,
    bool? isApiSubmitted,
    String? errorMessageKey,
    String? apiErrorKey,
    String? successMessageKey,
    bool? isCompleted,
    bool? isSkipped,
    bool? hasChanges,
  }) {
    return OnboardingFlowState(
      userType:         userType         ?? this.userType,
      currentStep:      currentStep      ?? this.currentStep,
      navigationSignal: navigationSignal ?? this.navigationSignal,
      // Step 1
      selectedCategories: selectedCategories ?? this.selectedCategories,
      isStep1Valid:       isStep1Valid       ?? this.isStep1Valid,
      // Step 2
      budgetPreference:  budgetPreference  ?? this.budgetPreference,
      budgetSliderValue: budgetSliderValue ?? this.budgetSliderValue,
      isStep2Valid:      isStep2Valid      ?? this.isStep2Valid,
      // Step 3
      shoppingStyles: shoppingStyles ?? this.shoppingStyles,
      isStep3Valid:   isStep3Valid   ?? this.isStep3Valid,
      // Flow
      isSaving:          isSaving          ?? this.isSaving,
      isSubmittingToApi: isSubmittingToApi ?? this.isSubmittingToApi,
      isApiSubmitted:    isApiSubmitted    ?? this.isApiSubmitted,
      errorMessageKey:   errorMessageKey,   // nullable — intentional passthrough
      apiErrorKey:       apiErrorKey,
      successMessageKey: successMessageKey,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped:   isSkipped   ?? this.isSkipped,
      hasChanges:  hasChanges  ?? this.hasChanges,
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
    userType,
    currentStep,
    navigationSignal,
    selectedCategories,
    isStep1Valid,
    budgetPreference,
    budgetSliderValue,
    isStep2Valid,
    shoppingStyles,
    isStep3Valid,
    isSaving,
    isSubmittingToApi,
    isApiSubmitted,
    errorMessageKey,
    apiErrorKey,
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
