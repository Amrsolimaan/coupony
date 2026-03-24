import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/message_formatter.dart';
import '../../../../core/widgets/buttons/app_primary_button.dart';
import '../cubit/auth_state.dart';
import '../cubit/login_cubit.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_toggle.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ── Hook declarations ──────────────────────────────────────────────────
    final emailController    = useTextEditingController();
    final passwordController = useTextEditingController();
    final roleNotifier       = useValueNotifier<String>('customer');
    final rememberMe         = useValueNotifier<bool>(false);

    // ── Reactive derivations (inline — no extra ValueNotifier) ─────────────
    // useValueListenable subscribes to TextEditingValue changes, rebuilding
    // the widget on every keystroke. This replaces the old addListener pattern.
    final emailValue    = useValueListenable(emailController);
    final passwordValue = useValueListenable(passwordController);

    final hasContent = emailValue.text.trim().isNotEmpty &&
                       passwordValue.text.isNotEmpty;

    return BlocConsumer<LoginCubit, AuthState>(
      // ── Listener: side-effects only (snackbars + navigation) ──────────────
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.getLocalizedMessage(state.errorMessage)),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.getLocalizedMessage(state.successMessage)),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        switch (state.navSignal) {
          case AuthNavigation.toHome:
            context.go(AppRouter.onboarding);
          case AuthNavigation.toMerchantDash:
            context.go(AppRouter.merchantDashboard);
          case AuthNavigation.toRegister:
            context.push(AppRouter.register);
          default:
            break;
        }
      },
      // ── Builder: pure UI — reads state, emits nothing ────────────────────
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

                    // ── Top bar: back (start) · skip (end) ──────────────────
                    _TopBar(l10n: l10n),
                    SizedBox(height: 28.h),

                    // ── Title ──────────────────────────────────────────────
                    Text(
                      l10n.login_welcome_back,
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Urbanist',
                        color: AppColors.textPrimary,
                        height: 1.3,
                        letterSpacing: -1.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),

                    // ── Role toggle ─────────────────────────────────────────
                    RoleToggle(
                      roleNotifier: roleNotifier,
                      userLabel: l10n.login_user_role,
                      merchantLabel: l10n.login_merchant_role,
                    ),
                    SizedBox(height: 20.h),

                    // ── Email field ─────────────────────────────────────────
                    AuthTextField(
                      controller: emailController,
                      hint: l10n.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 12.h),

                    // ── Password field ──────────────────────────────────────
                    AuthTextField(
                      controller: passwordController,
                      hint: l10n.password,
                      isPassword: true,
                      hasError: state.errorMessage != null,
                      textInputAction: TextInputAction.done,
                    ),

                    // ── Error text ──────────────────────────────────────────
                    if (state.errorMessage != null) ...[
                      SizedBox(height: 6.h),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.getLocalizedMessage(state.errorMessage),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 12.h),

                    // ── Remember me · Forgot password ───────────────────────
                    _RememberForgotRow(rememberMe: rememberMe, l10n: l10n),
                    SizedBox(height: 24.h),

                    // ── Login button ────────────────────────────────────────
                    AppPrimaryButton(
                      text: l10n.login,
                      isLoading: state.isLoading,
                      onPressed: hasContent && !state.isLoading
                          ? () => context.read<LoginCubit>().login(
                                email:    emailController.text.trim(),
                                password: passwordController.text,
                                role:     roleNotifier.value,
                              )
                          : null,
                      height: 56.h,
                      backgroundColor:
                          hasContent ? AppColors.primary : AppColors.textDisabled,
                      textStyle: AppTextStyles.button.copyWith(
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── "Or continue with" divider ───────────────────────────
                    _OrDivider(label: l10n.login_or_divider),
                    SizedBox(height: 16.h),

                    // ── Google sign-in button ────────────────────────────────
                    _GoogleButton(label: l10n.login_google_button),
                    SizedBox(height: 70.h),

                    // ── Register link ────────────────────────────────────────
                    _NoAccountRow(l10n: l10n),
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
// SUB-WIDGETS  (StatelessWidget — zero business logic)
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final AppLocalizations l10n;
  const _TopBar({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () => context.go(AppRouter.home),
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
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () => context.go(AppRouter.home),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              child: Text(
                l10n.skip,
                style: AppTextStyles.bodyMedium.copyWith(
                  color:      AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RememberForgotRow extends StatelessWidget {
  final ValueNotifier<bool> rememberMe;
  final AppLocalizations l10n;

  const _RememberForgotRow({required this.rememberMe, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Remember me ───────────────────────────────────────────────────
        ValueListenableBuilder<bool>(
          valueListenable: rememberMe,
          builder: (context, checked, _) {
            return GestureDetector(
              onTap: () => rememberMe.value = !checked,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width:  20.w,
                    height: 20.w,
                    child: Checkbox(
                      value:     checked,
                      onChanged: (v) => rememberMe.value = v ?? false,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      side: BorderSide(
                        color: AppColors.divider,
                        width: 1.5.w,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.login_remember_me,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 14.sp

                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // ── Forgot password ───────────────────────────────────────────────
        GestureDetector(
          onTap: () {}, // TODO: wire forgot-password flow
          child: Text(
            l10n.forgotPassword,
            style: AppTextStyles.bodySmall.copyWith(
              color:      AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              fontFamily: 'NotoSansArabic',
              fontSize: 14.sp
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  final String label;
  const _OrDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.borderField, height: 1.r, thickness: 1.r),
        ),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 14.sp
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.borderField, height: 1.r, thickness: 1.r),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google button
//
// AppOutlinedButton only accepts IconData for its icon slot, which cannot host
// an SVG asset. This widget replicates AppOutlinedButton.medium styling specs
// (height 56.h · radius 12.r · border 1.5.w) while embedding the SVG directly.
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  final String label;
  const _GoogleButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.h,
      width:  double.infinity,
      child: OutlinedButton(
        onPressed: () {}, // TODO: wire Google sign-in
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.borderField, width: 1.5.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
          backgroundColor: AppColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/google_ic.svg',
              width:  24.w,
              height: 24.h,
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Urbanist',
                color:      AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NoAccountRow extends StatelessWidget {
  final AppLocalizations l10n;
  const _NoAccountRow({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.push(AppRouter.register),
        child: RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(text: '${l10n.noAccount} ',style: AppTextStyles.bodyMedium.copyWith(
                  color:      AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),),
              
              TextSpan(
                text: l10n.register_now,
                style: AppTextStyles.bodyMedium.copyWith(
                  color:      AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}