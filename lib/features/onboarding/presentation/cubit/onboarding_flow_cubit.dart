import 'package:coupony/core/storage/local_cache_service.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/constants/budget_constants.dart';
import '../../../../core/constants/shopping_style_constants.dart';
import '../../domain/use_cases/save_onboarding_preferences_use_case.dart';
import '../../domain/use_cases/get_onboarding_preferences_use_case.dart';
import '../../domain/use_cases/init_interest_scores_use_case.dart';
import '../../domain/entities/user_preferences_entity.dart';
import 'onboarding_flow_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Unified Cubit for managing all onboarding flow (Steps 1, 2, 3)
/// with Interest Tracking System
/// 
/// Note: This Cubit uses a custom state (OnboardingFlowState) instead of BaseState
/// because it manages complex UI flow with multiple steps, navigation signals,
/// and validation flags that don't fit the simple BaseState pattern.
class OnboardingFlowCubit extends Cubit<OnboardingFlowState> {
  final SaveOnboardingPreferencesUseCase savePreferencesUseCase;
  final GetOnboardingPreferencesUseCase getPreferencesUseCase;
  final InitInterestScoresUseCase initInterestScoresUseCase;
  final LocalCacheService cacheService;
  final Logger logger;

  // Store original preferences to detect changes
  List<String> _originalCategories = [];
  String? _originalBudgetPreference;
  double _originalBudgetSliderValue = 0.0;
  List<String> _originalShoppingStyles = [];

  OnboardingFlowCubit({
    required this.savePreferencesUseCase,
    required this.getPreferencesUseCase,
    required this.initInterestScoresUseCase,
    required this.cacheService,
    required this.logger,
  }) : super(const OnboardingFlowState()) {
    _loadExistingPreferences();
  }

