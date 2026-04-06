import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/category_card.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_action_buttons.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_submit_button.dart';
import 'package:coupony/core/widgets/providers_theme/coupony_theme_provider.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/entities/onboarding_user_type.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/cubit/onboarding_Seller_flow_cubit.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/cubit/onboarding_Seller_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Seller Delivery Method Screen — Cubit Step 2 (customerReachMethod)
/// API values: physical_store | online_only
class SellerDeliveryMethodScreen extends StatelessWidget {
  const SellerDeliveryMethodScreen({super.key});

  static const _theme = CouponyThemeProvider(OnboardingUserType.seller);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SellerOnboardingFlowCubit>();

    return BlocBuilder<SellerOnboardingFlowCubit, SellerOnboardingFlowState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 24.h),

                OnboardingStepIndicator(
                  currentStep: state.currentStep,
                  totalSteps: 4,
                  theme: _theme,
                ),

                SizedBox(height: 32.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    l10n.seller_delivery_method_title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _theme.primaryColor, // ✅ Seller Blue color
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    children: [
                      SelectionOptionCard(
                        title: l10n.seller_delivery_method_physical,
                        icon: Icons.storefront,
                        isSelected: state.customerReachMethod == 'physical_store',
                        onTap: () =>
                            cubit.selectCustomerReachMethod('physical_store'),
                        theme: _theme,
                      ),
                      SizedBox(height: 12.h),
                      SelectionOptionCard(
                        title: l10n.seller_delivery_method_online,
                        icon: Icons.phone_android,
                        isSelected: state.customerReachMethod == 'online_only',
                        onTap: () =>
                            cubit.selectCustomerReachMethod('online_only'),
                        theme: _theme,
                      ),
                    ],
                  ),
                ),

                OnboardingActionButtons(
                  nextLabel: l10n.next,
                  skipLabel: l10n.skip,
                  isNextEnabled: state.isStep2Valid,
                  isLoading: state.isSaving,
                  onNext: () => cubit.completeCustomerReachMethodSelection(),
                  onSkip: () => cubit.skipOnboarding(),
                  theme: _theme,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
