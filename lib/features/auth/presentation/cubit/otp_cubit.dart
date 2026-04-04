import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/use_cases/resend_reset_code_use_case.dart';
import '../../domain/use_cases/send_otp_use_case.dart';
import '../../domain/use_cases/verify_otp_use_case.dart';
import '../../domain/use_cases/verify_reset_code_use_case.dart';
import '../pages/otp_screen.dart' show OtpMode;
import 'auth_state.dart';

/// Manages OTP send/verify flow for two distinct modes:
///
/// [OtpMode.emailVerification]
///   1. Screen opens → sendOtp() dispatches the code
///   2. User enters 6 digits → verifyOtp() calls /auth/otp/verify (purpose: verify_email)
///   3. Success → navSignal.toHome / toMerchantDash
///
/// [OtpMode.forgotPassword]
///   1. Screen opens → sendOtp() is NOT called (code already sent by ForgotPasswordCubit)
///   2. User enters 6 digits → verifyOtp() calls /auth/password/verify-otp
///      ✅ 200 OK → navSignal.toResetPassword (email + reset_token in state)
///      ❌ 422    → stay on screen, show error, vibrate
///   3. Resend → calls resendResetCodeUseCase (/auth/password/resend-otp)
class OtpCubit extends Cubit<AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final VerifyResetCodeUseCase verifyResetCodeUseCase;
  final ResendResetCodeUseCase resendResetCodeUseCase;
  final Logger logger;

  DateTime? _lastSentAt;
  static const _resendCooldownSeconds = 60;

  OtpCubit({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.verifyResetCodeUseCase,
    required this.resendResetCodeUseCase,
    required this.logger,
  }) : super(const AuthState());

  void _safeEmit(AuthState s) {
    if (!isClosed) emit(s);
  }

  // ════════════════════════════════════════════════════════
  // SEND OTP  (emailVerification only)
  // ════════════════════════════════════════════════════════

  Future<void> sendOtp(String email) async {
    if (state.isLoading) return;

    logger.i('Sending OTP to: ${_maskEmail(email)}');
    _safeEmit(state.copyWith(
      isLoading:      true,
      errorMessage:   null,
      successMessage: null,
      navSignal:      AuthNavigation.none,
      otpEmail:       email,
    ));

    final result = await sendOtpUseCase(email);

    result.fold(
      (failure) {
        logger.e('Send OTP failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isLoading: false,
          isOtpSent: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        logger.i('OTP sent successfully to ${_maskEmail(email)}');
        _lastSentAt = DateTime.now();
        _safeEmit(state.copyWith(
          isLoading:      false,
          isOtpSent:      true,
          otpEmail:       email,
          successMessage: 'otp_sent_success',
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // RESEND OTP  (mode-aware)
  // ════════════════════════════════════════════════════════

  Future<void> resendOtp({OtpMode mode = OtpMode.emailVerification}) async {
    final email = state.otpEmail;
    if (email == null) {
      logger.w('Cannot resend OTP — no email in state');
      return;
    }

    if (_lastSentAt != null) {
      final elapsed = DateTime.now().difference(_lastSentAt!).inSeconds;
      if (elapsed < _resendCooldownSeconds) {
        final remaining = _resendCooldownSeconds - elapsed;
        logger.d('Resend cooldown active — $remaining seconds remaining');
        _safeEmit(state.copyWith(errorMessage: 'otp_resend_cooldown_$remaining'));
        return;
      }
    }

    // CRITICAL: Reset isOtpSent FIRST to trigger listener properly
    _safeEmit(state.copyWith(
      isLoading:      true,
      isOtpSent:      false,
      errorMessage:   null,
      successMessage: null,
    ));

    if (mode == OtpMode.forgotPassword) {
      await _resendResetCode(email);
    } else {
      await _resendForEmailVerification(email);
    }
  }

  Future<void> _resendResetCode(String email) async {
    logger.i('Resending reset code to ${_maskEmail(email)}');
    final result = await resendResetCodeUseCase(email);

    result.fold(
      (failure) {
        logger.e('Resend reset code failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isLoading:    false,
          isOtpSent:    false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        logger.i('Reset code resent to ${_maskEmail(email)}');
        _lastSentAt = DateTime.now();
        _safeEmit(state.copyWith(
          isLoading:      false,
          isOtpSent:      true,
          successMessage: 'otp_sent_success',
        ));
      },
    );
  }

  Future<void> _resendForEmailVerification(String email) async {
    logger.i('Resending OTP to ${_maskEmail(email)}');
    final result = await sendOtpUseCase(email);

    result.fold(
      (failure) {
        logger.e('Resend OTP failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isLoading:    false,
          isOtpSent:    false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        logger.i('OTP resent successfully to ${_maskEmail(email)}');
        _lastSentAt = DateTime.now();
        _safeEmit(state.copyWith(
          isLoading:      false,
          isOtpSent:      true,
          successMessage: 'otp_sent_success',
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // VERIFY OTP  (mode-aware)
  // ════════════════════════════════════════════════════════

  Future<void> verifyOtp({
    required String email,
    required String code,
    OtpMode mode = OtpMode.emailVerification,
  }) async {
    if (state.isLoading) return;

    if (code.trim().isEmpty) {
      _safeEmit(state.copyWith(errorMessage: 'otp_empty_error'));
      return;
    }

    // ── forgotPassword mode: verify with server and get reset_token ──────
    if (mode == OtpMode.forgotPassword) {
      logger.i('Verifying reset code for ${_maskEmail(email)}');
      _safeEmit(state.copyWith(
        isLoading:      true,
        errorMessage:   null,
        successMessage: null,
        navSignal:      AuthNavigation.none,
      ));

      final resetResult = await verifyResetCodeUseCase(
        email: email,
        code:  code.trim(),
      );

      resetResult.fold(
        (failure) {
          logger.e('Reset code verification failed: ${failure.message}');
          _safeEmit(state.copyWith(
            isLoading:    false,
            errorMessage: 'reset_password_error_invalid_token',
          ));
        },
        (resetToken) {
          // Backend returns a new reset_token (different from OTP code)
          logger.i('Reset code verified for ${_maskEmail(email)} — token: ${resetToken.substring(0, 10)}...');
          _safeEmit(state.copyWith(
            isLoading:   false,
            otpEmail:    email,
            otpCode:     code.trim(),
            resetToken:  resetToken, 
            navSignal:   AuthNavigation.toResetPassword,
          ));
        },
      );
      return;
    }

    // ── emailVerification mode: call the API ─────────────────────────────
    logger.i('Verifying OTP for: ${_maskEmail(email)}');
    _safeEmit(state.copyWith(
      isLoading:      true,
      errorMessage:   null,
      successMessage: null,
      navSignal:      AuthNavigation.none,
    ));

    final result = await verifyOtpUseCase(email: email, code: code.trim());

    result.fold(
      (failure) {
        logger.e('OTP verification failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isLoading:    false,
          errorMessage: failure.message,
        ));
      },
      (user) {
        logger.i('OTP verified — role: ${user.role}, onboardingCompleted: ${user.isOnboardingCompleted}');
        
        // Determine navigation based on role and onboarding status
        final AuthNavigation nav;
        if (user.role == 'seller') {
          // Sellers: check if onboarding is completed
          nav = user.isOnboardingCompleted
              ? AuthNavigation.toMerchantDash
              : AuthNavigation.toSellerOnboarding;
        } else {
          // Customers: check if onboarding is completed
          nav = user.isOnboardingCompleted
              ? AuthNavigation.toHome
              : AuthNavigation.toOnboarding;
        }

        _safeEmit(state.copyWith(
          isLoading:      false,
          user:           user,
          isOtpSent:      false,
          successMessage: 'otp_verified_success',
          navSignal:      nav,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // NAVIGATION HELPERS
  // ════════════════════════════════════════════════════════

  void setEmail(String email) =>
      _safeEmit(state.copyWith(otpEmail: email));

  void clearNavSignal() =>
      _safeEmit(state.copyWith(navSignal: AuthNavigation.none));

  void clearMessages() =>
      _safeEmit(state.copyWith(errorMessage: null, successMessage: null));

  // ════════════════════════════════════════════════════════
  // COMPUTED HELPERS (for UI countdown timer)
  // ════════════════════════════════════════════════════════

  int get resendCooldownRemaining {
    if (_lastSentAt == null) return 0;
    final elapsed = DateTime.now().difference(_lastSentAt!).inSeconds;
    final remaining = _resendCooldownSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  bool get canResend => resendCooldownRemaining == 0;

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════

  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) return '****';
    return '${email[0]}****${email.substring(at)}';
  }
}