  /// Safe emit wrapper to prevent emitting after cubit is closed
  void _safeEmit(OnboardingFlowState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  // ════════════════════════════════════════════════════════
  // INITIALIZATION
  // ════════════════════════════════════════════════════════

  /// Load existing preferences (if user returns to onboarding)
  Future<void> _loadExistingPreferences() async {
    final result = await getPreferencesUseCase();

    result.fold(
      (failure) {
        logger.d('No existing preferences found');
      },
      (preferences) {
        if (preferences != null) {
          // Calculate valid flags based on loaded data
          final isStep1Valid = preferences.selectedCategories.isNotEmpty;
          final isStep2Valid = preferences.budgetPreference != null;
          final isStep3Valid = preferences.shoppingStyles?.isNotEmpty ?? false;

          // Store original values for change detection
          _originalCategories = List<String>.from(
            preferences.selectedCategories,
          );
          _originalBudgetPreference = preferences.budgetPreference;
          _originalBudgetSliderValue =
              preferences.budgetSliderValue ??
              BudgetConstants.defaultSliderValue;
          _originalShoppingStyles = List<String>.from(
            preferences.shoppingStyles ?? [],
          );

          _safeEmit(
            state.copyWith(
              selectedCategories: preferences.selectedCategories,
              budgetPreference: preferences.budgetPreference,
              budgetSliderValue:
                  preferences.budgetSliderValue ??
                  BudgetConstants.defaultSliderValue,
              shoppingStyles: preferences.shoppingStyles ?? [],
              isStep1Valid: isStep1Valid,
              isStep2Valid: isStep2Valid,
              isStep3Valid: isStep3Valid,
              currentStep: _calculateCurrentStep(preferences),
              hasChanges: false, // No changes initially
            ),
          );
          logger.i('Loaded existing preferences: $preferences');
        }
      },
    );
  }

  /// Calculate which step user should be on based on saved data
  int _calculateCurrentStep(UserPreferencesEntity preferences) {
    if (preferences.shoppingStyles != null &&
        preferences.shoppingStyles!.isNotEmpty) {
      return 3;
    } else if (preferences.budgetPreference != null) {
      return 3;
    } else if (preferences.selectedCategories.isNotEmpty) {
      return 2;
    }
    return 1;
  }

  // ════════════════════════════════════════════════════════
  // STEP 1: CATEGORY SELECTION
  // ════════════════════════════════════════════════════════

  /// Toggle category selection
  void toggleCategory(String categoryKey) {
    // Validate category
    if (!CategoryConstants.isValidCategory(categoryKey)) {
      logger.w('Invalid category key: $categoryKey');
      return;
    }

    // Toggle selection
    final categories = List<String>.from(state.selectedCategories);
    if (categories.contains(categoryKey)) {
      categories.remove(categoryKey);
      logger.d('Removed category: $categoryKey');
    } else {
      categories.add(categoryKey);
      logger.d('Added category: $categoryKey');
    }

    // Emit new state with change tracking
    final hasChanges = _hasCategoryChanges(categories);
    _safeEmit(
      state.copyWith(
        selectedCategories: categories,
        isStep1Valid: categories.isNotEmpty,
        hasChanges: hasChanges,
        successMessageKey: null, // Clear previous message
      ),
    );
  }

  /// Clear all category selections
  void clearCategories() {
    _safeEmit(state.copyWith(selectedCategories: [], isStep1Valid: false));
    logger.i('Cleared all category selections');
  }

  // ════════════════════════════════════════════════════════
  // STEP 2: BUDGET SELECTION
  // ════════════════════════════════════════════════════════

  /// Update budget slider value
  void updateBudgetSlider(double value) {
    final budgetOption = BudgetConstants.getBudgetFromSlider(value);

    final hasChanges = _hasBudgetChanges(budgetOption, value);
    _safeEmit(
      state.copyWith(
        budgetSliderValue: value,
        budgetPreference: budgetOption,
        isStep2Valid: true,
        hasChanges: hasChanges,
        successMessageKey: null, // Clear previous message
      ),
    );

    logger.d('Budget slider updated: $value → $budgetOption');
  }

  /// Select budget option directly (when user taps radio button)
  void selectBudgetOption(String budgetOption) {
    if (!BudgetConstants.isValidBudget(budgetOption)) {
      logger.w('Invalid budget option: $budgetOption');
      return;
    }

    final sliderValue = BudgetConstants.getSliderFromBudget(budgetOption);

    final hasChanges = _hasBudgetChanges(budgetOption, sliderValue);
    _safeEmit(
      state.copyWith(
        budgetPreference: budgetOption,
        budgetSliderValue: sliderValue,
        isStep2Valid: true,
        hasChanges: hasChanges,
        successMessageKey: null, // Clear previous message
      ),
    );

    logger.d('Budget option selected: $budgetOption (slider: $sliderValue)');
  }

  // ════════════════════════════════════════════════════════
  // STEP 3: SHOPPING STYLE SELECTION
  // ════════════════════════════════════════════════════════

  /// Toggle shopping style selection
  void toggleShoppingStyle(String styleKey) {
    // Validate style
    if (!ShoppingStyleConstants.isValidStyle(styleKey)) {
      logger.w('Invalid shopping style key: $styleKey');
      return;
    }

    // Toggle selection
    final styles = List<String>.from(state.shoppingStyles);
    if (styles.contains(styleKey)) {
      styles.remove(styleKey);
      logger.d('Removed shopping style: $styleKey');
    } else {
      styles.add(styleKey);
      logger.d('Added shopping style: $styleKey');
    }

    // Emit new state with change tracking
    final hasChanges = _hasShoppingStyleChanges(styles);
    _safeEmit(
      state.copyWith(
        shoppingStyles: styles,
        isStep3Valid: styles.isNotEmpty,
        hasChanges: hasChanges,
        successMessageKey: null, // Clear previous message
      ),
    );
  }

  /// Clear all shopping style selections
  void clearShoppingStyles() {
    _safeEmit(state.copyWith(shoppingStyles: [], isStep3Valid: false));
    logger.i('Cleared all shopping style selections');
  }

  // ════════════════════════════════════════════════════════
  // NAVIGATION CONTROL
  // ════════════════════════════════════════════════════════

  /// Clear any pending navigation signal (call after UI handles it)
  void clearNavigationSignal() {
    _safeEmit(state.copyWith(navigationSignal: OnboardingNavigation.none));
  }

  /// Clear success message (call after UI shows it)
  void clearSuccessMessage() {
    _safeEmit(state.copyWith(successMessageKey: null));
  }

  /// Step 1 -> Step 2
  Future<void> completeCategorySelection() async {
    if (state.isStep1Valid) {
      // Save first to avoid race conditions with navigation signal
      await saveProgress(silent: true);

      _safeEmit(
        state.copyWith(
          currentStep: 2,
          navigationSignal: OnboardingNavigation.toBudget,
        ),
      );
      logger.i('Categories selected, signal to Budget');
    }
  }

  /// Step 2 -> Step 3
  Future<void> completeBudgetSelection() async {
    if (state.isStep2Valid) {
      await saveProgress(silent: true);

      _safeEmit(
        state.copyWith(
          currentStep: 3,
          navigationSignal: OnboardingNavigation.toShoppingStyle,
        ),
      );
      logger.i('Budget selected, signal to Shopping Style');
    }
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

  /// Save current progress locally
  Future<void> saveProgress({bool silent = false}) async {
    _safeEmit(state.copyWith(isSaving: true, errorMessageKey: null));

    final changes = _detectChanges();
    final hasAnyChanges = changes.isNotEmpty;

    logger.d('Saving progress with changes: $changes (silent: $silent)');

    // Check if really changed before emit saving state
    if (!hasAnyChanges && !silent) {
      _safeEmit(state.copyWith(isSaving: false, successMessageKey: null));
      return;
    }

    final result = await savePreferencesUseCase(
      selectedCategories: state.selectedCategories,
      budgetPreference: state.budgetPreference,
      budgetSliderValue: state.budgetSliderValue,
      shoppingStyles: state.shoppingStyles.isEmpty
          ? null
          : state.shoppingStyles,
    );

    result.fold(
      (failure) {
        logger.e('Failed to save progress: ${failure.message}');
        _safeEmit(
          state.copyWith(
            isSaving: false,
            errorMessageKey: failure.message,
            successMessageKey: null,
          ),
        );
      },
      (_) {
        // Update original values after successful save
        _originalCategories = List<String>.from(state.selectedCategories);
        _originalBudgetPreference = state.budgetPreference;
        _originalBudgetSliderValue = state.budgetSliderValue;
        _originalShoppingStyles = List<String>.from(state.shoppingStyles);

        // Generate success message only if not silent and has changes
        final successMessageKey = (silent || !hasAnyChanges)
            ? null
            : _generateSuccessMessageKey(changes, hasAnyChanges);

        logger.i('Progress saved successfully. Changes: $changes');
        _safeEmit(
          state.copyWith(
            isSaving: false,
            errorMessageKey: null,
            successMessageKey: successMessageKey,
            hasChanges: false, // Reset after save
          ),
        );
      },
    );
  }

  /// Submit complete onboarding (all steps completed)
  Future<void> submitOnboarding() async {
    // Validate all steps
    if (!state.isStep1Valid) {
      logger.w('Cannot submit: Step 1 incomplete');
      _safeEmit(state.copyWith(errorMessageKey: 'error_onboarding_step1_incomplete'));
      return;
    }

    if (!state.isStep2Valid) {
      logger.w('Cannot submit: Step 2 incomplete');
      _safeEmit(state.copyWith(errorMessageKey: 'error_onboarding_step2_incomplete'));
      return;
    }

    if (!state.isStep3Valid) {
      logger.w('Cannot submit: Step 3 incomplete');
      _safeEmit(
        state.copyWith(errorMessageKey: 'error_onboarding_step3_incomplete'),
      );
      return;
    }

    logger.i('Submitting complete onboarding...');

    _safeEmit(state.copyWith(isSaving: true, errorMessageKey: null));

    final result = await savePreferencesUseCase(
      selectedCategories: state.selectedCategories,
      budgetPreference: state.budgetPreference,
      budgetSliderValue: state.budgetSliderValue,
      shoppingStyles: state.shoppingStyles,
    );

    result.fold(
      (failure) {
        logger.e('Failed to submit onboarding: ${failure.message}');
        _safeEmit(state.copyWith(isSaving: false, errorMessageKey: failure.message));
      },
      (_) async {
        // Initialize category scores with +50 for each selected category
        await _initializeInterestScores();

        // Update original values after successful save
        _originalCategories = List<String>.from(state.selectedCategories);
        _originalBudgetPreference = state.budgetPreference;
        _originalBudgetSliderValue = state.budgetSliderValue;
        _originalShoppingStyles = List<String>.from(state.shoppingStyles);

        final changes = _detectChanges();
        final successMessageKey = _generateSuccessMessageKey(
          changes,
          changes.isNotEmpty,
        );

        logger.i('Onboarding submitted successfully');

        // 1. Emit success message first
        _safeEmit(
          state.copyWith(
            isSaving: false,
            isCompleted: true,
            errorMessageKey: null,
            successMessageKey: successMessageKey,
            hasChanges: false, // Reset after save
            navigationSignal: OnboardingNavigation.none,
          ),
        );

        // 2. Emit Navigation Signal to loading page (UI will handle delay)
        _safeEmit(
          state.copyWith(navigationSignal: OnboardingNavigation.toLoading),
        );
      },
    );
  }

  /// Initialize interest scores for selected categories
  Future<void> _initializeInterestScores() async {
    final result = await initInterestScoresUseCase(
      state.selectedCategories,
    );

    result.fold(
      (failure) {
        logger.e('Failed to initialize interest scores: ${failure.message}');
      },
      (_) {
        logger.i(
          '✅ Interest scores initialized for ${state.selectedCategories.length} categories',
        );
      },
    );
  }

  /// Skip onboarding
  void skipOnboarding() {
    logger.i('User skipped onboarding');
    _safeEmit(
      state.copyWith(
        isSkipped: true,
        navigationSignal: OnboardingNavigation.toLogin,
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // INTEREST TRACKING METHODS
  // ════════════════════════════════════════════════════════

  /// Update category score (called from product interactions)
  /// This is ASYNC and NON-BLOCKING
  Future<void> updateCategoryScore({
    required String categoryId,
    required int points,
  }) async {
    // Don't await - fire and forget to keep UI responsive
    cacheService
        .updateCategoryScore(categoryId: categoryId, points: points)
        .then((result) {
          result.fold(
            (failure) => logger.e('Failed to update score: ${failure.message}'),
            (_) => logger.d('✅ Updated score for $categoryId: +$points'),
          );
        });
  }

  /// Track product click (+1 point)
  Future<void> trackProductClick(String categoryId) async {
    await updateCategoryScore(
      categoryId: categoryId,
      points: LocalCacheService.productClickScore,
    );
  }

  /// Track view details (+5 points)
  Future<void> trackViewDetails(String categoryId) async {
    await updateCategoryScore(
      categoryId: categoryId,
      points: LocalCacheService.viewDetailsScore,
    );
  }

  /// Track add to favorites (+15 points)
  Future<void> trackAddToFavorites(String categoryId) async {
    await updateCategoryScore(
      categoryId: categoryId,
      points: LocalCacheService.addToFavoritesScore,
    );
  }

  /// Track conversion/use (+20 points)
  Future<void> trackConversion(String categoryId) async {
    await updateCategoryScore(
      categoryId: categoryId,
      points: LocalCacheService.conversionScore,
    );
  }

  /// Track seen product (for infinite novelty feed)
  Future<void> trackSeenProduct(String productId) async {
    cacheService.trackSeenProduct(productId).then((result) {
      result.fold(
        (failure) =>
            logger.e('Failed to track seen product: ${failure.message}'),
        (_) => logger.d('✅ Tracked seen product: $productId'),
      );
    });
  }

  /// Get top 3 interests for API requests
  Future<List<String>> getTopThreeInterests() async {
    final result = await cacheService.getTopThreeInterests();
    return result.fold((failure) {
      logger.e('Failed to get top interests: ${failure.message}');
      return [];
    }, (interests) => interests);
  }

  /// Get seen product IDs for API filtering
  Future<List<String>> getSeenProductIds() async {
    final result = await cacheService.getSeenProductIds();
    return result.fold((failure) {
      logger.e('Failed to get seen products: ${failure.message}');
      return [];
    }, (seenIds) => seenIds);
  }

  /// Clear seen products (reset novelty feed)
  Future<void> clearSeenProducts() async {
    final result = await cacheService.clearSeenProducts();
    result.fold(
      (failure) =>
          logger.e('Failed to clear seen products: ${failure.message}'),
      (_) => logger.i('✅ Cleared seen products list'),
    );
  }

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════

  /// Check if current step is valid (can proceed to next)
  bool get canProceedFromCurrentStep {
    switch (state.currentStep) {
      case 1:
        return state.isStep1Valid;
      case 2:
        return state.isStep2Valid;
      case 3:
        return state.isStep3Valid;
      default:
        return false;
    }
  }

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    int completed = 0;
    if (state.isStep1Valid) completed++;
    if (state.isStep2Valid) completed++;
    if (state.isStep3Valid) completed++;
    return completed / 3.0;
  }

  /// Reset all onboarding data
  void reset() {
    _originalCategories = [];
    _originalBudgetPreference = null;
    _originalBudgetSliderValue = BudgetConstants.defaultSliderValue;
    _originalShoppingStyles = [];
    _safeEmit(const OnboardingFlowState());
    logger.i('Onboarding flow reset');
  }

  // ════════════════════════════════════════════════════════
  // CHANGE DETECTION HELPERS
  // ════════════════════════════════════════════════════════

  /// Check if categories have changed
  bool _hasCategoryChanges(List<String> currentCategories) {
    if (currentCategories.length != _originalCategories.length) return true;
    final currentSet = currentCategories.toSet();
    final originalSet = _originalCategories.toSet();
    return !currentSet.containsAll(originalSet) ||
        !originalSet.containsAll(currentSet);
  }

  /// Check if budget has changed
  bool _hasBudgetChanges(String? currentBudget, double currentSlider) {
    return currentBudget != _originalBudgetPreference ||
        (currentSlider - _originalBudgetSliderValue).abs() > 0.01;
  }

  /// Check if shopping styles have changed
  bool _hasShoppingStyleChanges(List<String> currentStyles) {
    if (currentStyles.length != _originalShoppingStyles.length) return true;
    final currentSet = currentStyles.toSet();
    final originalSet = _originalShoppingStyles.toSet();
    return !currentSet.containsAll(originalSet) ||
        !originalSet.containsAll(currentSet);
  }

  /// Detect all changes made by user
  List<String> _detectChanges() {
    final changes = <String>[];

    if (_hasCategoryChanges(state.selectedCategories)) {
      changes.add('categories');
    }

    if (_hasBudgetChanges(state.budgetPreference, state.budgetSliderValue)) {
      changes.add('budget');
    }

    if (_hasShoppingStyleChanges(state.shoppingStyles)) {
      changes.add('shopping_styles');
    }

    return changes;
  }

  /// Generate user-friendly success message key
  String _generateSuccessMessageKey(List<String> changes, bool hasAnyChanges) {
    if (!hasAnyChanges) {
      return 'success_onboarding_preferences_saved';
    }

    // Single change - return specific key
    if (changes.length == 1) {
      if (changes.contains('categories')) {
        return 'success_onboarding_categories_updated';
      } else if (changes.contains('budget')) {
        return 'success_onboarding_budget_updated';
      } else if (changes.contains('shopping_styles')) {
        return 'success_onboarding_styles_updated';
      }
    }

    // Multiple changes - return generic "all updated" key
    return 'success_onboarding_all_updated';
  }
}
