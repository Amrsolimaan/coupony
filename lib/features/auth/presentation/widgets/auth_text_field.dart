import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'role_animation_wrapper.dart';

/// Reusable auth text field.
/// For password fields, pass [isPassword: true] — visibility is managed
/// internally via a [ValueNotifier<bool>].
/// For email/phone fields, pass [forceLeftToRight: true] to use smart LTR alignment.
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final bool hasError;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final Color? overrideColor;
  final bool forceLeftToRight; // ✅ Smart LTR for email/phone (empty: follows locale, has content: left)

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.hasError = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.overrideColor,
    this.forceLeftToRight = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPassword) {
      return _PasswordField(
        controller: controller,
        hint: hint,
        hasError: hasError,
        textInputAction: textInputAction,
        focusNode: focusNode,
        overrideColor: overrideColor,
      );
    }

    // ✅ For email/phone fields with smart LTR behavior
    if (forceLeftToRight) {
      return _SmartLTRField(
        controller: controller,
        hint: hint,
        hasError: hasError,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        focusNode: focusNode,
        overrideColor: overrideColor,
      );
    }

    // If overrideColor is provided, use it directly without animation
    if (overrideColor != null) {
      return _buildField(
        context: context,
        controller: controller,
        hint: hint,
        hasError: hasError,
        obscure: false,
        suffixIcon: null,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        primaryColor: overrideColor!,
        focusNode: focusNode,
        isPassword: false,
        hasContent: false,
        forceLeftToRight: false,
      );
    }

    return AnimatedPrimaryColor(
      builder: (context, primaryColor) {
        return _buildField(
          context: context,
          controller: controller,
          hint: hint,
          hasError: hasError,
          obscure: false,
          suffixIcon: null,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          primaryColor: primaryColor,
          focusNode: focusNode,
          isPassword: false,
          hasContent: false,
          forceLeftToRight: false,
        );
      },
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool hasError;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final Color? overrideColor;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.hasError,
    required this.textInputAction,
    this.focusNode,
    this.overrideColor,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  final ValueNotifier<bool> _obscure = ValueNotifier(true);
  final ValueNotifier<bool> _hasContent = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update textDirection dynamically
    widget.controller.addListener(_onTextChanged);
    _hasContent.value = widget.controller.text.isNotEmpty;
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasContent.value != hasText) {
      _hasContent.value = hasText;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _obscure.dispose();
    _hasContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If overrideColor is provided, use it directly without animation
    if (widget.overrideColor != null) {
      return ValueListenableBuilder<bool>(
        valueListenable: _obscure,
        builder: (context, obscure, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: _hasContent,
            builder: (context, hasContent, _) {
              return _buildField(
                context: context,
                controller: widget.controller,
                hint: widget.hint,
                hasError: widget.hasError,
                obscure: obscure,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: widget.textInputAction,
                primaryColor: widget.overrideColor!,
                focusNode: widget.focusNode,
                isPassword: true,
                hasContent: hasContent,
                suffixIcon: GestureDetector(
                  onTap: () => _obscure.value = !obscure,
                  child: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20.w,
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return AnimatedPrimaryColor(
      builder: (context, primaryColor) {
        return ValueListenableBuilder<bool>(
          valueListenable: _obscure,
          builder: (context, obscure, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _hasContent,
              builder: (context, hasContent, _) {
                return _buildField(
                  context: context,
                  controller: widget.controller,
                  hint: widget.hint,
                  hasError: widget.hasError,
                  obscure: obscure,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: widget.textInputAction,
                  primaryColor: primaryColor,
                  focusNode: widget.focusNode,
                  isPassword: true,
                  hasContent: hasContent,
                  suffixIcon: GestureDetector(
                    onTap: () => _obscure.value = !obscure,
                    child: Icon(
                      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20.w,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMART LTR FIELD (for Email/Phone)
// Same behavior as password: empty follows locale, has content aligns left
// ─────────────────────────────────────────────────────────────────────────────

class _SmartLTRField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool hasError;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final Color? overrideColor;

  const _SmartLTRField({
    required this.controller,
    required this.hint,
    required this.hasError,
    required this.keyboardType,
    required this.textInputAction,
    this.focusNode,
    this.overrideColor,
  });

  @override
  State<_SmartLTRField> createState() => _SmartLTRFieldState();
}

class _SmartLTRFieldState extends State<_SmartLTRField> {
  final ValueNotifier<bool> _hasContent = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasContent.value = widget.controller.text.isNotEmpty;
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasContent.value != hasText) {
      _hasContent.value = hasText;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _hasContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If overrideColor is provided, use it directly without animation
    if (widget.overrideColor != null) {
      return ValueListenableBuilder<bool>(
        valueListenable: _hasContent,
        builder: (context, hasContent, _) {
          return _buildField(
            context: context,
            controller: widget.controller,
            hint: widget.hint,
            hasError: widget.hasError,
            obscure: false,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            primaryColor: widget.overrideColor!,
            focusNode: widget.focusNode,
            isPassword: false,
            hasContent: hasContent,
            forceLeftToRight: true,
            suffixIcon: null,
          );
        },
      );
    }

    return AnimatedPrimaryColor(
      builder: (context, primaryColor) {
        return ValueListenableBuilder<bool>(
          valueListenable: _hasContent,
          builder: (context, hasContent, _) {
            return _buildField(
              context: context,
              controller: widget.controller,
              hint: widget.hint,
              hasError: widget.hasError,
              obscure: false,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              primaryColor: primaryColor,
              focusNode: widget.focusNode,
              isPassword: false,
              hasContent: hasContent,
              forceLeftToRight: true,
              suffixIcon: null,
            );
          },
        );
      },
    );
  }
}

Widget _buildField({
  required BuildContext context,
  required TextEditingController controller,
  required String hint,
  required bool hasError,
  required bool obscure,
  required Widget? suffixIcon,
  required TextInputType keyboardType,
  required TextInputAction textInputAction,
  required Color primaryColor,
  FocusNode? focusNode,
  bool isPassword = false,
  bool hasContent = false,
  bool forceLeftToRight = false, // ✅ New parameter
}) {
  final borderColor        = hasError ? AppColors.error : AppColors.divider;
  final focusedBorderColor = hasError ? AppColors.error : primaryColor;

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: BorderSide(color: borderColor, width: 1.5.w),
  );
  final focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: BorderSide(color: focusedBorderColor, width: 1.5.w),
  );

  // expands: true يملا الـ SizedBox بالكامل — لكن مش متوافق مع obscureText
  // فالـ password field بتستخدم vertical padding بدلاً منه
  final bool useExpands = !obscure;

  // ✅ Text direction logic:
  // 1. Password/Email fields (forceLeftToRight): Always LTR
  // 2. Other fields: Follow locale direction
  final TextDirection? textDirection = (isPassword || forceLeftToRight) 
      ? TextDirection.ltr 
      : null;
  
  // ✅ Smart text alignment:
  // For password/email fields with forceLeftToRight:
  // - Empty: cursor follows locale (right for Arabic, left for English)
  // - Has content: always left (because content is LTR)
  final TextAlign textAlign;
  if (isPassword || forceLeftToRight) {
    if (hasContent) {
      textAlign = TextAlign.left;
    } else {
      final isRTL = Directionality.of(context) == TextDirection.rtl;
      textAlign = isRTL ? TextAlign.right : TextAlign.left;
    }
  } else {
    textAlign = TextAlign.start;
  }

  return SizedBox(
    height: 56.r,
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textDirection: textDirection,
      textAlign: textAlign,
      maxLines: useExpands ? null : 1,
      minLines: useExpands ? null : null,
      expands: useExpands,
      textAlignVertical: TextAlignVertical.center,
      style: AppTextStyles.customStyle(
        context,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: obscure ? 2.0 : 0,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.customStyle(
          context,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDisabled,
          letterSpacing: 0,
        ),
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: 16.w,
          vertical: useExpands ? 0 : 18.r,
        ),
        isDense: true,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: EdgeInsetsDirectional.only(end: 12.w),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: BoxConstraints(minWidth: 30.w, minHeight: 30.h),
        filled: true,
        fillColor: AppColors.surface,
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        errorBorder: border,
        focusedErrorBorder: focusedBorder,
      ),
    ),
  );
}