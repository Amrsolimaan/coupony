import 'package:coupony/core/storage/secure_storage_service.dart';
import 'package:coupony/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/domain/entities/onboarding_Seller_type.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/domain/entities/seller_preferences_entity.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/domain/use_cases/get_onboarding_preferences_use_case.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/domain/use_cases/save_onboarding_preferences_use_case.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/domain/use_cases/submit_onboarding_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'onboarding_Seller_flow_state.dart';

/// Cubit for managing the 4-step Seller onboarding flow.
///
/// Note: This Cubit uses a custom state (SellerOnboardingFlowState) instead
/// of BaseState because it manages complex UI flow with multiple steps,
/// navigation signals, and validation flags.
/// 
class SellerOnboardingFlowCubit extends Cubit<SellerOnboardingFlowState> {
  final SaveSellerOnboardingPreferencesUseCase savePreferencesUseCase;
  final GetSellerOnboardingPreferencesUseCase getPreferencesUseCase;
  final SubmitSellerOnboardingUseCase submitOnboardingUseCase;
  final SecureStorageService secureStorage;
  final AuthLocalDataSource authLocalDataSource;
  final Logger logger;

  // ── Original values for change detection ──────────────────────────────
  String? _originalPriceCategory;
  String? _originalCustomerReachMethod;
  String? _originalBestOfferTime;
  String? _originalTargetAudience;

  SellerOnboardingFlowCubit({
    required this.savePreferencesUseCase,
    required this.getPreferencesUseCase,
    required this.submitOnboardingUseCase,
    required this.secureStorage,
    required this.authLocalDataSource,
    required this.logger,
  }) : super(const SellerOnboardingFlowState()) {
    _loadExistingPreferences();
  }

  /// Safe emit wrapper to prevent emitting after cubit is closed
  void _safeEmit(SellerOnboardingFlowState newState) {
    if (!isClosed) emit(newState);
  }

  // ════════════════════════════════════════════════════════
  // INITIALIZATION
  // ════════════════════════════════════════════════════════

  /// Load existing preferences if the seller returns to onboarding mid-flow
  Future<void> _loadExistingPreferences() async {
    final result = await getPreferencesUseCase();

    result.fold(
      (failure) {
        logger.d('No existing seller preferences found');
      },
      (preferences) {
        if (preferences != null) {
          final isStep1Valid = preferences.priceCategory != null;
          final isStep2Valid = preferences.customerReachMethod != null;
          final isStep3Valid = preferences.bestOfferTime != null;
          final isStep4Valid = preferences.targetAudience != null;

          // Store originals for change detection
          _originalPriceCategory      = preferences.priceCategory;
          _originalCustomerReachMethod = preferences.customerReachMethod;
          _originalBestOfferTime      = preferences.bestOfferTime;
          _originalTargetAudience     = preferences.targetAudience;

          _safeEmit(
            state.copyWith(
              priceCategory:       preferences.priceCategory,
              customerReachMethod: preferences.customerReachMethod,
              bestOfferTime:       preferences.bestOfferTime,
              targetAudience:      preferences.targetAudience,
              isStep1Valid:        isStep1Valid,
              isStep2Valid:        isStep2Valid,
              isStep3Valid:        isStep3Valid,
              isStep4Valid:        isStep4Valid,
              currentStep:         _calculateCurrentStep(preferences),
              hasChanges:          false,
            ),
          );
          logger.i('Loaded existing seller preferences: $preferences');
        }
      },
    );
  }

  /// Resume at the first incomplete step based on saved data
  int _calculateCurrentStep(SellerPreferencesEntity preferences) {
    if (preferences.targetAudience != null)     return 4;
    if (preferences.bestOfferTime != null)      return 4;
    if (preferences.customerReachMethod != null) return 3;
    if (preferences.priceCategory != null)      return 2;
    return 1;
  }

