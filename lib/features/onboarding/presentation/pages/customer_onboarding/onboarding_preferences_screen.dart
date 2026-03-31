// lib/features/onboarding/presentation/pages/customer_onboarding/onboarding_preferences_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/constants/category_constants.dart';
import '../../../../../core/extensions/snackbar_extension.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/message_formatter.dart';
import '../../cubit/onboarding_flow_cubit.dart';
import '../../cubit/onboarding_flow_state.dart';
import '../../providers/onboarding_theme_provider.dart';
import '../../widgets/category_card.dart';
import '../../widgets/onboarding_action_buttons.dart';
import '../../widgets/onboarding_submit_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING CATEGORY SELECTION SCREEN (STEP 1/3)
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingCategorySelectionScreen extends StatelessWidget {
  const OnboardingCategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OnboardingCategorySelectionView();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY SELECTION VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingCategorySelectionView extends StatelessWidget {
  const _OnboardingCategorySelectionView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<OnboardingFlowCubit>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<OnboardingFlowCubit, OnboardingFlowState>(
          listener: (context, state) {
            if (state.navigationSignal == OnboardingNavigation.toBudget) {
              context.push(AppRouter.onboardingBudget);
              cubit.clearNavigationSignal();
            }

            if (state.navigationSignal == OnboardingNavigation.toLogin) {
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
            final theme = OnboardingThemeProvider(state.userType);

            return Column(
              children: [
                SizedBox(height: 24.h),

                // ── Step Indicator ──────────────────────────────────────────
                OnboardingStepIndicator(
                  currentStep: 1,
                  totalSteps: 3,
                  theme: theme,
                ),

                SizedBox(height: 32.h),

                // ── Title & Subtitle ────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.onboardingTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        l10n.onboardingSubtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // ── Category List ───────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: CategoryConstants.allCategories.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final categoryKey =
                          CategoryConstants.allCategories[index];
                      final isSelected =
                          state.selectedCategories.contains(categoryKey);

                      return SelectionOptionCard(
                        title: CategoryConstants.getCategoryName(
                          categoryKey,
                          context,
                        ),
                        icon: CategoryConstants.getIcon(categoryKey),
                        isSelected: isSelected,
                        onTap: () => cubit.toggleCategory(categoryKey),
                        theme: theme,
                      );
                    },
                  ),
                ),

                // ── Action Buttons ──────────────────────────────────────────
                OnboardingActionButtons(
                  nextLabel: l10n.next,
                  skipLabel: l10n.skip,
                  isNextEnabled: state.isStep1Valid,
                  isLoading: state.isSaving,
                  onNext: () => cubit.completeCategorySelection(),
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
}