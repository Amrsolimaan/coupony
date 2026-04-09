import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/extensions/snackbar_extension.dart';
import '../../cubit/change_password_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CHANGE PASSWORD PAGE
// ─────────────────────────────────────────────────────────────────────────────

class ChangePasswordPage extends HookWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final currentController = useTextEditingController();
    final newController = useTextEditingController();
    final confirmController = useTextEditingController();

    final showCurrent = useValueNotifier(false);
    final showNew = useValueNotifier(true);
    final showConfirm = useValueNotifier(false);

    // Reactive strength checks
    final newPassValue = useValueListenable(newController);
    final currentValue = useValueListenable(currentController);
    final confirmValue = useValueListenable(confirmController);

    final hasMinLength = newPassValue.text.length >= 8;
    final hasDigitOrSymbol = RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]')
        .hasMatch(newPassValue.text);
    final hasUpperAndLower = RegExp(r'[a-z]').hasMatch(newPassValue.text) &&
        RegExp(r'[A-Z]').hasMatch(newPassValue.text);

    // Button enabled when all fields filled and password passes basic checks
    final isEnabled = currentValue.text.isNotEmpty &&
        newPassValue.text.isNotEmpty &&
        confirmValue.text.isNotEmpty &&
        hasMinLength;

    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          context.showSuccessSnackBar(l10n.change_password_success);
          context.pop();
        }
        if (state is ChangePasswordError && !state.isCurrentPasswordWrong) {
          context.showErrorSnackBar(l10n.unexpectedError);
        }
      },
      builder: (context, state) {
        final isLoading = state is ChangePasswordLoading;
        final currentError = state is ChangePasswordError && state.isCurrentPasswordWrong;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(context, l10n),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Current Password ──────────────────────────────────────
                  _buildLabel(context, l10n.change_password_current_label),
                  SizedBox(height: 8.h),
                  _buildPasswordField(
                    context: context,
                    controller: currentController,
                    showPassword: showCurrent,
                    hasError: currentError,
                    textInputAction: TextInputAction.next,
                  ),
                  if (currentError) ...[
                    SizedBox(height: 6.h),
                    Text(
                      l10n.change_password_current_error,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  SizedBox(height: 20.h),

                  // ── New Password ──────────────────────────────────────────
                  _buildLabel(context, l10n.change_password_new_label),
                  SizedBox(height: 8.h),
                  _buildPasswordField(
                    context: context,
                    controller: newController,
                    showPassword: showNew,
                    textInputAction: TextInputAction.next,
                  ),

                  // ── Strength Indicators (show once user starts typing) ────
                  if (newPassValue.text.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    _buildStrengthBar(hasMinLength, hasDigitOrSymbol, hasUpperAndLower),
                    SizedBox(height: 10.h),
                    _buildStrengthIndicator(
                      context: context,
                      label: l10n.reset_password_strength_min_length,
                      passed: hasMinLength,
                    ),
                    SizedBox(height: 4.h),
                    _buildStrengthIndicator(
                      context: context,
                      label: l10n.reset_password_strength_digit,
                      passed: hasDigitOrSymbol,
                    ),
                    SizedBox(height: 4.h),
                    _buildStrengthIndicator(
                      context: context,
                      label: l10n.reset_password_strength_uppercase,
                      passed: hasUpperAndLower,
                    ),
                  ],
                  SizedBox(height: 20.h),

                  // ── Confirm Password ──────────────────────────────────────
                  _buildLabel(context, l10n.change_password_confirm_label),
                  SizedBox(height: 8.h),
                  _buildPasswordField(
                    context: context,
                    controller: confirmController,
                    showPassword: showConfirm,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 16.h),

                  // ── Forgot Password Link ──────────────────────────────────
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: GestureDetector(
                      onTap: () => context.push(AppRouter.forgotPassword),
                      child: Text(
                        l10n.change_password_forgot_link,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // ── Submit Button ─────────────────────────────────────────
                  _buildSubmitButton(
                    context: context,
                    l10n: l10n,
                    isEnabled: isEnabled && !isLoading,
                    isLoading: isLoading,
                    onTap: () {
                      context.read<ChangePasswordCubit>().changePassword(
                            currentPassword: currentController.text,
                            newPassword: newController.text,
                            confirmPassword: confirmController.text,
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        l10n.settings_change_password,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 20.w,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  // ── Label ──────────────────────────────────────────────────────────────────
  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: AppTextStyles.customStyle(
        context,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ── Password Field ─────────────────────────────────────────────────────────
  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required ValueNotifier<bool> showPassword,
    bool hasError = false,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: showPassword,
      builder: (context, visible, _) {
        return SizedBox(
          height: 56.h,
          child: TextField(
            controller: controller,
            obscureText: !visible,
            textInputAction: textInputAction,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '......',
              hintStyle: AppTextStyles.customStyle(
                context,
                fontSize: 18,
                color: AppColors.textDisabled,
                letterSpacing: 3,
              ),
              contentPadding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              isDense: true,
              filled: true,
              fillColor: AppColors.surface,
              suffixIcon: GestureDetector(
                onTap: () => showPassword.value = !visible,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 12.w),
                  child: Icon(
                    visible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    size: 22.w,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.divider,
                  width: 1.5.w,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.divider,
                  width: 1.5.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.primary,
                  width: 1.5.w,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Strength Bar ───────────────────────────────────────────────────────────
  Widget _buildStrengthBar(
      bool hasMinLength, bool hasDigitOrSymbol, bool hasUpperAndLower) {
    final passed =
        (hasMinLength ? 1 : 0) + (hasDigitOrSymbol ? 1 : 0) + (hasUpperAndLower ? 1 : 0);
    final color = passed == 3
        ? AppColors.success
        : passed >= 2
            ? AppColors.warning
            : AppColors.error;

    return Row(
      children: List.generate(3, (i) {
        final active = i < passed;
        return Expanded(
          child: Container(
            margin: EdgeInsetsDirectional.only(end: i < 2 ? 4.w : 0),
            height: 4.h,
            decoration: BoxDecoration(
              color: active ? color : AppColors.grey200,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }

  // ── Strength Indicator Row ─────────────────────────────────────────────────
  Widget _buildStrengthIndicator({
    required BuildContext context,
    required String label,
    required bool passed,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          passed ? Icons.check_rounded : Icons.circle,
          size: passed ? 16.w : 8.w,
          color: passed ? AppColors.primary : AppColors.textDisabled,
        ),
        if (!passed) SizedBox(width: 4.w),
        SizedBox(width: passed ? 6.w : 2.w),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 12,
              color: passed ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Submit Button ──────────────────────────────────────────────────────────
  Widget _buildSubmitButton({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool isEnabled,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primary : AppColors.textDisabled,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(14.r),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5.w,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.change_password_submit,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