  // ════════════════════════════════════════════════════════
  // STEP 1: PRICE CATEGORY  (budget | mid_range | premium)
  // ════════════════════════════════════════════════════════

  void selectPriceCategory(String value) {
    final hasChanges = value != _originalPriceCategory;
    _safeEmit(
      state.copyWith(
        priceCategory: value,
        isStep1Valid: true,
        hasChanges: hasChanges,
        successMessageKey: null,
      ),
    );
    logger.d('Price category selected: $value');
  }

  // ════════════════════════════════════════════════════════
  // STEP 2: CUSTOMER REACH METHOD  (physical_store | online_only)
  // ════════════════════════════════════════════════════════

  void selectCustomerReachMethod(String value) {
    final hasChanges = value != _originalCustomerReachMethod;
    _safeEmit(
      state.copyWith(
        customerReachMethod: value,
        isStep2Valid: true,
        hasChanges: hasChanges,
        successMessageKey: null,
      ),
    );
    logger.d('Customer reach method selected: $value');
  }

  // ════════════════════════════════════════════════════════
  // STEP 3: BEST OFFER TIME  (all_week | weekends_occasions | off_peak)
  // ════════════════════════════════════════════════════════

  void selectBestOfferTime(String value) {
    final hasChanges = value != _originalBestOfferTime;
    _safeEmit(
      state.copyWith(
        bestOfferTime: value,
        isStep3Valid: true,
        hasChanges: hasChanges,
        successMessageKey: null,
      ),
    );
    logger.d('Best offer time selected: $value');
  }

  // ════════════════════════════════════════════════════════
  // STEP 4: TARGET AUDIENCE  (youth | families | all)
  // ════════════════════════════════════════════════════════

  void selectTargetAudience(String value) {
    final hasChanges = value != _originalTargetAudience;
    _safeEmit(
      state.copyWith(
        targetAudience: value,
        isStep4Valid: true,
        hasChanges: hasChanges,
        successMessageKey: null,
      ),
    );
    logger.d('Target audience selected: $value');
  }

  // ════════════════════════════════════════════════════════
  // NAVIGATION CONTROL
  // ════════════════════════════════════════════════════════

  /// Clear any pending navigation signal (call after UI handles it)
  void clearNavigationSignal() {
    _safeEmit(state.copyWith(navigationSignal: SellerOnboardingNavigation.none));
  }

  /// Clear success message (call after UI shows it)
  void clearSuccessMessage() {
    _safeEmit(state.copyWith(successMessageKey: null));
  }

  /// Step 1 → Step 2
  Future<void> completePriceCategorySelection() async {
    if (!state.isStep1Valid) return;
    await saveProgress(silent: true);
    _safeEmit(
      state.copyWith(
        currentStep: 2,
        navigationSignal: SellerOnboardingNavigation.toCustomerReachMethod,
      ),
    );
    logger.i('Price category selected — navigating to Customer Reach Method');
  }

  /// Step 2 → Step 3
  Future<void> completeCustomerReachMethodSelection() async {
    if (!state.isStep2Valid) return;
    await saveProgress(silent: true);
    _safeEmit(
      state.copyWith(
        currentStep: 3,
        navigationSignal: SellerOnboardingNavigation.toBestOfferTime,
      ),
    );
    logger.i('Customer reach method selected — navigating to Best Offer Time');
  }

  /// Step 3 → Step 4
  Future<void> completeBestOfferTimeSelection() async {
    if (!state.isStep3Valid) return;
    await saveProgress(silent: true);
    _safeEmit(
      state.copyWith(
        currentStep: 4,
        navigationSignal: SellerOnboardingNavigation.toTargetAudience,
      ),
    );
    logger.i('Best offer time selected — navigating to Target Audience');
  }

  /// Go back to previous step
  void goToPreviousStep() {
    if (state.currentStep > 1) {
      _safeEmit(state.copyWith(currentStep: state.currentStep - 1));
      logger.i('Going back to step ${state.currentStep - 1}');
    }
  }

