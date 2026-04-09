import 'package:coupony/features/seller_flow/SellerOnboarding/domain/entities/onboarding_Seller_type.dart';
import 'package:equatable/equatable.dart';

/// Navigation signals for seller onboarding flow
enum SellerOnboardingNavigation {
  none,
  toCustomerReachMethod, // Step 1 → Step 2
  toBestOfferTime,       // Step 2 → Step 3
  toTargetAudience,      // Step 3 → Step 4
  showSuccessBottomSheet, // Show success bottom sheet after API submission
  toCreateStore,         // Navigate directly to Create Store after completion
  toLogin,               // User skipped onboarding (deprecated - use toHome)
  toHome,                // Navigate to home after skipping all steps
}

/// Unified state for seller onboarding flow (Steps 1 → 4)
class SellerOnboardingFlowState extends Equatable {
  // ════════════════════════════════════════════════════════
  // USER TYPE (always seller — kept for API contract symmetry)
  // ════════════════════════════════════════════════════════
  final OnboardingSellerType userType;

  // ════════════════════════════════════════════════════════
  // CURRENT STEP TRACKING
  // ════════════════════════════════════════════════════════
  final int currentStep; // 1, 2, 3, or 4
  final SellerOnboardingNavigation navigationSignal;

  // ════════════════════════════════════════════════════════
  // STEP 1: PRICE CATEGORY
  // Valid values: budget | mid_range | premium
  // ════════════════════════════════════════════════════════
  final String? priceCategory;
  final bool isStep1Valid;

  // ════════════════════════════════════════════════════════
  // STEP 2: CUSTOMER REACH METHOD
  // Valid values: physical_store | online_only
  // ════════════════════════════════════════════════════════
  final String? customerReachMethod;
  final bool isStep2Valid;

  // ════════════════════════════════════════════════════════
  // STEP 3: BEST OFFER TIME
  // Valid values: all_week | weekends_occasions | off_peak
  // ════════════════════════════════════════════════════════
  final String? bestOfferTime;
  final bool isStep3Valid;

  // ════════════════════════════════════════════════════════
  // STEP 4: TARGET AUDIENCE
  // Valid values: youth | families | all
  // ════════════════════════════════════════════════════════
  final String? targetAudience;
  final bool isStep4Valid;

  // ════════════════════════════════════════════════════════
  // FLOW STATE
  // ════════════════════════════════════════════════════════
  final bool isSaving;           // Local Hive save in progress
  final bool isSubmittingToApi;  // API call in progress (Step 4 submit)
  final bool isApiSubmitted;     // API returned 200 OK
  final String? errorMessageKey;   // Localized error key
  final String? apiErrorKey;       // API-specific error (retryable)
  final String? successMessageKey; // Localized success key
  final bool isCompleted; // All steps completed and API confirmed
  final bool isSkipped;   // User skipped onboarding for this session
  final bool hasChanges;  // Unsaved in-progress changes

  const SellerOnboardingFlowState({
    this.userType = OnboardingSellerType.seller,
    this.currentStep = 1,
    this.navigationSignal = SellerOnboardingNavigation.none,
    // Step 1
    this.priceCategory,
    this.isStep1Valid = false,
    // Step 2
    this.customerReachMethod,
    this.isStep2Valid = false,
    // Step 3
    this.bestOfferTime,
    this.isStep3Valid = false,
    // Step 4
    this.targetAudience,
    this.isStep4Valid = false,
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
  SellerOnboardingFlowState copyWith({
    OnboardingSellerType? userType,
    int? currentStep,
    SellerOnboardingNavigation? navigationSignal,
    // Step 1
    String? priceCategory,
    bool? isStep1Valid,
    // Step 2
    String? customerReachMethod,
    bool? isStep2Valid,
    // Step 3
    String? bestOfferTime,
    bool? isStep3Valid,
    // Step 4
    String? targetAudience,
    bool? isStep4Valid,
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
    return SellerOnboardingFlowState(
      userType:         userType         ?? this.userType,
      currentStep:      currentStep      ?? this.currentStep,
      navigationSignal: navigationSignal ?? this.navigationSignal,
      // Step 1
      priceCategory: priceCategory ?? this.priceCategory,
      isStep1Valid:  isStep1Valid  ?? this.isStep1Valid,
      // Step 2
      customerReachMethod: customerReachMethod ?? this.customerReachMethod,
      isStep2Valid:        isStep2Valid        ?? this.isStep2Valid,
      // Step 3
      bestOfferTime: bestOfferTime ?? this.bestOfferTime,
      isStep3Valid:  isStep3Valid  ?? this.isStep3Valid,
      // Step 4
      targetAudience: targetAudience ?? this.targetAudience,
      isStep4Valid:   isStep4Valid   ?? this.isStep4Valid,
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

  /// Check if all 4 steps are valid
  bool get isAllStepsValid =>
      isStep1Valid && isStep2Valid && isStep3Valid && isStep4Valid;

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    int completed = 0;
    if (isStep1Valid) completed++;
    if (isStep2Valid) completed++;
    if (isStep3Valid) completed++;
    if (isStep4Valid) completed++;
    return completed / 4.0;
  }

  /// Check if user can proceed from current step
  bool get canProceed {
    switch (currentStep) {
      case 1: return isStep1Valid;
      case 2: return isStep2Valid;
      case 3: return isStep3Valid;
      case 4: return isStep4Valid;
      default: return false;
    }
  }

  /// Check if user can submit (all steps completed)
  bool get canSubmit => isAllStepsValid;

  @override
  List<Object?> get props => [
    userType,
    currentStep,
    navigationSignal,
    priceCategory,
    isStep1Valid,
    customerReachMethod,
    isStep2Valid,
    bestOfferTime,
    isStep3Valid,
    targetAudience,
    isStep4Valid,
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
      'SellerOnboardingFlowState('
      'step: $currentStep, '
      'priceCategory: $priceCategory, '
      'reachMethod: $customerReachMethod, '
      'offerTime: $bestOfferTime, '
      'audience: $targetAudience, '
      'completed: $isCompleted)';
}
