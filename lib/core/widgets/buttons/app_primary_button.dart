import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_button_variants.dart';

/// App Primary Button
/// Unified primary button used across the entire app
/// Maintains exact same UI as current buttons
class AppPrimaryButton extends StatelessWidget {
  /// Button text
  final String text;

  /// On pressed callback
  final VoidCallback? onPressed;

  /// Whether button is in loading state
  final bool isLoading;

  /// Custom width (defaults to full width)
  final double? width;

  /// Custom height (defaults based on size)
  /// If null, uses size-based height. Set to specific value to override.
  final double? height;
  
  /// Custom padding (optional, overrides default)
  final EdgeInsetsGeometry? padding;

  /// Button size variant
  final AppButtonSize size;

  /// Icon to display (optional)
  final IconData? icon;

  /// Icon position relative to text
  final AppButtonIconPosition? iconPosition;

  /// Custom border radius
  final double? borderRadius;

  /// Whether button should take full width
  final bool isFullWidth;

  /// Custom text style (optional)
  final TextStyle? textStyle;

  /// Custom background color (optional, defaults to primary)
  final Color? backgroundColor;

  /// Custom disabled background color (optional)
  final Color? disabledBackgroundColor;



  const AppPrimaryButton({
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
    this.isFullWidth = true,
    this.textStyle,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveHeight = height ?? _getHeightForSize(size);
    final effectiveBorderRadius = borderRadius ?? _getBorderRadiusForSize(size);
    final effectiveBackgroundColor = backgroundColor ?? theme.primaryColor;
    final effectiveDisabledColor = disabledBackgroundColor ??
        effectiveBackgroundColor.withValues(alpha: 0.6);
    
    // If custom padding is provided, don't enforce height (let it be flexible)
    final shouldEnforceHeight = padding == null;

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: effectiveDisabledColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
        elevation: 0,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w),
      ),
      child: _buildChild(),
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
  Widget _buildChild() {
    if (isLoading) {
      return _buildLoadingIndicator();
    }

    if (icon != null) {
      return _buildWithIcon();
    }

    return _buildText();
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 24.w,
      height: 24.w,
      child: const CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  /// Build text only
  Widget _buildText() {
    final effectiveTextStyle = textStyle ??
        TextStyle(
          fontSize: _getFontSizeForSize(size),
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        );

    return Text(
      text,
      style: effectiveTextStyle,
    );
  }

  /// Build button with icon
  Widget _buildWithIcon() {
    final effectiveTextStyle = textStyle ??
        TextStyle(
          fontSize: _getFontSizeForSize(size),
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        );

    final iconWidget = Icon(
      icon,
      color: Colors.white,
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
}

