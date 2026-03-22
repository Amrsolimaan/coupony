// lib/features/onboarding/presentation/pages/onboarding_shopping_style_screen.dart

import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/features/onboarding/presentation/widgets/onboarding_action_buttons.dart';
import 'package:coupony/features/onboarding/presentation/widgets/category_card.dart';
import 'package:coupony/features/onboarding/presentation/widgets/onboarding_submit_button.dart';
// import 'package:coupony/core/widgets/loading/loading.dart'; // Disabled - using inline button loading
import 'package:coupony/core/utils/message_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/shopping_style_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../cubit/onboarding_flow_cubit.dart';
import '../cubit/onboarding_flow_state.dart';

class OnboardingShoppingStyleScreen extends StatelessWidget {
  const OnboardingShoppingStyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OnboardingFlowCubit>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<OnboardingFlowCubit, OnboardingFlowState>(
          // Listener to monitor navigation signals
          listener: (context, state) {
            if (state.navigationSignal == OnboardingNavigation.toPermissions) {
              // Add delay here to allow user to read the "Saved" message
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) {
                  context.go(AppRouter.permissionSplash);
                  cubit.clearNavigationSignal();
                }
              });
            }

            if (state.navigationSignal == OnboardingNavigation.toLogin) {
              context.go(AppRouter.login);
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
            // Show error if save failed
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
                // الـ Indicator يظهر الخطوات 1 و 2 كمكتملة (Checked)
                const OnboardingStepIndicator(currentStep: 3, totalSteps: 3),
                SizedBox(height: 32.h),

                Text(
                  l10n?.shoppingStyleTitle ?? 'أسلوبك في الشوبينج؟',
                  style: AppTextStyles.h1.copyWith(fontSize: 22.sp),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 12.h,
                  ),
                  child: Text(
                    l10n?.shoppingStyleSubtitle ??
                        'قوليلنا بتشتري إزاي عشان ترشيحاتنا تبقى أدق',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: ShoppingStyleConstants.allShoppingStyles.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final styleKey =
                          ShoppingStyleConstants.allShoppingStyles[index];
                      final isSelected = state.shoppingStyles.contains(
                        styleKey,
                      );

                      return SelectionOptionCard(
                        title: _getLocalizedStyleName(styleKey, context),
                        isSelected: isSelected,
                        onTap: () => cubit.toggleShoppingStyle(styleKey),
                      );
                    },
                  ),
                ),

                // أزرار التحكم السفلية المشتركة
                OnboardingActionButtons(
                  nextLabel: l10n?.finish ?? 'إنهاء',
                  skipLabel: l10n?.skip ?? 'تخطي',
                  isNextEnabled: state.isStep3Valid,
                  isLoading: state.isSaving,
                  onNext: () => cubit.submitOnboarding(),
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

  String _getLocalizedStyleName(String key, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case ShoppingStyleConstants.online:
        return l10n?.shoppingOnline ?? 'بشتري Online أغلب الوقت';
      case ShoppingStyleConstants.basedOnOffer:
        return l10n?.shoppingBasedOnOffer ?? 'حسب العرض';
      case ShoppingStyleConstants.inStore:
        return l10n?.shoppingInStore ?? 'بفضّل المحلات (In-Store)';
      case ShoppingStyleConstants.bestDiscount:
        return l10n?.shoppingBestDiscount ?? 'بدور على أقوى خصم';
      default:
        return key;
    }
  }
}
