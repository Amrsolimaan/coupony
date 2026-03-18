import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
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
            return _buildStepCircle(stepNumber);
          } else {
            final stepNumber = (index ~/ 2) + 1;
            return _buildConnectingLine(stepNumber);
          }
        }),
      ),
    );
  }

  Widget _buildStepCircle(int stepNumber) {
    final bool isActive = stepNumber == currentStep;
    final bool isCompleted = stepNumber < currentStep;

    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive || isCompleted ? AppColors.primary : Colors.white,
        border: Border.all(
          color: isActive || isCompleted
              ? AppColors.primary
              : AppColors.grey200,
          width: 2.w,
        ),
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 20.w,
              ) // إضافة علامة الصح للخطوات المكتملة كما في التصميم
            : Text(
                '$stepNumber',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.primary,
                  fontSize: 16.sp,
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
        color: isCompleted ? AppColors.primary : AppColors.grey200,
      ),
    );
  }
}
