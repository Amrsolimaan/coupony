import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/buttons/buttons.dart';

class OnboardingActionButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String nextLabel;
  final String skipLabel;
  final bool isNextEnabled;
  final bool isLoading;

  const OnboardingActionButtons({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.nextLabel,
    required this.skipLabel,
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
              isLoading: false, // Skip button doesn't show loading
              // Maintain exact same UI as before (padding: vertical 8.h)
              size: AppButtonSize.medium,
              borderRadius: 12.r,
              borderWidth: 1.5.w, // Same as before
              borderColor: AppColors.primary,
              textColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 8.h), // Same as original
            ),
          ),
          SizedBox(width: 12.w),
          // Next Button
          Expanded(
            child: AppPrimaryButton(
              text: nextLabel,
              onPressed: (isNextEnabled && !isLoading) ? onNext : null,
              isLoading: isLoading,
              // Maintain exact same UI as before (padding: vertical 8.h)
              size: AppButtonSize.medium,
              borderRadius: 12.r,
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.divider,
              padding: EdgeInsets.symmetric(vertical: 8.h), // Same as original
            ),
          ),
        ],
      ),
    );
  }
}
