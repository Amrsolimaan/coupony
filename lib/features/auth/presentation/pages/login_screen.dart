import 'package:coupony/config/dependency_injection/injection_container.dart' as di;
import 'package:coupony/features/auth/presentation/cubit/google_sign_in_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../utils/seller_routing_resolver.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/message_formatter.dart';
import '../../../../core/widgets/buttons/app_primary_button.dart';
import '../../../../core/extensions/snackbar_extension.dart';
import '../cubit/auth_state.dart';
import '../cubit/login_cubit.dart';
import '../cubit/auth_role_cubit.dart';
import '../cubit/auth_role_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_toggle.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/auth_success_bottom_sheet.dart';
import '../widgets/role_animation_wrapper.dart';

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
    final rememberMe         = useValueNotifier<bool>(false);

    // ── Reactive derivations (inline — no extra ValueNotifier) ─────────────
    final emailValue    = useValueListenable(emailController);
    final passwordValue = useValueListenable(passwordController);

    final hasContent = emailValue.text.trim().isNotEmpty &&
                       passwordValue.text.isNotEmpty;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthRoleCubit>.value(
          value: di.sl<AuthRoleCubit>(),
        ),
        BlocProvider<LoginCubit>(
          create: (context) => di.sl<LoginCubit>(),
        ),
        BlocProvider<GoogleSignInCubit>(
          create: (context) => di.sl<GoogleSignInCubit>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, AuthState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                context.showErrorSnackBar(context.getLocalizedMessage(state.errorMessage));
              }
              if (state.successMessage != null) {
                context.showSuccessSnackBar(context.getLocalizedMessage(state.successMessage));
              }
              switch (state.navSignal) {
                case AuthNavigation.toHome:
                  context.go(AppRouter.home);
                case AuthNavigation.toOnboarding:
                  context.go(AppRouter.onboarding);
                case AuthNavigation.toSellerOnboarding:
                  context.go(AppRouter.sellerOnboarding);
                case AuthNavigation.toSellerLanding:
                  // Delegate to the shared 4-scenario resolver.
                  // user is always a UserModel here (carries fresh stores list).
                  if (state.user != null) {
                    SellerRoutingResolver.resolveForUser(
                      context:     context,
                      user:        state.user!,
                      authLocalDs: di.sl<AuthLocalDataSource>(),
                    );
                  }
                case AuthNavigation.toRegister:
                  context.push(AppRouter.register);
                default:
                  break;
              }
            },
          ),
          BlocListener<GoogleSignInCubit, AuthState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                context.showErrorSnackBar(context.getLocalizedMessage(state.errorMessage));
              }

              // OTP required (unverified account) — navigate immediately, no bottom sheet
              if (state.navSignal == AuthNavigation.toOtpVerification) {
                context.push(
                  AppRouter.otpVerification,
                  extra: <String, String>{
                    'email':    state.otpEmail    ?? '',
                    'password': state.otpPassword ?? '',
                  },
                );
                return;
              }

              if (state.successMessage != null && state.navSignal != AuthNavigation.none) {
                final primaryColor = Theme.of(context).primaryColor;
                // Capture the login-screen context before entering the builder
                // so async resolver calls (e.g. saveSelectedStoreId) can use a
                // context that outlives the bottom sheet widget.
                final outerCtx  = context;
                final snapUser  = state.user;
                final snapSignal = state.navSignal;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AuthSuccessBottomSheet(
                    title:        l10n.login_success_title,
                    buttonText:   l10n.continue_button,
                    primaryColor: primaryColor,
                    onContinue: () {
                      Navigator.of(outerCtx).pop();
                      switch (snapSignal) {
                        case AuthNavigation.toHome:
                          outerCtx.go(AppRouter.home);
                        case AuthNavigation.toOnboarding:
                          outerCtx.go(AppRouter.onboarding);
                        case AuthNavigation.toSellerOnboarding:
                          outerCtx.go(AppRouter.sellerOnboarding);
                        case AuthNavigation.toSellerLanding:
                          if (snapUser != null) {
                            SellerRoutingResolver.resolveForUser(
                              context:     outerCtx,
                              user:        snapUser,
                              authLocalDs: di.sl<AuthLocalDataSource>(),
                            );
                          }
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
        child: BlocBuilder<LoginCubit, AuthState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: AppColors.surface,
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: SafeArea(
                  child: RoleAnimationWrapper(
                    child: SingleChildScrollView(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 16.h),

                          // ── Top bar: back (start) · skip (end) ──────────────────
                          _TopBar(l10n: l10n),
                          SizedBox(height: 10.h),

                          // ── Animated Logo ───────────────────────────────────────
                          AnimatedLogoSwitcher(
                            size: 100,
                          ),
                          SizedBox(height: 20.h),

                          // ── Title ──────────────────────────────────────────────
                          Text(
                            l10n.login_welcome_back,
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

                          // ── Role toggle ─────────────────────────────────────────
                          RoleToggle(
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
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 12,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 12.h),

                          // ── Remember me · Forgot password ───────────────────────
                          _RememberForgotRow(
                            rememberMe: rememberMe,
                            l10n: l10n,
                          ),
                          SizedBox(height: 24.h),

                          // ── Login button (with animated color) ─────────────────
                          AnimatedPrimaryColor(
                            builder: (context, primaryColor) {
                              return BlocBuilder<AuthRoleCubit, AuthRoleState>(
                                builder: (context, roleState) {
                                  return AppPrimaryButton(
                                    text: l10n.login,
                                    isLoading: state.isLoading,
                                    onPressed: hasContent && !state.isLoading
                                        ? () => context.read<LoginCubit>().login(
                                              email:    emailController.text.trim(),
                                              password: passwordController.text,
                                              role:     roleState.role,
                                            )
                                        : null,
                                    height: 56.h,
                                    backgroundColor:
                                        hasContent ? primaryColor : AppColors.textDisabled,
                                    textStyle: AppTextStyles.customStyle(
                                      context,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.surface,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          SizedBox(height: 20.h),

                          // ── "Or continue with" divider ───────────────────────────
                          _OrDivider(label: l10n.login_or_divider),
                          SizedBox(height: 16.h),

                          // ── Google sign-in button ────────────────────────────────
                          BlocBuilder<AuthRoleCubit, AuthRoleState>(
                            builder: (context, roleState) {
                              return GoogleSignInButton(
                                label: l10n.login_google_button,
                                role: roleState.role,
                              );
                            },
                          ),
                          SizedBox(height: 20.h),

                          // ── Register link (with animated color) ─────────────────
                          AnimatedPrimaryColor(
                            builder: (context, primaryColor) {
                              return _NoAccountRow(
                                l10n: l10n,
                                primaryColor: primaryColor,
                              );
                            },
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
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

class _RememberForgotRow extends StatelessWidget {
  final ValueNotifier<bool> rememberMe;
  final AppLocalizations l10n;

  const _RememberForgotRow({
    required this.rememberMe,
    required this.l10n,
  });

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
                  AnimatedPrimaryColor(
                    builder: (context, primaryColor) => SizedBox(
                      width:  20.w,
                      height: 20.w,
                      child: Checkbox(
                        value:     checked,
                        onChanged: (v) => rememberMe.value = v ?? false,
                        activeColor: primaryColor,
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
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.login_remember_me,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // ── Forgot password ───────────────────────────────────────────────
        GestureDetector(
          onTap: () => context.push(AppRouter.forgotPassword),
          child: Text(
            l10n.forgotPassword,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
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
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
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

class _NoAccountRow extends StatelessWidget {
  final AppLocalizations l10n;
  final Color primaryColor;

  const _NoAccountRow({
    required this.l10n,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.push(AppRouter.register),
        child: RichText(
          text: TextSpan(
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(text: '${l10n.noAccount} '),
              TextSpan(
                text: l10n.register_now,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  color: primaryColor,
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