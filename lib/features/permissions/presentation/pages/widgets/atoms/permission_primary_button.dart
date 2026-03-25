import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/buttons/buttons.dart';

/// Permission Primary Button
/// Wrapper around AppPrimaryButton for backward compatibility
/// Maintains exact same API and UI
class PermissionPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;

  const PermissionPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      height: height,
      isFullWidth: isFullWidth,
      backgroundColor: backgroundColor,
      textStyle: textColor != null
          ? AppTextStyles.customStyle(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor!,
              fontFamily: AppTextStyles.fontFamily,
            )
          : null,
      size: AppButtonSize.medium,
      borderRadius: 12.r,
    );
  }
}
