import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../atoms/permission_icon.dart';

/// Permission Header
/// Combines icon + title + subtitle
/// Reusable across all permission screens
class PermissionHeader extends StatelessWidget {
  /// Icon asset path
  final String? iconAssetPath;

  /// Custom icon widget
  final Widget? iconWidget;

  /// Icon size
  final double? iconSize;

  /// Title text
  final String title;

  /// Subtitle text
  final String subtitle;

  /// Custom title style
  final TextStyle? titleStyle;

  /// Custom subtitle style
  final TextStyle? subtitleStyle;

  /// Spacing between icon and title
  final double? iconTitleSpacing;

  /// Spacing between title and subtitle
  final double? titleSubtitleSpacing;

  const PermissionHeader({
    super.key,
    this.iconAssetPath,
    this.iconWidget,
    this.iconSize,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.iconTitleSpacing,
    this.titleSubtitleSpacing,
  }) : assert(
          iconAssetPath != null || iconWidget != null,
          'Either iconAssetPath or iconWidget must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        PermissionIcon(
          assetPath: iconAssetPath,
          icon: iconWidget,
          size: iconSize,
        ),

        SizedBox(height: iconTitleSpacing ?? 32.h),

        // Title
        Text(
          title,
          style: titleStyle ??
              TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                fontFamily: 'Cairo',
              ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: titleSubtitleSpacing ?? 16.h),

        // Subtitle
        Text(
          subtitle,
          style: subtitleStyle ??
              TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontFamily: 'Cairo',
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
