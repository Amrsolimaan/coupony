// lib/features/onboarding/presentation/pages/customer_onboarding/onboarding_budget_screen.dart

import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/constants/budget_constants.dart';
import 'package:coupony/core/extensions/snackbar_extension.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/utils/message_formatter.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/category_card.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_action_buttons.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_submit_button.dart';
import 'package:coupony/core/widgets/providers_theme/coupony_theme_provider.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/cubit/onboarding_flow_cubit.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/cubit/onboarding_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING BUDGET SCREEN (STEP 2/3)
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingBudgetScreen extends StatelessWidget {
  const OnboardingBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<OnboardingFlowCubit>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<OnboardingFlowCubit, OnboardingFlowState>(
          listener: (context, state) {
            if (state.navigationSignal ==
                OnboardingNavigation.toShoppingStyle) {
              context.push(AppRouter.onboardingShoppingStyle);
              cubit.clearNavigationSignal();
            }

            if (state.navigationSignal == OnboardingNavigation.toHome) {
              context.go(AppRouter.home);
              cubit.clearNavigationSignal();
            }

            if (state.successMessageKey != null &&
                state.successMessageKey!.isNotEmpty) {
              context.showSuccessSnackBar(
                context.getLocalizedMessage(state.successMessageKey),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<OnboardingFlowCubit>().clearSuccessMessage();
                }
              });
            }

            if (state.errorMessageKey != null) {
              context.showErrorSnackBar(
                context.getLocalizedMessage(state.errorMessageKey),
              );
            }
          },
          builder: (context, state) {
            final theme = CouponyThemeProvider(state.userType);

            return Column(
              children: [
                SizedBox(height: 24.h),

                // ── Step Indicator ──────────────────────────────────────────
                OnboardingStepIndicator(
                  currentStep: 2,
                  totalSteps: 3,
                  theme: theme,
                ),
                SizedBox(height: 32.h),

                // ── Title ───────────────────────────────────────────────────
                Text(
                  l10n.budgetTitle,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // ── Subtitle ────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 12.h,
                  ),
                  child: Text(
                    l10n.budgetSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Budget Slider ───────────────────────────────────────────
                _BudgetSlider(state: state, cubit: cubit, theme: theme),

                SizedBox(height: 32.h),

                // ── Budget Options List ─────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: BudgetConstants.allBudgetOptions.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final budgetKey = BudgetConstants.allBudgetOptions[index];
                      final isSelected = state.budgetPreference == budgetKey;

                      return SelectionOptionCard(
                        title: _getLocalizedBudgetName(budgetKey, l10n),
                        isSelected: isSelected,
                        onTap: () => cubit.selectBudgetOption(budgetKey),
                        theme: theme,
                      );
                    },
                  ),
                ),

                // ── Action Buttons ──────────────────────────────────────────
                OnboardingActionButtons(
                  nextLabel: l10n.next,
                  skipLabel: l10n.skip,
                  isNextEnabled: state.isStep2Valid,
                  isLoading: state.isSaving,
                  onNext: () => cubit.completeBudgetSelection(),
                  onSkip: () => cubit.skipOnboarding(),
                  theme: theme,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Get localized budget name from ARB keys
  String _getLocalizedBudgetName(String key, AppLocalizations l10n) {
    switch (key) {
      case BudgetConstants.low:
        return l10n.budgetLow;
      case BudgetConstants.medium:
        return l10n.budgetMedium;
      case BudgetConstants.bestValue:
        return l10n.budgetBestValue;
      default:
        return key;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BUDGET SLIDER WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetSlider extends StatelessWidget {
  final OnboardingFlowState state;
  final OnboardingFlowCubit cubit;
  final CouponyThemeProvider theme;

  const _BudgetSlider({
    required this.state,
    required this.cubit,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final int percentage = (state.budgetSliderValue * 100).toInt();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // ── Slider Label (Percentage Indicator) ─────────────────────────
          _SliderLabel(
            value: state.budgetSliderValue,
            percentage: percentage,
            theme: theme,
          ),

          // ── Slider ──────────────────────────────────────────────────────
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6.h,
              activeTrackColor: theme.primaryColor,
              inactiveTrackColor: theme.primaryWithOpacity(0.2),
              thumbColor: AppColors.surface,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 10.r,
                elevation: 4,
              ),
              overlayColor: theme.primaryWithOpacity(0.1),
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: state.budgetSliderValue,
              onChanged: (val) => cubit.updateBudgetSlider(val),
              min: 0.0,
              max: 1.0,
            ),
          ),

          // ── Slider Scale Labels (0%, 50%, 100%) ─────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0%',
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '50%',
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '100%',
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SLIDER LABEL (PERCENTAGE BADGE)
// ─────────────────────────────────────────────────────────────────────────────

class _SliderLabel extends StatelessWidget {
  final double value;
  final int percentage;
  final CouponyThemeProvider theme;

  const _SliderLabel({
    required this.value,
    required this.percentage,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(value * 2 - 1, 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          '$percentage%',
          style: AppTextStyles.customStyle(
            context,
            fontSize: 12,
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
