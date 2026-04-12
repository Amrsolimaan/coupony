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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Seller Price Range Screen — Cubit Step 1 (priceCategory)
/// API values: budget | mid_range | premium
/// Note: 'all' is NOT accepted by the backend API
class SellerPriceRangeScreen extends StatelessWidget {
  const SellerPriceRangeScreen({super.key});

  // Seller Blue theme — kept as const to avoid rebuilding on each frame
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
                    l10n.seller_price_range_title,
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
                        title: l10n.seller_price_range_economic,
                        subtitle: l10n.seller_price_range_economic_subtitle,
                        icon: FontAwesomeIcons.percent,
                        isSelected: state.priceCategory == 'budget',
                        onTap: () => cubit.selectPriceCategory('budget'),
                        theme: _theme,
                      ),
                      SizedBox(height: 12.h),
                      SelectionOptionCard(
                        title: l10n.seller_price_range_medium,
                        subtitle: l10n.seller_price_range_medium_subtitle,
                        icon: FontAwesomeIcons.scaleBalanced,
                        isSelected: state.priceCategory == 'mid_range',
                        onTap: () => cubit.selectPriceCategory('mid_range'),
                        theme: _theme,
                      ),
                      SizedBox(height: 12.h),
                      SelectionOptionCard(
                        title: l10n.seller_price_range_premium,
                        subtitle: l10n.seller_price_range_premium_subtitle,
                        icon: FontAwesomeIcons.crown,
                        isSelected: state.priceCategory == 'premium',
                        onTap: () => cubit.selectPriceCategory('premium'),
                        theme: _theme,
                      ),
                      SizedBox(height: 12.h),
                      // Note: 'all' is not accepted by the API
                      // Only budget, mid_range, and premium are valid values
                      // SelectionOptionCard(
                      //   title: l10n.seller_price_range_all_levels,
                      //   subtitle: l10n.seller_price_range_all_levels_subtitle,
                      //   icon: Icons.layers,
                      //   isSelected: state.priceCategory == 'all',
                      //   onTap: () => cubit.selectPriceCategory('all'),
                      //   theme: _theme,
                      // ),
                    ],
                  ),
                ),

                OnboardingActionButtons(
                  nextLabel: l10n.next,
                  skipLabel: l10n.skip,
                  isNextEnabled: state.isStep1Valid,
                  isLoading: state.isSaving,
                  onNext: () => cubit.completePriceCategorySelection(),
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
