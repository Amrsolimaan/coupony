import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/providers_theme/coupony_theme_provider.dart';

/// Role-aware Selection Option Card
/// Dynamically changes color based on OnboardingUserType
class SelectionOptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final CouponyThemeProvider theme;

  const SelectionOptionCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? theme.primaryColor : AppColors.grey200,
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryWithOpacity(0.1),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Radio Indicator
            _buildRadioIndicator(),
            const Spacer(),
            // Content
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Icon (If provided)
            if (icon != null) ...[
              SizedBox(width: 12.w),
              _buildIconContainer(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRadioIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20.w,
      height: 20.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? theme.primaryColor : AppColors.surface,
        border: Border.all(
          color: isSelected ? theme.primaryColor : AppColors.textDisabled,
          width: 2.w,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 8.w,
                height: 8.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.primaryWithOpacity(0.1)
            : AppColors.grey200,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(
        icon,
        size: 24.w,
        color: isSelected ? theme.primaryColor : AppColors.grey600,
      ),
    );
  }
}
