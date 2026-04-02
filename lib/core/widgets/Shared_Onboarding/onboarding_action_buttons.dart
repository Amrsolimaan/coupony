import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/buttons/buttons.dart';
import 'package:coupony/core/widgets/providers_theme/coupony_theme_provider.dart';

/// Role-aware Action Buttons
/// Dynamically changes color based on OnboardingUserType
class OnboardingActionButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String nextLabel;
  final String skipLabel;
  final bool isNextEnabled;
  final bool isLoading;
  final CouponyThemeProvider theme;

  const OnboardingActionButtons({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.nextLabel,
    required this.skipLabel,
    required this.theme,
    this.isNextEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          // Skip Button
          Expanded(
            child: AppOutlinedButton(
              text: skipLabel,
              onPressed: isLoading ? null : onSkip,
              isLoading: false,
              size: AppButtonSize.medium,
              borderRadius: 12.r,
              borderWidth: 1.5.w,
              borderColor: theme.primaryColor,
              textColor: theme.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
          SizedBox(width: 12.w),
          // Next Button
          Expanded(
            child: AppPrimaryButton(
              text: nextLabel,
              onPressed: (isNextEnabled && !isLoading) ? onNext : null,
              isLoading: isLoading,
              size: AppButtonSize.medium,
              borderRadius: 12.r,
              backgroundColor: theme.primaryColor,
              disabledBackgroundColor: AppColors.divider,
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }
}
