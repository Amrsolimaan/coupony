import 'package:coupony/features/onboarding/domain/entities/onboarding_user_type.dart';
import 'package:coupony/features/onboarding/presentation/providers/onboarding_theme_provider.dart';
import 'package:coupony/features/onboarding/presentation/widgets/category_card.dart';
import 'package:coupony/features/onboarding/presentation/widgets/onboarding_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../../core/widgets/buttons/app_button_variants.dart';
import '../../../../../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../../../../../core/widgets/buttons/app_primary_button.dart';
import  'package:coupony/core/extensions/snackbar_extension.dart';
import  'package:coupony/core/utils/message_formatter.dart';
/// Seller Target Audience Screen (UI ONLY - No Cubit/Repository)
/// Step 4 of 4 in Seller Onboarding Flow
class SellerTargetAudienceScreen extends StatefulWidget {
  const SellerTargetAudienceScreen({super.key});

  @override
  State<SellerTargetAudienceScreen> createState() =>
      _SellerTargetAudienceScreenState();
}

class _SellerTargetAudienceScreenState
    extends State<SellerTargetAudienceScreen> {
  String? _selectedAudience;

  bool get _isValid => _selectedAudience != null;

  void _onFinish() {
    if (_isValid) {
      // Complete onboarding - navigate to home or dashboard
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  void _onSkip() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = const OnboardingThemeProvider(OnboardingUserType.seller);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24.h),
            // Step Indicator (4 of 4)
            OnboardingStepIndicator(
              currentStep: 4,
              totalSteps: 4,
              theme: theme,
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
                    icon: Icons.celebration,
                    isSelected: _selectedAudience == 'youth',
                    onTap: () => setState(() => _selectedAudience = 'youth'),
                    theme: theme,
                  ),
                  SizedBox(height: 12.h),
                  SelectionOptionCard(
                    title: l10n.seller_target_audience_families,
                    subtitle: l10n.seller_target_audience_families_subtitle,
                    icon: Icons.home,
                    isSelected: _selectedAudience == 'families',
                    onTap: () => setState(() => _selectedAudience = 'families'),
                    theme: theme,
                  ),
                  SizedBox(height: 12.h),
                  SelectionOptionCard(
                    title: l10n.seller_target_audience_everyone,
                    subtitle: l10n.seller_target_audience_everyone_subtitle,
                    icon: Icons.groups,
                    isSelected: _selectedAudience == 'everyone',
                    onTap: () => setState(() => _selectedAudience = 'everyone'),
                    theme: theme,
                  ),
                ],
              ),
            ),

            // Action Buttons
            _buildActionButtons(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          Expanded(
            child: AppOutlinedButton(
              text: l10n.skip,
              onPressed: _onSkip,
              size: AppButtonSize.medium,
              borderRadius: 12.r,
              borderWidth: 1.5.w,
              borderColor: AppColors.primary_of_saller,
              textColor: AppColors.primary_of_saller,
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppPrimaryButton(
              text: l10n.next,
              onPressed: _isValid ? _onFinish : null,
              size: AppButtonSize.medium,
              borderRadius: 12.r,
              backgroundColor: AppColors.primary_of_saller,
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }
}
