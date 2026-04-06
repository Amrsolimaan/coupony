import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Seller Onboarding Start Screen - Welcome/Intro page before the 4 steps
/// This is the first screen sellers see after successful registration
class SellerOnboardingStartScreen extends StatelessWidget {
  const SellerOnboardingStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 100.h),
              
              // Title
              Text(
                l10n.seller_onboarding_start_title,
                textAlign: TextAlign.center,
                style: (isArabic 
                  ? AppTextStyles.onboardingHeader
                  : AppTextStyles.onboardingHeaderEnglish).copyWith(
                    color: AppColors.primaryOfSeller, // ✅ Seller Blue color
                  ),
              ),

              SizedBox(height: 16.h),

              // Subtitle
              Text(
                l10n.seller_onboarding_start_subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),

              // Illustration
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.asset(
                    'assets/images/seller_onboarding_start.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Continue Button
              AppPrimaryButton(
                text: l10n.seller_onboarding_start_button,
                onPressed: () {
                  // Navigate to the main seller onboarding flow (4 steps)
                  context.go(AppRouter.sellerOnboardingFlow);
                },
                icon: Icons.arrow_forward,
                iconPosition: AppButtonIconPosition.end,
                size: AppButtonSize.medium,
                borderRadius: 16.r,
                backgroundColor: Theme.of(context).primaryColor, // Seller Blue
                textStyle: AppTextStyles.customStyle(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.surface,
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
