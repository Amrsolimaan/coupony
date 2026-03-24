import 'package:coupony/features/onboarding/presentation/widgets/onboarding_action_buttons.dart';
import 'package:coupony/features/onboarding/presentation/widgets/category_card.dart';
import 'package:coupony/features/onboarding/presentation/widgets/onboarding_submit_button.dart';
// import 'package:coupony/core/widgets/loading/loading.dart'; // Disabled - using inline button loading
import 'package:coupony/core/utils/message_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/l10n/app_localizations.dart';

import '../cubit/onboarding_flow_cubit.dart';
import '../cubit/onboarding_flow_state.dart';

class OnboardingCategorySelectionScreen extends StatelessWidget {
  const OnboardingCategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الـ Provider موجود بالفعل في الـ Router أو يتم حقنه هنا
    return const OnboardingCategorySelectionView();
  }
}

class OnboardingCategorySelectionView extends StatelessWidget {
  const OnboardingCategorySelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OnboardingFlowCubit>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<OnboardingFlowCubit, OnboardingFlowState>(
          // نراقب إشارات الملاحة والرسائل
          listener: (context, state) {
            // Navigation signals
            if (state.navigationSignal == OnboardingNavigation.toBudget) {
              context.push(AppRouter.onboardingBudget);
              cubit.clearNavigationSignal();
            }

            if (state.navigationSignal == OnboardingNavigation.toLogin) {
              context.go(AppRouter.home);
              cubit.clearNavigationSignal();
            }

            // Show success message when saved (only if not null)
            if (state.successMessageKey != null && state.successMessageKey!.isNotEmpty) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any existing snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.getLocalizedMessage(state.successMessageKey),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsetsDirectional.only(
                    bottom: 100.h,
                    start: 20.w,
                    end: 20.w,
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
            if (state.errorMessageKey != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.getLocalizedMessage(state.errorMessageKey)),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            // Full-screen loader disabled - using inline button loading instead
            // return LoadingOverlay(
            //   isLoading: state.isSaving,
            //   message: 'Saving preferences...',
            //   icon: LoadingIcons.saving,
            //   child: Column(
            return Column(
              children: [
                SizedBox(height: 24.h),

                // استخدام المكون المشترك للتقدم (Step 1)
                const OnboardingStepIndicator(currentStep: 1, totalSteps: 3),

                SizedBox(height: 32.h),

                // ... (نفس النصوص السابقة)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n?.onboardingTitle ?? 'إيه العروض اللي تهمّك؟',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        l10n?.onboardingSubtitle ??
                            'اختار المجالات اللي تبحث عنها عشان نرشحلك عروض مناسبة ليك',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // قائمة التصنيفات باستخدام SelectionOptionCard العام
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: CategoryConstants.allCategories.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final categoryKey =
                          CategoryConstants.allCategories[index];
                      final isSelected = state.selectedCategories.contains(
                        categoryKey,
                      );

                      return SelectionOptionCard(
                        title: CategoryConstants.getCategoryName(
                          categoryKey,
                          context,
                        ),
                        icon: CategoryConstants.getIcon(
                          categoryKey,
                        ), // نمرر الأيقونة هنا فقط
                        isSelected: isSelected,
                        onTap: () => cubit.toggleCategory(categoryKey),
                      );
                    },
                  ),
                ),

                // استخدام مكون الأزرار المشترك لتوحيد الستايل والمسافات
                OnboardingActionButtons(
                  nextLabel: l10n?.next ?? 'التالي',
                  skipLabel: l10n?.skip ?? 'تخطي',
                  isNextEnabled: state.isStep1Valid,
                  isLoading: state.isSaving,
                  onNext: () => cubit.completeCategorySelection(),
                  onSkip: () => cubit.skipOnboarding(),
                ),
              ],
            // ), // Closing for LoadingOverlay - commented out
            );
          },
        ),
      ),
    );
  }
}
