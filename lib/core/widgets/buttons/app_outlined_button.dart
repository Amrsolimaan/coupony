import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_button_variants.dart';

/// App Outlined Button
/// Unified outlined button used across the entire app
/// Maintains exact same UI as current buttons
class AppOutlinedButton extends StatelessWidget {
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

  /// Custom border radius
  final double? borderRadius;

  /// Border width
  final double? borderWidth;

  /// Whether button should take full width
  final bool isFullWidth;

  /// Custom text style (optional)
  final TextStyle? textStyle;

  /// Custom border color (optional, defaults to primary)
  final Color? borderColor;

  /// Custom text color (optional, defaults to primary)
  final Color? textColor;

  /// Custom padding (optional, overrides default)
  final EdgeInsetsGeometry? padding;

  const AppOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconPosition,
    this.borderRadius,
    this.borderWidth,
    this.isFullWidth = true,
    this.textStyle,
    this.borderColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveHeight = height ?? _getHeightForSize(size);
    final effectiveBorderRadius = borderRadius ?? _getBorderRadiusForSize(size);
    final effectiveBorderColor = borderColor ?? theme.primaryColor;
    final effectiveBorderWidth = borderWidth ?? _getBorderWidthForSize(size);
    final effectiveTextColor = textColor ?? theme.primaryColor;
    
    // If custom padding is provided, don't enforce height (let it be flexible)
    final shouldEnforceHeight = padding == null;

    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: effectiveTextColor,
        side: BorderSide(
          color: effectiveBorderColor,
          width: effectiveBorderWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w),
      ),
      child: _buildChild(effectiveTextColor),
    );

    // Wrap in SizedBox only if we should enforce height
    if (shouldEnforceHeight) {
      return SizedBox(
        width: isFullWidth ? (width ?? double.infinity) : width,
        height: effectiveHeight,
        child: button,
      );
    } else {
      // If custom padding, just constrain width
      return SizedBox(
        width: isFullWidth ? (width ?? double.infinity) : width,
        child: button,
      );
    }
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

  /// Get border radius based on size
  double _getBorderRadiusForSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return 10.r;
      case AppButtonSize.medium:
        return 12.r;
      case AppButtonSize.large:
        return 16.r;
    }
  }

  /// Get border width based on size
  double _getBorderWidthForSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return 1.w;
      case AppButtonSize.medium:
        return 2.w;
      case AppButtonSize.large:
        return 2.5.w;
    }
  }
}

