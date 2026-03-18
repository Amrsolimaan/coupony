// lib/features/onboarding/presentation/pages/onboarding_budget_screen.dart

import 'package:coupon/features/onboarding/presentation/widgets/onboarding_action_buttons.dart';
import 'package:coupon/features/onboarding/presentation/widgets/category_card.dart';
import 'package:coupon/features/onboarding/presentation/widgets/onboarding_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/budget_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/l10n/app_localizations.dart';

import '../cubit/onboarding_flow_cubit.dart';
import '../cubit/onboarding_flow_state.dart';

class OnboardingBudgetScreen extends StatelessWidget {
  const OnboardingBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OnboardingFlowCubit>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<OnboardingFlowCubit, OnboardingFlowState>(
          // نراقب إشارات الملاحة (Navigation Signals)
          listener: (context, state) {
            if (state.navigationSignal == OnboardingNavigation.toShoppingStyle) {
              context.push(AppRouter.onboardingShoppingStyle);
              cubit.clearNavigationSignal();
            }

            if (state.navigationSignal == OnboardingNavigation.toLogin) {
              context.go(AppRouter.login);
              cubit.clearNavigationSignal();
            }

            // Show success message when saved (only if not null)
            if (state.saveSuccessMessage != null && state.saveSuccessMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any existing snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.saveSuccessMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: 100.h,
                    left: 20.w,
                    right: 20.w,
                  ),
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              );
              // Clear message immediately after showing
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<OnboardingFlowCubit>().clearSuccessMessage();
                }
              });
            }
            // Show error message if save failed
            if (state.saveError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.saveError!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                SizedBox(height: 24.h),
                // الخطوة الثانية: تعرض الخطوة 1 كمكتملة
                const OnboardingStepIndicator(currentStep: 2, totalSteps: 3),
                SizedBox(height: 32.h),

                // ... (rest of the build logic)
                // النصوص التعريفية
                Text(
                  l10n?.budgetTitle ?? 'حدد ميزانيتك',
                  style: AppTextStyles.h1.copyWith(fontSize: 22.sp),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 12.h,
                  ),
                  child: Text(
                    l10n?.budgetSubtitle ??
                        'هنستخدم اختيارك عشان نجهزلك تجربة تناسب احتياجاتك من أول لحظة',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // الـ Slider المخصص مع الـ Tooltip
                _buildBudgetSlider(state, cubit),

                SizedBox(height: 32.h),

                // خيارات الميزانية (SelectionOptionCard المشترك)
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
                        title: _getLocalizedBudgetName(budgetKey, context),
                        isSelected: isSelected,
                        onTap: () => cubit.selectBudgetOption(budgetKey),
                      );
                    },
                  ),
                ),

                // الأزرار السفلية المشتركة
                OnboardingActionButtons(
                  nextLabel: l10n?.next ?? 'التالي',
                  skipLabel: l10n?.skip ?? 'تخطي',
                  isNextEnabled: state.isStep2Valid,
                  onNext: () => cubit.completeBudgetSelection(),
                  onSkip: () => cubit.skipOnboarding(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // بناء السلايدر مع ملصق النسبة المئوية (Tooltip) العلوي
  Widget _buildBudgetSlider(
    OnboardingFlowState state,
    OnboardingFlowCubit cubit,
  ) {
    final int percentage = (state.budgetSliderValue * 100).toInt();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // الـ Tooltip المتحرك
          _buildSliderLabel(state.budgetSliderValue, percentage),

          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6.h,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
              thumbColor: Colors.white,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 10.r,
                elevation: 4,
              ),
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: state.budgetSliderValue,
              onChanged: (val) => cubit.updateBudgetSlider(val),
              min: 0.0,
              max: 1.0,
            ),
          ),

          // نصوص النسبة السفلية
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '50%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '100%',
                  style: AppTextStyles.caption.copyWith(
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

  // المربع البرتقالي الصغير فوق السلايدر
  Widget _buildSliderLabel(double value, int percentage) {
    return Align(
      alignment: Alignment(value * 2 - 1, 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          '$percentage%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getLocalizedBudgetName(String key, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case BudgetConstants.low:
        return l10n?.budgetLow ?? 'ميزانية قليلة';
      case BudgetConstants.medium:
        return l10n?.budgetMedium ?? 'ميزانية متوسطة';
      case BudgetConstants.bestValue:
        return l10n?.budgetBestValue ?? 'أفضل قيمة';
      default:
        return key;
    }
  }
}