  // ════════════════════════════════════════════════════════
  // SAVE OPERATIONS
  // ════════════════════════════════════════════════════════

  /// Save current progress locally to Hive
  Future<void> saveProgress({bool silent = false}) async {
    _safeEmit(state.copyWith(isSaving: true, errorMessageKey: null));

    final changes = _detectChanges();
    final hasAnyChanges = changes.isNotEmpty;

    logger.d('Saving seller progress with changes: $changes (silent: $silent)');

    if (!hasAnyChanges && !silent) {
      _safeEmit(state.copyWith(isSaving: false, successMessageKey: null));
      return;
    }

    final result = await savePreferencesUseCase(
      priceCategory:       state.priceCategory,
      customerReachMethod: state.customerReachMethod,
      bestOfferTime:       state.bestOfferTime,
      targetAudience:      state.targetAudience,
    );

    result.fold(
      (failure) {
        logger.e('Failed to save seller progress: ${failure.message}');
        _safeEmit(
          state.copyWith(
            isSaving: false,
            errorMessageKey: failure.message,
            successMessageKey: null,
          ),
        );
      },
      (_) {
        // Update originals after successful save
        _originalPriceCategory      = state.priceCategory;
        _originalCustomerReachMethod = state.customerReachMethod;
        _originalBestOfferTime      = state.bestOfferTime;
        _originalTargetAudience     = state.targetAudience;

        final successKey = (silent || !hasAnyChanges)
            ? null
            : _generateSuccessMessageKey(changes);

        logger.i('Seller progress saved. Changes: $changes');
        _safeEmit(
          state.copyWith(
            isSaving: false,
            errorMessageKey: null,
            successMessageKey: successKey,
            hasChanges: false,
          ),
        );
      },
    );
  }

  /// Submit complete seller onboarding (all 4 steps).
  ///
  /// Flow:
  ///   1. Validate all 4 steps.
  ///   2. Save draft to Hive (local backup).
  ///   3. POST to /api/v1/on-boarding/seller.
  ///   4. On success: persist completed flag → navigate to loading.
  ///   5. On API failure: show retryable error, do NOT navigate.
  Future<void> submitOnboarding() async {
    if (!state.isStep1Valid) {
      _safeEmit(state.copyWith(errorMessageKey: 'error_seller_onboarding_step1_incomplete'));
      return;
    }
    if (!state.isStep2Valid) {
      _safeEmit(state.copyWith(errorMessageKey: 'error_seller_onboarding_step2_incomplete'));
      return;
    }
    if (!state.isStep3Valid) {
      _safeEmit(state.copyWith(errorMessageKey: 'error_seller_onboarding_step3_incomplete'));
      return;
    }
    if (!state.isStep4Valid) {
      _safeEmit(state.copyWith(errorMessageKey: 'error_seller_onboarding_step4_incomplete'));
      return;
    }

    logger.i('Submitting seller onboarding — Step 1: local save');
    _safeEmit(state.copyWith(isSaving: true, errorMessageKey: null, apiErrorKey: null));

    bool localSaveSuccess = false;
    bool shouldNavigate = false;

    try {
      // ── STEP 1: Save draft locally ───────────────────────────────────────
      final saveResult = await savePreferencesUseCase(
        priceCategory:       state.priceCategory,
        customerReachMethod: state.customerReachMethod,
        bestOfferTime:       state.bestOfferTime,
        targetAudience:      state.targetAudience,
      );

      if (saveResult.isLeft()) {
        final msg = saveResult.fold((f) => f.message, (_) => '');
        logger.e('Local save failed: $msg');
        _safeEmit(state.copyWith(isSaving: false, errorMessageKey: msg));
        return;
      }

      localSaveSuccess = true;

      // ── STEP 2: POST to backend (non-blocking) ───────────────────────────
      logger.i('Seller prefs saved locally — Step 2: API submission');
      _safeEmit(state.copyWith(isSaving: false, isSubmittingToApi: true));

      final apiResult = await submitOnboardingUseCase(
        userType: OnboardingSellerType.seller,
      );

      await apiResult.fold(
        (failure) async {
          logger.e('Seller API submission failed: ${failure.message}');
          // Server did not confirm with 200 OK — do NOT set the flag and do NOT
          // navigate.  The user stays on Step 4 and can retry.
          _safeEmit(state.copyWith(apiErrorKey: failure.message));
          shouldNavigate = false;
        },
        (_) async {
          // ── STEP 3: Persist account-level completed flag ─────────────────
          await authLocalDataSource.cacheOnboardingCompleted(true);

          _originalPriceCategory      = state.priceCategory;
          _originalCustomerReachMethod = state.customerReachMethod;
          _originalBestOfferTime      = state.bestOfferTime;
          _originalTargetAudience     = state.targetAudience;

          logger.i('Seller onboarding submitted successfully — showing success bottom sheet ✅');
          shouldNavigate = true;
        },
      );
    } catch (e) {
      logger.e('Unexpected error during seller onboarding submission: $e');
      _safeEmit(
        state.copyWith(
          errorMessageKey: 'error_unexpected',
          apiErrorKey: null,
        ),
      );
      shouldNavigate = false;
    } finally {
      // Always clear loading states
      _safeEmit(state.copyWith(isSaving: false, isSubmittingToApi: false));

      // Show success bottom sheet after a confirmed 200 OK
      if (shouldNavigate && localSaveSuccess) {
        _safeEmit(
          state.copyWith(
            isApiSubmitted: true,
            isCompleted: true,
            hasChanges: false,
            errorMessageKey: null,
            successMessageKey: 'success_seller_onboarding_completed',
            navigationSignal: SellerOnboardingNavigation.showSuccessBottomSheet,
          ),
        );
      }
    }
  }

