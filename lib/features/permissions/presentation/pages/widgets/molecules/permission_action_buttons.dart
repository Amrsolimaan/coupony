import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../atoms/permission_primary_button.dart';
import '../atoms/permission_text_button.dart';

/// Permission Action Buttons
/// Combines primary button + skip button
/// Reusable across all permission screens
class PermissionActionButtons extends StatelessWidget {
  /// Primary button text
  final String primaryText;

  /// Primary button callback
  final VoidCallback? onPrimaryPressed;

  /// Whether primary button is loading
  final bool isPrimaryLoading;

  /// Skip button text
  final String? skipText;

  /// Skip button callback
  final VoidCallback? onSkipPressed;

  /// Spacing between buttons
  final double? buttonSpacing;

  const PermissionActionButtons({
    super.key,
    required this.primaryText,
    this.onPrimaryPressed,
    this.isPrimaryLoading = false,
    this.skipText,
    this.onSkipPressed,
    this.buttonSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary Button
        PermissionPrimaryButton(
          text: primaryText,
          onPressed: onPrimaryPressed,
          isLoading: isPrimaryLoading,
        ),

        // Skip Button (if provided)
        if (skipText != null && onSkipPressed != null) ...[
          SizedBox(height: buttonSpacing ?? 12.h),
          PermissionTextButton(
            text: skipText!,
            onPressed: onSkipPressed,
          ),
        ],
      ],
    );
  }
}
