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

/// Seller Target Audience Screen — Cubit Step 4 (targetAudience)
/// API values: youth | families | all
class SellerTargetAudienceScreen extends StatelessWidget {
  const SellerTargetAudienceScreen({super.key});

  static const _theme = CouponyThemeProvider(OnboardingUserType.seller);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SellerOnboardingFlowCubit>();

    return BlocListener<SellerOnboardingFlowCubit, SellerOnboardingFlowState>(
      listener: (context, state) {
        // Show error message if API submission fails
        if (state.apiErrorKey != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.apiErrorKey!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label:  'Retry',
                textColor: Colors.white,
                onPressed: () => cubit.submitOnboarding(),
              ),
            ),
          );
        }
        
        // Show general error message
        if (state.errorMessageKey != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessageKey!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<SellerOnboardingFlowCubit, SellerOnboardingFlowState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 24.h),

                  // Step Indicator (4 of 4)
                  OnboardingStepIndicator(
                    currentStep: state.currentStep,
                    totalSteps: 4,
                    theme: _theme,
                  ),

                  SizedBox(height: 32.h),

                  // Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      l10n.seller_target_audience_title,
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

                  // Target Audience Options
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      children: [
                        SelectionOptionCard(
                          title: l10n.seller_target_audience_youth,
                          subtitle: l10n.seller_target_audience_youth_subtitle,
                          icon: FontAwesomeIcons.champagneGlasses,
                          isSelected: state.targetAudience == 'youth',
                          onTap: () => cubit.selectTargetAudience('youth'),
                          theme: _theme,
                        ),
                        SizedBox(height: 12.h),
                        SelectionOptionCard(
                          title: l10n.seller_target_audience_families,
                          subtitle: l10n.seller_target_audience_families_subtitle,
                          icon: FontAwesomeIcons.house,
                          isSelected: state.targetAudience == 'families',
                          onTap: () => cubit.selectTargetAudience('families'),
                          theme: _theme,
                        ),
                        SizedBox(height: 12.h),
                        SelectionOptionCard(
                          title: l10n.seller_target_audience_everyone,
                          subtitle: l10n.seller_target_audience_everyone_subtitle,
                          icon: FontAwesomeIcons.userGroup,
                          isSelected: state.targetAudience == 'all',
                          onTap: () => cubit.selectTargetAudience('all'),
                          theme: _theme,
                        ),
                      ],
                    ),
                  ),

                  // Final step: "Finish" triggers submitOnboarding
                  OnboardingActionButtons(
                    nextLabel: l10n.finish,
                    skipLabel: l10n.skip,
                    isNextEnabled: state.isStep4Valid,
                    isLoading: state.isSubmittingToApi || state.isSaving,
                    onNext: () => cubit.submitOnboarding(),
                    onSkip: () => cubit.skipOnboarding(),
                    theme: _theme,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
