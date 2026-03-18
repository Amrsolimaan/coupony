import 'package:coupon/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Permission Icon Widget
/// Displays an icon/image for permission screens
/// Supports both asset images and custom icons
class PermissionIcon extends StatelessWidget {
  /// Asset path for the icon (e.g., 'assets/icons/location.png')
  final String? assetPath;

  /// Widget to display (alternative to assetPath)
  final Widget? icon;

  /// Icon size (defaults to PermissionConstants.iconSize)
  final double? size;

  /// Whether to show shadow under icon
  final bool showShadow;

  const PermissionIcon({
    super.key,
    this.assetPath,
    this.icon,
    this.size,
    this.showShadow = true,
  }) : assert(
         assetPath != null || icon != null,
         'Either assetPath or icon must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? 120.w;

    Widget iconWidget;

    if (icon != null) {
      iconWidget = icon!;
    } else {
      iconWidget = Image.asset(
        assetPath!,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      );
    }

    if (!showShadow) {
      return SizedBox(width: iconSize, height: iconSize, child: iconWidget);
    }

    // With shadow
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 50,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: iconWidget,
    );
  }
}
