import 'package:coupony/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../molecules/permission_header.dart';
import '../molecules/permission_action_buttons.dart';

/// Permission Content Card
/// Smart organism that combines header + action buttons
/// Adapts to different content types (intro, error, etc.)
class PermissionContentCard extends StatelessWidget {
  /// Icon asset path
  final String? iconAssetPath;

  /// Custom icon widget
  final Widget? iconWidget;

  /// Icon size
  final double? iconSize;

  /// Card title
  final String title;

  /// Card subtitle/description
  final String subtitle;

  /// Primary button text
  final String primaryButtonText;

  /// Primary button callback
  final VoidCallback? onPrimaryPressed;

  /// Whether primary button is loading
  final bool isPrimaryLoading;

  /// Skip button text (optional)
  final String? skipButtonText;

  /// Skip button callback (optional)
  final VoidCallback? onSkipPressed;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom padding
  final EdgeInsetsGeometry? padding;

  /// Whether to show card shadow
  final bool showShadow;

  const PermissionContentCard({
    super.key,
    this.iconAssetPath,
    this.iconWidget,
    this.iconSize,
    required this.title,
    required this.subtitle,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    this.isPrimaryLoading = false,
    this.skipButtonText,
    this.onSkipPressed,
    this.backgroundColor,
    this.padding,
    this.showShadow = false,
  }) : assert(
          iconAssetPath != null || iconWidget != null,
          'Either iconAssetPath or iconWidget must be provided',
        );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500.w),
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: padding ?? EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 20,
                    offset: Offset(0, 10.h),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (Icon + Title + Subtitle)
            PermissionHeader(
              iconAssetPath: iconAssetPath,
              iconWidget: iconWidget,
              iconSize: iconSize,
              title: title,
              subtitle: subtitle,
            ),

            SizedBox(height: 40.h),

            // Action Buttons
            PermissionActionButtons(
              primaryText: primaryButtonText,
              onPrimaryPressed: onPrimaryPressed,
              isPrimaryLoading: isPrimaryLoading,
              skipText: skipButtonText,
              onSkipPressed: onSkipPressed,
            ),
          ],
        ),
      ),
    );
  }
}
