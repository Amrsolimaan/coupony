import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../config/routes/app_router.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/message_formatter.dart';
import '../../../../core/widgets/buttons/app_primary_button.dart';
import '../../../../core/extensions/snackbar_extension.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../cubit/auth_state.dart';
import '../cubit/otp_cubit.dart';
import '../utils/seller_routing_resolver.dart';
import '../widgets/auth_success_bottom_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OTP MODE ENUM
// ─────────────────────────────────────────────────────────────────────────────

enum OtpMode {
  emailVerification, // Post-register email confirmation
  forgotPassword,    // Password-reset code entry
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP SCREEN  — generic multi-mode tool
//
// Mode behaviour summary
// ─────────────────────
// emailVerification:
//   • Auto-sends OTP on mount via OtpCubit.sendOtp
//   • Verifies code via API (VerifyOtpUseCase)
//   • Success → AuthSuccessBottomSheet → home / merchant dashboard
//
// forgotPassword:
//   • Does NOT auto-send (code already dispatched by ForgotPasswordCubit)
//   • "Verifies" code locally — just carries it forward (no API round-trip)
//   • Success → direct push to ResetPasswordScreen with {email, token}
// ─────────────────────────────────────────────────────────────────────────────

class OtpScreen extends HookWidget {
  final String email;
  final OtpMode mode;
  final String? maskedRecipient;
  final int? expiryMinutes;

