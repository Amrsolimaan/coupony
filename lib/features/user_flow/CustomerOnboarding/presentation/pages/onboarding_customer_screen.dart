import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OnboardingCustomerScreen extends StatelessWidget {
  const OnboardingCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 100.h),
              // Title using localization with language-specific styling
              Text(
                AppLocalizations.of(context)!.customerOnboardingTitle,
                textAlign: TextAlign.center,
                style: isArabic 
                  ? AppTextStyles.onboardingHeader
                  : AppTextStyles.onboardingHeaderEnglish,
              ),

              // --- الرسم التوضيحي (Illustration) ---
              Expanded(flex: 3, child: _buildCentralIllustration()),

              SizedBox(height: 24.h),

              // --- زر المتابعة ---
              _buildContinueButton(context),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCentralIllustration() {
    return Center(
      child: Image.asset(
        'assets/images/onboarding_hero.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return AppPrimaryButton(
      text: AppLocalizations.of(context)!.customerOnboardingSubTitle,
      onPressed: () {
        context.go(AppRouter.onboardingPreferences);
      },
      icon: Icons.arrow_forward,
      iconPosition: AppButtonIconPosition.end, // RTL: icon on right
      size: AppButtonSize.medium,
      borderRadius: 16.r,
      backgroundColor: AppColors.primary,
      textStyle: AppTextStyles.customStyle(
        context,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.surface,
      ),
    );
  }
}
