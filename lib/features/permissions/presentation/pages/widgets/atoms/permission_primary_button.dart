import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/widgets/buttons/buttons.dart';

/// Permission Primary Button
/// Wrapper around AppPrimaryButton for backward compatibility
/// Maintains exact same API and UI
class PermissionPrimaryButton extends StatelessWidget {
  /// Button text
  final String text;

  /// On pressed callback
  final VoidCallback? onPressed;

  /// Whether button is in loading state
  final bool isLoading;

  /// Custom width (defaults to full width)
  final double? width;

  const PermissionPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      // Maintain exact same UI as before
      size: AppButtonSize.medium, // 56.h height, 16.sp font
      borderRadius: 12.r, // Same as before
    );
  }
}
