import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/widgets/buttons/buttons.dart';

/// Permission Text Button
/// Wrapper around AppOutlinedButton for backward compatibility
/// Maintains exact same API and UI
class PermissionTextButton extends StatelessWidget {
  /// Button text
  final String text;

  /// On pressed callback
  final VoidCallback? onPressed;

  /// Custom width (defaults to full width)
  final double? width;

  const PermissionTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppOutlinedButton(
      text: text,
      onPressed: onPressed,
      width: width,
      // Maintain exact same UI as before
      size: AppButtonSize.medium, // 56.h height, 16.sp font
      borderRadius: 12.r, // Same as before
      borderWidth: 2.w, // Same as before
      borderColor: theme.primaryColor,
      textColor: theme.primaryColor,
    );
  }
}
