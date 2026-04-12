import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/message_formatter.dart';
import '../../../../core/widgets/buttons/app_primary_button.dart';
import '../../../../core/extensions/snackbar_extension.dart';
import '../cubit/reset_password_cubit.dart';
import '../cubit/reset_password_state.dart';
import '../widgets/auth_success_bottom_sheet.dart';
import '../widgets/auth_text_field.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RESET PASSWORD SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ResetPasswordScreen extends HookWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ── Hook declarations ──────────────────────────────────────────────────
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    // ── Reactive derivations ───────────────────────────────────────────────
    final newPasswordValue = useValueListenable(newPasswordController);
    final confirmPasswordValue = useValueListenable(confirmPasswordController);

    // ── Real-time password strength update ─────────────────────────────────
    useEffect(() {
      context.read<ResetPasswordCubit>().updatePasswordStrength(
        newPasswordValue.text,
      );
      return null;
    }, [newPasswordValue.text]);

    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      // ── Listener: side-effects only (snackbars + navigation) ──────────────
      listener: (context, state) {
        if (state.errorMessage != null) {
          context.showErrorSnackBar(context.getLocalizedMessage(state.errorMessage));
        }
        if (state.successMessage != null && !state.isLoading) {
          _showSuccessModal(
            context,
            l10n,
            onContinue: () {
              context.go(AppRouter.login);
            },
          );
        }
      },
      // ── Builder: pure UI ───────────────────────────────────────────────────
      builder: (context, state) {
        final primaryColor = Theme.of(context).primaryColor;

        final hasContent =
            newPasswordValue.text.isNotEmpty &&
            confirmPasswordValue.text.isNotEmpty &&
            state.passwordStrength.isStrong;

        final passwordsMatch =
            newPasswordValue.text == confirmPasswordValue.text;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.h),

                    // ── Top bar: back button ────────────────────────────────
                    _TopBar(),
                    SizedBox(height: 28.h),

                    // ── Title ──────────────────────────────────────────────
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        l10n.reset_password_title,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.3,
                          letterSpacing: -1,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // ── Subtitle ───────────────────────────────────────────
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        l10n.reset_password_subtitle,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // ── New Password field ──────────────────────────────────
                    AuthTextField(
                      controller: newPasswordController,
                      hint: l10n.reset_password_new_password_hint,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 3.h),

                    // ── Password Strength Meter ─────────────────────────────
                    // FIX: removed the SizedBox(height: 8) before it and let
                    //      the meter handle its own top spacing so the progress
                    //      bar sits flush right under the field (matches design)
                    if (newPasswordValue.text.isNotEmpty)
                      _PasswordStrengthMeter(
                        strength: state.passwordStrength,
                        l10n: l10n,
                        primaryColor: primaryColor,
                      ),

                    SizedBox(height: 12.h),

                    // ── Confirm Password field ──────────────────────────────
                    AuthTextField(
                      controller: confirmPasswordController,
                      hint: l10n.reset_password_confirm_hint,
                      isPassword: true,
                      hasError:
                          confirmPasswordValue.text.isNotEmpty &&
                          !passwordsMatch,
                      textInputAction: TextInputAction.done,
                    ),

                    // ── Password mismatch error ─────────────────────────────
                    if (confirmPasswordValue.text.isNotEmpty &&
                        !passwordsMatch) ...[
                      SizedBox(height: 6.h),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l10n.reset_password_error_mismatch,
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 12.sp,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h),

                    // ── Reset Password button ───────────────────────────────
                    AppPrimaryButton(
                      text: l10n.reset_password_submit_button,
                      isLoading: state.isLoading,
                      onPressed:
                          hasContent && passwordsMatch && !state.isLoading
                          ? () => context
                                .read<ResetPasswordCubit>()
                                .resetPassword(
                                  email: email,
                                  token: token,
                                  password: newPasswordController.text,
                                  passwordConfirmation:
                                      confirmPasswordController.text,
                                )
                          : null,
                      height: 56.h,
                      backgroundColor: hasContent && passwordsMatch
                          ? primaryColor
                          : AppColors.textDisabled,
                      textStyle: AppTextStyles.customStyle(
                        context,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surface,
                      ),
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSuccessModal(
    BuildContext context,
    AppLocalizations l10n, {
    required VoidCallback onContinue,
  }) {
    // ✅ Capture current theme color explicitly
    final primaryColor = Theme.of(context).primaryColor;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => AuthSuccessBottomSheet(
        title: l10n.reset_password_success,
        buttonText: l10n.reset_password_continue_login,
        primaryColor: primaryColor, // ✅ Explicit color injection
        onContinue: onContinue,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    // FIX: Design shows the arrow on the END side in RTL (which is visually
    //      left on screen). AlignmentDirectional.centerEnd is correct for RTL
    //      and arrow_forward_ios_rounded automatically flips in RTL — ✅ keep as-is.
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => context.pop(),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 20.w,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PasswordStrengthMeter extends StatelessWidget {
  final PasswordStrength strength;
  final AppLocalizations l10n;
  final Color primaryColor;

  const _PasswordStrengthMeter({
    required this.strength,
    required this.l10n,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Progress Bar ────────────────────────────────────────────────────
        // FIX: sits directly under the field with no extra top gap
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
          child: SizedBox(
            height: 2.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.r),
              child: LinearProgressIndicator(
                value: strength.score / 4,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // ── Checkmarks ──────────────────────────────────────────────────────
        // Design shows 3 rows (not 4):
        //   • 8 أحرف على الأقل
        //   • رقم واحد على الأقل (0-9) أو رمز
        //   • الأحرف الصغيرة (a-z) والأحرف الكبيرة (A-Z)   ← uppercase+lowercase merged
        _StrengthCheckItem(
          label: l10n.reset_password_strength_min_length,
          isValid: strength.hasMinLength,
          primaryColor: primaryColor,
        ),
        SizedBox(height: 6.h),
        _StrengthCheckItem(
          label: l10n.reset_password_strength_digit,
          isValid: strength.hasDigit,
          primaryColor: primaryColor,
        ),
        SizedBox(height: 6.h),
        // FIX: uppercase & lowercase merged into one row (matches design)
        _StrengthCheckItem(
          label: l10n.reset_password_strength_uppercase,
          isValid: strength.hasUppercase && strength.hasLowercase,
          primaryColor: primaryColor,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StrengthCheckItem extends StatelessWidget {
  final String label;
  final bool isValid;
  final Color primaryColor;

  const _StrengthCheckItem({
    required this.label,
    required this.isValid,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      // FIX: RTL — icon on the LEFT visually = end of the Row in RTL
      //      Use mainAxisAlignment start so text takes remaining space naturally
      children: [
        // ── FIX: icon style matches design ────────────────────────────────
        //  valid   → orange ✓ checkmark (Icons.check — simple, no circle)
        //  invalid → grey bullet/dot   (Icons.circle, small, filled grey)
        if (isValid)
          Icon(
            Icons.check,
            size: 14.w,
            color: primaryColor,
          )
        else
          Icon(
            Icons.circle, // filled small dot
            size: 8.w, // FIX: much smaller — just a bullet point
            color: AppColors.textDisabled,
          ),

        SizedBox(width: 8.w),

        // ── Label ─────────────────────────────────────────────────────────
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 13.sp,
              color: isValid ? primaryColor : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