  /// Skip current onboarding step and navigate to next step.
  ///
  /// - If on Step 1 (Price Category): Navigate to Step 2 (Customer Reach Method)
  /// - If on Step 2 (Customer Reach Method): Navigate to Step 3 (Best Offer Time)
  /// - If on Step 3 (Best Offer Time): Navigate to Step 4 (Target Audience)
  /// - If on Step 4 (Target Audience): Submit empty preferences to API
  ///   to mark onboarding as completed on the server
  Future<void> skipOnboarding() async {
    logger.i('Seller skipped onboarding at step ${state.currentStep}');

    if (state.currentStep == 1) {
      // Skip Step 1 → Go to Step 2
      _safeEmit(
        state.copyWith(
          currentStep: 2,
          navigationSignal: SellerOnboardingNavigation.toCustomerReachMethod,
        ),
      );
      logger.i('Skipped Step 1 → Navigate to Customer Reach Method');
    } else if (state.currentStep == 2) {
      // Skip Step 2 → Go to Step 3
      _safeEmit(
        state.copyWith(
          currentStep: 3,
          navigationSignal: SellerOnboardingNavigation.toBestOfferTime,
        ),
      );
      logger.i('Skipped Step 2 → Navigate to Best Offer Time');
    } else if (state.currentStep == 3) {
      // Skip Step 3 → Go to Step 4
      _safeEmit(
        state.copyWith(
          currentStep: 4,
          navigationSignal: SellerOnboardingNavigation.toTargetAudience,
        ),
      );
      logger.i('Skipped Step 3 → Navigate to Target Audience');
    } else if (state.currentStep == 4) {
      // Skip Step 4 → Submit empty preferences to API
      logger.i('Skipped Step 4 → Submitting empty preferences to API');
      await _submitEmptyPreferencesAndComplete();
    }
  }

