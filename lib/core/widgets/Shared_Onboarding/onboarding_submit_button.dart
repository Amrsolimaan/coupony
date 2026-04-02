import 'package:coupony/core/widgets/providers_theme/coupony_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Role-aware Step Indicator
/// Dynamically changes color based on OnboardingUserType
class OnboardingStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final CouponyThemeProvider theme;

  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isEven) {
            final stepNumber = (index ~/ 2) + 1;
            return _buildStepCircle(context, stepNumber);
          } else {
            final stepNumber = (index ~/ 2) + 1;
            return _buildConnectingLine(stepNumber);
          }
        }),
      ),
    );
  }

  Widget _buildStepCircle(BuildContext context, int stepNumber) {
    final bool isActive = stepNumber == currentStep;
    final bool isCompleted = stepNumber < currentStep;

    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive || isCompleted ? theme.primaryColor : AppColors.surface,
        border: Border.all(
          color: isActive || isCompleted
              ? theme.primaryColor
              : AppColors.grey200,
          width: 2.w,
        ),
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check,
                color: AppColors.surface,
                size: 20.w,
              )
            : Text(
                '$stepNumber',
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 16,
                  color: isActive ? AppColors.surface : theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildConnectingLine(int beforeStep) {
    final bool isCompleted = beforeStep < currentStep;
    return Expanded(
      child: Container(
        height: 2.h,
        color: isCompleted ? theme.primaryColor : AppColors.grey200,
      ),
    );
  }
}
