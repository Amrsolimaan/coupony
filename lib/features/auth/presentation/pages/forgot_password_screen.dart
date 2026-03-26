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
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../widgets/auth_text_field.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FORGOT PASSWORD SCREEN  — Step 1 of the password-reset chain
//
// Flow:
//   User enters email → ForgotPasswordCubit.sendResetCode
//   Success           → push OtpScreen(mode: forgotPassword)
// ─────────────────────────────────────────────────────────────────────────────

class ForgotPasswordScreen extends HookWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n            = AppLocalizations.of(context)!;
    final emailController = useTextEditingController();
    final emailValue      = useValueListenable(emailController);
    final hasContent      = emailValue.text.trim().isNotEmpty;

    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      // ── Listener: side-effects only ────────────────────────────────────────
      listener: (context, state) {
        if (state.errorMessage != null) {
          context.showErrorSnackBar(context.getLocalizedMessage(state.errorMessage));
        }

        if (state.navSignal == ForgotPasswordNavigation.toResetPassword) {
          context.read<ForgotPasswordCubit>().clearNavSignal();
          // Push OtpScreen in forgotPassword mode — email carried via route extra
          context.push(
            AppRouter.otpVerification,
            extra: <String, String>{
              'email': state.submittedEmail ?? emailController.text.trim(),
              'mode':  'forgotPassword',
            },
          );
        }
      },
      // ── Builder: pure UI ───────────────────────────────────────────────────
      builder: (context, state) {
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

                    // ── Back button ────────────────────────────────────────
                    _TopBar(),
                    SizedBox(height: 28.h),

                    // ── Title ──────────────────────────────────────────────
                    Text(
                      l10n.forgot_password_title,
                      style: TextStyle(
                        fontFamily: AppTextStyles.Main_Font_arabic,
                        fontSize:   26.sp,
                        fontWeight: FontWeight.w700,
                        color:      AppColors.textPrimary,
                        height:     1.3,
                        letterSpacing: -1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),

                    // ── Subtitle ───────────────────────────────────────────
                    Text(
                      l10n.forgot_password_subtitle,
                      style: TextStyle(
                        fontFamily: AppTextStyles.Main_Font_arabic,
                        fontSize:   14.sp,
                        color:      AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        height:     1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),

                    // ── Email field ────────────────────────────────────────
                    AuthTextField(
                      controller:       emailController,
                      hint:             l10n.forgot_password_email_hint,
                      keyboardType:     TextInputType.emailAddress,
                      textInputAction:  TextInputAction.done,
                    ),
                    SizedBox(height: 24.h),

                    // ── Send button ────────────────────────────────────────
                    AppPrimaryButton(
                      text:      l10n.forgot_password_send_button,
                      isLoading: state.isLoading,
                      onPressed: hasContent && !state.isLoading
                          ? () => context
                              .read<ForgotPasswordCubit>()
                              .sendResetCode(emailController.text.trim())
                          : null,
                      height:          56.h,
                      backgroundColor: hasContent
                          ? AppColors.primary
                          : AppColors.textDisabled,
                      textStyle: TextStyle(
                        fontFamily: AppTextStyles.Main_Font_arabic,
                        fontSize:   16.sp,
                        fontWeight: FontWeight.w600,
                        color:      AppColors.surface,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Back to login link ─────────────────────────────────
                    _BackToLoginRow(l10n: l10n),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Material(
        color:        Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => context.pop(),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size:  20.w,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BackToLoginRow extends StatelessWidget {
  final AppLocalizations l10n;
  const _BackToLoginRow({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Text(
          l10n.forgot_password_back_to_login,
          style: TextStyle(
            fontFamily: AppTextStyles.Main_Font_arabic,
            fontSize:   14.sp,
            color:      AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