  /// Submit empty preferences to API when seller skips all steps.
  /// This marks onboarding as completed on the server side.
  Future<void> _submitEmptyPreferencesAndComplete() async {
    _safeEmit(state.copyWith(isSaving: true, isSubmittingToApi: true));

    try {
      // Save empty preferences locally first (required by repository)
      logger.i('Saving empty seller preferences locally before API submission');
      final saveResult = await savePreferencesUseCase(
        priceCategory: state.priceCategory,
        customerReachMethod: state.customerReachMethod,
        bestOfferTime: state.bestOfferTime,
        targetAudience: state.targetAudience,
      );

      if (saveResult.isLeft()) {
        logger.e('Failed to save empty seller preferences locally');
        // Continue anyway to mark as completed
      }

      // Submit to API (will send whatever is saved locally, even if empty)
      final apiResult = await submitOnboardingUseCase(
        userType: OnboardingSellerType.seller,
      );

      await apiResult.fold(
        (failure) async {
          logger.e('Failed to submit skipped seller onboarding: ${failure.message}');
          // Even if API fails, mark as completed locally to prevent showing again
          await authLocalDataSource.cacheOnboardingCompleted(true);
          _navigateToHome();
        },
        (_) async {
          logger.i('✅ Empty seller onboarding submitted successfully');
          // Mark as completed locally
          await authLocalDataSource.cacheOnboardingCompleted(true);
          _navigateToHome();
        },
      );
    } catch (e) {
      logger.e('Error submitting empty seller onboarding: $e');
      // Mark as completed locally anyway to prevent showing again
      await authLocalDataSource.cacheOnboardingCompleted(true);
      _navigateToHome();
    } finally {
      _safeEmit(state.copyWith(isSaving: false, isSubmittingToApi: false));
    }
  }

  /// Navigate to home after skipping all steps
  void _navigateToHome() {
    _safeEmit(
      state.copyWith(
        isSkipped: true,
        isCompleted: true,
        navigationSignal: SellerOnboardingNavigation.toHome,
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════

  /// Check if current step is valid (can proceed to next)
  bool get canProceedFromCurrentStep {
    switch (state.currentStep) {
      case 1: return state.isStep1Valid;
      case 2: return state.isStep2Valid;
      case 3: return state.isStep3Valid;
      case 4: return state.isStep4Valid;
      default: return false;
    }
  }

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    int completed = 0;
    if (state.isStep1Valid) completed++;
    if (state.isStep2Valid) completed++;
    if (state.isStep3Valid) completed++;
    if (state.isStep4Valid) completed++;
    return completed / 4.0;
  }

  /// Reset all seller onboarding data
  void reset() {
    _originalPriceCategory      = null;
    _originalCustomerReachMethod = null;
    _originalBestOfferTime      = null;
    _originalTargetAudience     = null;
    _safeEmit(const SellerOnboardingFlowState());
    logger.i('Seller onboarding flow reset');
  }

  // ════════════════════════════════════════════════════════
  // CHANGE DETECTION HELPERS
  // ════════════════════════════════════════════════════════

  List<String> _detectChanges() {
    final changes = <String>[];
    if (state.priceCategory      != _originalPriceCategory)      changes.add('price_category');
    if (state.customerReachMethod != _originalCustomerReachMethod) changes.add('customer_reach_method');
    if (state.bestOfferTime       != _originalBestOfferTime)       changes.add('best_offer_time');
    if (state.targetAudience      != _originalTargetAudience)      changes.add('target_audience');
    return changes;
  }

  String _generateSuccessMessageKey(List<String> changes) {
    if (changes.length == 1) {
      switch (changes.first) {
        case 'price_category':       return 'success_seller_price_category_updated';
        case 'customer_reach_method': return 'success_seller_reach_method_updated';
        case 'best_offer_time':      return 'success_seller_offer_time_updated';
        case 'target_audience':      return 'success_seller_audience_updated';
      }
    }
    return 'success_seller_onboarding_all_updated';
  }
}
