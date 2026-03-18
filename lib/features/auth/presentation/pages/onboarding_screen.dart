import 'package:coupon/config/routes/app_router.dart';
import 'package:coupon/core/theme/app_colors.dart';
import 'package:coupon/core/theme/app_text_styles.dart';
import 'package:coupon/core/widgets/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 100.h),
              // --- العنوان العلوي (Nunito Style) ---
              Text(
                "...خلّينا نعرفك أكتر\nوهنوفرلك أكتر ",
                textAlign: TextAlign.center,
                style: AppTextStyles.onboardingHeader,
              ),

              // --- الرسم التوضيحي (Illustration) ---
              Expanded(flex: 3, child: _buildCentralIllustration()),

              SizedBox(height: 24.h),

              // --- زر المتابعة ---
              _buildContinueButton(context), // Pass context here

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
    // Accept context as parameter
    return AppPrimaryButton(
      text: "متابعه",
      onPressed: () {
        context.go(AppRouter.onboardingPreferences);
      },
      icon: Icons.arrow_forward,
      iconPosition: AppButtonIconPosition.end, // RTL: icon on right
      // Maintain exact same UI as before
      size: AppButtonSize.medium,
      borderRadius: 16.r, // Same as original
      backgroundColor: AppColors.primary,
      textStyle: AppTextStyles.button.copyWith(fontSize: 18.sp),
    );
  }
}