  const OtpScreen({
    super.key,
    required this.email,
    required this.mode,
    this.maskedRecipient,
    this.expiryMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final codeControllers    = List.generate(6, (_) => useTextEditingController());
    final focusNodes         = List.generate(6, (_) => useFocusNode());
    final timerNotifier      = useValueNotifier<int>(60);
    final activeIndexNotifier = useValueNotifier<int>(0);
    final shakeController    = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    final hasAutoSubmitted = useRef(false);
    final timerRef         = useRef<Timer?>(null);

    final shakeAnimation = useMemoized(
      () => Tween<double>(begin: 0, end: 10).animate(
        CurvedAnimation(parent: shakeController, curve: Curves.elasticIn),
      ),
    );

    // ── Countdown timer helpers ─────────────────────────────────────────────
    // startCountdown cancels any live timer and starts a fresh 60-second one.
    // Using a Ref so the listener closure always calls the latest version.
    void startCountdown() {
      timerRef.value?.cancel();
      timerNotifier.value = 60;
      timerRef.value = Timer.periodic(const Duration(seconds: 1), (t) {
        if (timerNotifier.value > 0) {
          timerNotifier.value--;
        } else {
          t.cancel();
          timerRef.value = null;
        }
      });
    }

    final startCountdownRef = useRef(startCountdown);
    startCountdownRef.value = startCountdown; // always point to latest closure

    // Start timer once on mount; dispose on unmount.
    useEffect(() {
      startCountdown();
      return () {
        timerRef.value?.cancel();
        timerRef.value = null;
      };
    }, const []);

    // ── Initialize email in cubit state (NO auto-send) ────────────────────
    // 🔧 FIX: Removed auto-send to prevent double OTP issue.
    // The backend already sends OTP during registration when no access_token
    // is returned. Auto-sending here would invalidate the first code.
    // Users can still manually trigger resend via the "Resend" button.
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final cubit = context.read<OtpCubit>();
        // Set email in state so resend functionality works correctly
        cubit.setEmail(email);
        // ❌ REMOVED: cubit.sendOtp(email) - Backend already sent OTP
      });
      return null;
    }, []);

    // ── Reactive code value ────────────────────────────────────────────────
    final codeValues = codeControllers.map((c) => useValueListenable(c).text).toList();
    final code        = codeValues.join();
    final hasFullCode = code.length == 6 && code.split('').every((c) => c.isNotEmpty);

    // ── Auto-submit on full code ───────────────────────────────────────────
    useEffect(() {
      if (hasFullCode && !hasAutoSubmitted.value) {
        hasAutoSubmitted.value = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            HapticFeedback.mediumImpact();
            context.read<OtpCubit>().verifyOtp(
              email: email,
              code:  code,
              mode:  mode,
            );
          }
        });
      } else if (!hasFullCode) {
        hasAutoSubmitted.value = false;
      }
      return null;
    }, [hasFullCode]);

    return BlocConsumer<OtpCubit, AuthState>(
      listener: (context, state) {
        // ── Error → shake + snackbar ────────────────────────────────────────
        if (state.errorMessage != null) {
          HapticFeedback.vibrate();
          shakeController.forward(from: 0).then((_) => shakeController.reverse());
          context.showErrorSnackBar(context.getLocalizedMessage(state.errorMessage));
        }

        // ── OTP resent → restart countdown ────────────────────────────────
        if (state.isOtpSent) {
          startCountdownRef.value();
          HapticFeedback.lightImpact();
        }

        // ── CASE A: email verification success → bottom sheet ──────────────
        if (state.navSignal == AuthNavigation.toHome ||
            state.navSignal == AuthNavigation.toOnboarding ||
            state.navSignal == AuthNavigation.toSellerOnboarding ||
            state.navSignal == AuthNavigation.toSellerLanding) {
          HapticFeedback.mediumImpact();

          // Capture before async/builder boundary to prevent use-after-dispose
          final targetNav  = state.navSignal;
          final targetUser = state.user;

          _showSuccessModal(context, l10n, onContinue: () {
            Navigator.of(context).pop();
            context.read<OtpCubit>().clearNavSignal();

            switch (targetNav) {
              case AuthNavigation.toSellerLanding:
                if (targetUser != null) {
                  SellerRoutingResolver.resolveForUser(
                    context:     context,
                    user:        targetUser,
                    authLocalDs: di.sl<AuthLocalDataSource>(),
                  );
                }
              case AuthNavigation.toSellerOnboarding:
                context.go(AppRouter.sellerOnboarding);
              case AuthNavigation.toOnboarding:
                context.go(AppRouter.onboarding);
              default:
                context.go(AppRouter.home);
            }
          });
        }

        // ── CASE B: forgot-password code collected → reset screen ──────────
        if (state.navSignal == AuthNavigation.toResetPassword) {
          context.read<OtpCubit>().clearNavSignal();
          context.push(AppRouter.resetPassword, extra: {
            'email': email,
            'token': state.resetToken ?? '', // ✅ إرسال reset_token من السيرفر
          });
        }
      },
      builder: (context, state) {
        final displayEmail = maskedRecipient ?? email;
        final primaryColor = Theme.of(context).primaryColor;

        // Dynamic title based on mode
        final screenTitle = mode == OtpMode.forgotPassword
            ? l10n.forgot_password_title
            : l10n.otp_screen_title;

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
                    const _TopBar(),
                    SizedBox(height: 28.h),

                    // ── Title ──────────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        screenTitle,
                        style: TextStyle(
                          fontFamily: AppTextStyles.Main_Font_arabic,
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
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        l10n.otp_screen_subtitle,
                        style: TextStyle(
                          fontFamily: AppTextStyles.Main_Font_arabic,
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // ── Email address ──────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        displayEmail,
                        style: TextStyle(
                          fontFamily: AppTextStyles.Main_Font_english,
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // ── 6-Digit OTP input with shake ───────────────────────
                    AnimatedBuilder(
                      animation: shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            shakeAnimation.value *
                                (shakeController.status == AnimationStatus.reverse
                                    ? -1
                                    : 1),
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: _OtpInputRow(
                        controllers:          codeControllers,
                        focusNodes:           focusNodes,
                        activeIndexNotifier:  activeIndexNotifier,
                        isEnabled:            !state.isLoading,
                        email:                email,
                        primaryColor:         primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // ── Expiry notice ──────────────────────────────────────
                    Text(
                      l10n.otp_expiry_notice,
                      style: TextStyle(
                        fontFamily: AppTextStyles.Main_Font_arabic,
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),

                    // ── Verify button ──────────────────────────────────────
                    AppPrimaryButton(
                      text:      l10n.otp_verify_button,
                      isLoading: state.isLoading,
                      onPressed: hasFullCode && !state.isLoading
                          ? () {
                              HapticFeedback.lightImpact();
                              context.read<OtpCubit>().verifyOtp(
                                email: email,
                                code:  code,
                                mode:  mode,
                              );
                            }
                          : null,
                      height:          56.h,
                      backgroundColor: hasFullCode
                          ? primaryColor
                          : AppColors.textDisabled,
                      textStyle: TextStyle(
                        fontFamily:  AppTextStyles.Main_Font_arabic,
                        fontSize:    16.sp,
                        fontWeight:  FontWeight.w600,
                        color:       AppColors.surface,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Resend row ─────────────────────────────────────────
                    ValueListenableBuilder<int>(
                      valueListenable: timerNotifier,
                      builder: (context, timer, _) {
                        final canResend = timer == 0 && !state.isLoading;
                        return GestureDetector(
                          onTap: canResend
                              ? () {
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<OtpCubit>()
                                      .resendOtp(mode: mode);
                                }
                              : null,
                          child: timer > 0
                              ? RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontFamily:  AppTextStyles.Main_Font_arabic,
                                      fontSize:    14.sp,
                                      color:       AppColors.textPrimary,
                                      fontWeight:  FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(text: '${l10n.otp_resend_timer_prefix} '),
                                      TextSpan(
                                        text: _formatTimer(timer),
                                        style: TextStyle(
                                          fontFamily: AppTextStyles.Main_Font_english,
                                          color:      AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontFamily:  AppTextStyles.Main_Font_arabic,
                                      fontSize:    14.sp,
                                      color:       AppColors.textPrimary,
                                      fontWeight:  FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(text: '${l10n.otp_resend_prefix} '),
                                      TextSpan(
                                        text: l10n.otp_resend_button,
                                        style: TextStyle(
                                          color:      primaryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        );
                      },
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

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs    = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showSuccessModal(
    BuildContext context,
    AppLocalizations l10n, {
    required VoidCallback onContinue,
  }) {
    // ✅ Capture current theme color explicitly to avoid premature capture bug
    final primaryColor = Theme.of(context).primaryColor;
    
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      isDismissible:      false,
      enableDrag:         false,
      builder: (_) => AuthSuccessBottomSheet(
        title:        l10n.otp_success_title,
        buttonText:   l10n.otp_success_button,
        onContinue:   onContinue,
        primaryColor: primaryColor, // ✅ Explicit color injection
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
              Icons.arrow_back_ios_rounded,
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

class _OtpInputRow extends HookWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final ValueNotifier<int> activeIndexNotifier;
  final bool isEnabled;
  final String email;
  final Color primaryColor;

  const _OtpInputRow({
    required this.controllers,
    required this.focusNodes,
    required this.activeIndexNotifier,
    required this.isEnabled,
    required this.email,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 6.w),
              child: _OtpDigitBox(
                controller:          controllers[index],
                focusNode:           focusNodes[index],
                activeIndexNotifier: activeIndexNotifier,
                index:               index,
                isEnabled:           isEnabled,
                primaryColor:        primaryColor,
                onChanged:           (value) => _handleDigitChange(context, index, value),
                onPaste:             () => _handlePaste(context),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _handleDigitChange(BuildContext context, int index, String value) {
    // Handle paste of multiple digits
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        HapticFeedback.mediumImpact();
        // Fill current and subsequent fields
        for (int i = 0; i < digits.length && (index + i) < 6; i++) {
          controllers[index + i].text = digits[i];
        }
        // Move focus to next empty field or unfocus if all filled
        final nextEmptyIndex = index + digits.length;
        if (nextEmptyIndex < 6) {
          focusNodes[nextEmptyIndex].requestFocus();
        } else {
          FocusScope.of(context).unfocus();
        }
      }
      return;
    }

    if (value.isNotEmpty) {
      HapticFeedback.lightImpact();
      activeIndexNotifier.value = index;
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
    } else {
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _handlePaste(BuildContext context) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final pastedText = clipboardData.text!.replaceAll(RegExp(r'\D'), '');
      if (pastedText.length == 6 && context.mounted) {
        HapticFeedback.mediumImpact();
        for (int i = 0; i < 6; i++) {
          controllers[i].text = pastedText[i];
        }
        if (context.mounted) FocusScope.of(context).unfocus();
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _OtpDigitBox extends HookWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueNotifier<int> activeIndexNotifier;
  final int index;
  final bool isEnabled;
  final Color primaryColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onPaste;

  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.activeIndexNotifier,
    required this.index,
    required this.isEnabled,
    required this.primaryColor,
    required this.onChanged,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    final textValue = useValueListenable(controller);
    final hasValue  = textValue.text.isNotEmpty;

    return GestureDetector(
      onLongPress: onPaste,
      child: SizedBox(
        height: 68.h,
        child: TextField(
          controller:    controller,
          focusNode:     focusNode,
          enabled:       isEnabled,
          keyboardType:  TextInputType.number,
          textAlign:     TextAlign.center,
          maxLength:     6, // Allow paste of full code
          style: TextStyle(
            fontFamily: AppTextStyles.Main_Font_english,
            fontSize:   24.sp,
            fontWeight: FontWeight.w700,
            color:      primaryColor,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:   BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: hasValue
                  ? BorderSide(color: primaryColor, width: 2.w)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:   BorderSide(color: primaryColor, width: 2.w),
            ),
            filled:          true,
            fillColor:       hasValue ? AppColors.surface : const Color(0xFFF5F5F5),
            counterText:     '',
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: onChanged,
          onTap: () {
            // Allow editing by selecting all text when tapping
            if (hasValue) {
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            }
          },
        ),
      ),
    );
  }
}
