// lib/features/onboarding/presentation/pages/customer_onboarding/onboarding_shopping_style_screen.dart

import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/category_card.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_action_buttons.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_submit_button.dart';
import 'package:coupony/features/auth/presentation/widgets/auth_success_bottom_sheet.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/cubit/onboarding_flow_cubit.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/cubit/onboarding_flow_state.dart';
import 'package:coupony/core/utils/message_formatter.dart';
import 'package:coupony/core/extensions/snackbar_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:coupony/core/constants/shopping_style_constants.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/widgets/providers_theme/coupony_theme_provider.dart';

class OnboardingShoppingStyleScreen extends StatelessWidget {
  const OnboardingShoppingStyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<OnboardingFlowCubit>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<OnboardingFlowCubit, OnboardingFlowState>(
          listener: (context, state) {
            // ── Show Success Bottom Sheet ──────────────────────────────────────
            if (state.navigationSignal == OnboardingNavigation.toLoading) {
              final l10n = AppLocalizations.of(context)!;
              cubit.clearNavigationSignal();
              
              // ✅ Capture current theme color explicitly (should be Customer Purple)
              final theme = CouponyThemeProvider(state.userType);
              final primaryColor = theme.primaryColor;
              
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                isDismissible: false,
                enableDrag: false,
                builder: (context) => AuthSuccessBottomSheet(
                  title: l10n.customer_onboarding_success_title,
                  buttonText: l10n.continue_button,
                  primaryColor: primaryColor, // ✅ Explicit color injection
                  onContinue: () {
                    Navigator.of(context).pop();
                    context.go(AppRouter.home);
                  },
                ),
              );
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
                OnboardingStepIndicator(
                  currentStep: 3,
                  totalSteps: 3,
                  theme: theme,
                ),
                SizedBox(height: 32.h),

                Text(
                  l10n.shoppingStyleTitle,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 12.h,
                  ),
                  child: Text(
                    l10n.shoppingStyleSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
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
                        theme: theme,
                      );
                    },
                  ),
                ),

                OnboardingActionButtons(
                  nextLabel: l10n.finish,
                  skipLabel: l10n.skip,
                  isNextEnabled: state.isStep3Valid,
                  isLoading: state.isSaving,
                  onNext: () => cubit.submitOnboarding(),
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

  String _getLocalizedStyleName(String key, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case ShoppingStyleConstants.online:
        return l10n.shoppingOnline;
      case ShoppingStyleConstants.basedOnOffer:
        return l10n.shoppingBasedOnOffer;
      case ShoppingStyleConstants.inStore:
        return l10n.shoppingInStore;
      case ShoppingStyleConstants.bestDiscount:
        return l10n.shoppingBestDiscount;
      default:
        return key;
    }
  }
}
