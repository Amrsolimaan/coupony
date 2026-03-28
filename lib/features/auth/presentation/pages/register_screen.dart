import 'package:coupony/config/dependency_injection/injection_container.dart' as di;
import 'package:coupony/features/auth/presentation/cubit/google_sign_in_cubit.dart';
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
import '../cubit/auth_state.dart';
import '../cubit/register_cubit.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_toggle.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/auth_success_bottom_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REGISTER SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends HookWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ── Hook declarations ──────────────────────────────────────────────────
    final firstNameController       = useTextEditingController();
    final lastNameController        = useTextEditingController();
    final emailController           = useTextEditingController();
    final phoneController           = useTextEditingController();
    final passwordController        = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final roleNotifier              = useValueNotifier<String>('customer');
    final agreeToTerms              = useValueNotifier<bool>(false);

    // ── Reactive derivations ───────────────────────────────────────────────
    final firstNameValue        = useValueListenable(firstNameController);
    final lastNameValue         = useValueListenable(lastNameController);
    final emailValue            = useValueListenable(emailController);
    final phoneValue            = useValueListenable(phoneController);
    final passwordValue         = useValueListenable(passwordController);
    final confirmPasswordValue  = useValueListenable(confirmPasswordController);
    final termsValue            = useValueListenable(agreeToTerms);

    final hasContent = firstNameValue.text.trim().isNotEmpty &&
        lastNameValue.text.trim().isNotEmpty &&
        emailValue.text.trim().isNotEmpty &&
        phoneValue.text.trim().isNotEmpty &&
        passwordValue.text.isNotEmpty &&
        confirmPasswordValue.text.isNotEmpty &&
        termsValue;

    return BlocProvider<GoogleSignInCubit>(
      create: (context) => di.sl<GoogleSignInCubit>(),
      child: MultiBlocListener(
        listeners: [
          // ── RegisterCubit listener ───────────────────────────────────────
          BlocListener<RegisterCubit, AuthState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                context.showErrorSnackBar(context.getLocalizedMessage(state.errorMessage));
              }
              if (state.successMessage != null) {
                context.showSuccessSnackBar(context.getLocalizedMessage(state.successMessage));
              }
              switch (state.navSignal) {
                case AuthNavigation.toHome:
                  context.go(AppRouter.onboarding);
                case AuthNavigation.toMerchantDash:
                  context.go(AppRouter.merchantDashboard);
                case AuthNavigation.toOtpVerification:
                  context.push(AppRouter.otpVerification, extra: state.otpEmail);
                case AuthNavigation.toLogin:
                  context.pop();
                default:
                  break;
              }
            },
          ),
          // ── GoogleSignInCubit listener ───────────────────────────────────
          BlocListener<GoogleSignInCubit, AuthState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                context.showErrorSnackBar(context.getLocalizedMessage(state.errorMessage));
              }
              if (state.successMessage != null && state.navSignal != AuthNavigation.none) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AuthSuccessBottomSheet(
                    title: l10n.login_success_title,
                    buttonText: l10n.continue_button,
                    onContinue: () {
                      Navigator.of(context).pop();
                      switch (state.navSignal) {
                        case AuthNavigation.toHome:
                          context.go(AppRouter.home);
                        case AuthNavigation.toOnboarding:
                          context.go(AppRouter.onboarding);
                        case AuthNavigation.toMerchantDash:
                          context.go(AppRouter.merchantDashboard);
                        default:
                          break;
                      }
                    },
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<RegisterCubit, AuthState>(
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

                        // ── Top bar ─────────────────────────────────────────
                        _TopBar(l10n: l10n),
                        SizedBox(height: 28.h),

                        // ── Title ───────────────────────────────────────────
                        Text(
                          l10n.register_welcome,
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.3,
                            letterSpacing: -1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),

                        // ── Role toggle ─────────────────────────────────────
                        RoleToggle(
                          roleNotifier: roleNotifier,
                          userLabel: l10n.login_user_role,
                          merchantLabel: l10n.login_merchant_role,
                        ),
                        SizedBox(height: 20.h),

                        // ── Name fields (First · Last) ──────────────────────
                        Directionality(
                          textDirection: Directionality.of(context),
                          child: Row(
                            children: [
                              Expanded(
                                child: AuthTextField(
                                  controller: firstNameController,
                                  hint: l10n.register_first_name,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: AuthTextField(
                                  controller: lastNameController,
                                  hint: l10n.register_last_name,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // ── Email field ─────────────────────────────────────
                        AuthTextField(
                          controller: emailController,
                          hint: l10n.email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 12.h),

                        // ── Phone field ─────────────────────────────────────
                        AuthTextField(
                          controller: phoneController,
                          hint: l10n.register_phone,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 12.h),

                        // ── Password field ──────────────────────────────────
                        AuthTextField(
                          controller: passwordController,
                          hint: l10n.register_password,
                          isPassword: true,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 12.h),

                        // ── Confirm password field ──────────────────────────
                        AuthTextField(
                          controller: confirmPasswordController,
                          hint: l10n.register_confirm_password,
                          isPassword: true,
                          hasError: state.errorMessage != null,
                          textInputAction: TextInputAction.done,
                        ),

                        // ── Error text ──────────────────────────────────────
                        if (state.errorMessage != null) ...[
                          SizedBox(height: 6.h),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              context.getLocalizedMessage(state.errorMessage),
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 12,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 12.h),

                        // ── Terms & Conditions checkbox ─────────────────────
                        _TermsCheckbox(agreeToTerms: agreeToTerms, l10n: l10n),
                        SizedBox(height: 24.h),

                        // ── Register button ─────────────────────────────────
                        AppPrimaryButton(
                          text: l10n.register,
                          isLoading: state.isLoading,
                          onPressed: hasContent && !state.isLoading
                              ? () => context.read<RegisterCubit>().register(
                                    firstName: firstNameController.text.trim(),
                                    lastName: lastNameController.text.trim(),
                                    email: emailController.text.trim(),
                                    phoneNumber: phoneController.text.trim(),
                                    password: passwordController.text,
                                    passwordConfirmation:
                                        confirmPasswordController.text,
                                    role: roleNotifier.value,
                                  )
                              : null,
                          height: 56.h,
                          backgroundColor:
                              hasContent ? AppColors.primary : AppColors.textDisabled,
                          textStyle: AppTextStyles.customStyle(
                            context,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.surface,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ── "Or continue with" divider ───────────────────────
                        _OrDivider(label: l10n.login_or_divider),
                        SizedBox(height: 16.h),

                        // ── Google sign-in button ────────────────────────────
                        ValueListenableBuilder<String>(
                          valueListenable: roleNotifier,
                          builder: (context, role, _) {
                            return GoogleSignInButton(
                              label: l10n.login_google_button,
                              role: role,
                            );
                          },
                        ),
                        SizedBox(height: 24.h),

                        // ── Login link ───────────────────────────────────────
                        _HaveAccountRow(l10n: l10n),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-WIDGETS
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
            onTap: () => context.pop(),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20.w,
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
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
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

class _TermsCheckbox extends StatelessWidget {
  final ValueNotifier<bool> agreeToTerms;
  final AppLocalizations l10n;

  const _TermsCheckbox({required this.agreeToTerms, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: agreeToTerms,
      builder: (context, checked, _) {
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: GestureDetector(
            onTap: () => agreeToTerms.value = !checked,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: Checkbox(
                    value: checked,
                    onChanged: (v) => agreeToTerms.value = v ?? false,
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
                  l10n.register_agree_terms,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          child: Divider(
              color: AppColors.borderField, height: 1.r, thickness: 1.r),
        ),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
          child: Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
              color: AppColors.borderField, height: 1.r, thickness: 1.r),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HaveAccountRow extends StatelessWidget {
  final AppLocalizations l10n;
  const _HaveAccountRow({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => context.pop(),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 8.w,
              vertical: 4.h,
            ),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(text: '${l10n.hasAccount} '),
                  TextSpan(
                    text: l10n.login_now,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}