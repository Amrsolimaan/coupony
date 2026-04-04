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

/// Seller Best Offer Time Screen — Cubit Step 3 (bestOfferTime)
/// API values: all_week | weekends_occasions | off_peak
class SellerStoreInfoScreen extends StatelessWidget {
  const SellerStoreInfoScreen({super.key});

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
                    l10n.seller_best_offer_time_title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    children: [
                      SelectionOptionCard(
                        title: l10n.seller_best_offer_time_all_week,
                        subtitle: l10n.seller_best_offer_time_all_week_subtitle,
                        icon: Icons.calendar_month,
                        isSelected: state.bestOfferTime == 'all_week',
                        onTap: () => cubit.selectBestOfferTime('all_week'),
                        theme: _theme,
                      ),
                      SizedBox(height: 12.h),
                      SelectionOptionCard(
                        title: l10n.seller_best_offer_time_weekends,
                        subtitle: l10n.seller_best_offer_time_weekends_subtitle,
                        icon: Icons.celebration,
                        isSelected: state.bestOfferTime == 'weekends_occasions',
                        onTap: () => cubit.selectBestOfferTime('weekends_occasions'),
                        theme: _theme,
                      ),
                      SizedBox(height: 12.h),
                      SelectionOptionCard(
                        title: l10n.seller_best_offer_time_off_peak,
                        subtitle: l10n.seller_best_offer_time_off_peak_subtitle,
                        icon: Icons.trending_down,
                        isSelected: state.bestOfferTime == 'off_peak',
                        onTap: () => cubit.selectBestOfferTime('off_peak'),
                        theme: _theme,
                      ),
                    ],
                  ),
                ),

                OnboardingActionButtons(
                  nextLabel: l10n.next,
                  skipLabel: l10n.skip,
                  isNextEnabled: state.isStep3Valid,
                  isLoading: state.isSaving,
                  onNext: () => cubit.completeBestOfferTimeSelection(),
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
