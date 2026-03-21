import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_button_variants.dart';

/// App Text Button
/// Unified text button used across the entire app
/// Maintains exact same UI as current buttons
class AppTextButton extends StatelessWidget {
  /// Button text
  final String text;

  /// On pressed callback
  final VoidCallback? onPressed;

  /// Whether button is in loading state
  final bool isLoading;

  /// Custom width (defaults to full width)
  final double? width;

  /// Custom height (defaults based on size)
  final double? height;

  /// Button size variant
  final AppButtonSize size;

  /// Icon to display (optional)
  final IconData? icon;

  /// Icon position relative to text
  final AppButtonIconPosition? iconPosition;

  /// Whether button should take full width
  final bool isFullWidth;

  /// Custom text style (optional)
  final TextStyle? textStyle;

  /// Custom text color (optional, defaults to primary)
  final Color? textColor;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconPosition,
    this.isFullWidth = true,
    this.textStyle,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveHeight = height ?? _getHeightForSize(size);
    final effectiveTextColor = textColor ?? theme.primaryColor;

    return SizedBox(
      width: isFullWidth ? (width ?? double.infinity) : width,
      height: effectiveHeight,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: effectiveTextColor,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
        ),
        child: _buildChild(effectiveTextColor),
      ),
    );
  }

  /// Build button child (text, icon, or loading indicator)
  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return _buildLoadingIndicator(textColor);
    }

    if (icon != null) {
      return _buildWithIcon(textColor);
    }

    return _buildText(textColor);
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      width: 24.w,
      height: 24.w,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  /// Build text only
  Widget _buildText(Color textColor) {
    final effectiveTextStyle = textStyle ??
        TextStyle(
          fontSize: _getFontSizeForSize(size),
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
          color: textColor,
        );

    return Text(
      text,
      style: effectiveTextStyle,
    );
  }

  /// Build button with icon
  Widget _buildWithIcon(Color textColor) {
    final effectiveTextStyle = textStyle ??
        TextStyle(
          fontSize: _getFontSizeForSize(size),
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
          color: textColor,
        );

    final iconWidget = Icon(
      icon,
      color: textColor,
      size: 20.w,
    );

    final textWidget = Text(
      text,
      style: effectiveTextStyle,
    );

    final isRTL = iconPosition == AppButtonIconPosition.end ||
        (iconPosition == null && icon != null);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: isRTL
          ? [
              iconWidget,
              SizedBox(width: 12.w),
              textWidget,
            ]
          : [
              textWidget,
              SizedBox(width: 12.w),
              iconWidget,
            ],
    );
  }

  /// Get height based on size
  double _getHeightForSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return 40.h;
      case AppButtonSize.medium:
        return 56.h;
      case AppButtonSize.large:
        return 64.h;
    }
  }

  /// Get font size based on size
  double _getFontSizeForSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return 14.sp;
      case AppButtonSize.medium:
        return 16.sp;
      case AppButtonSize.large:
        return 18.sp;
    }
  }
}

