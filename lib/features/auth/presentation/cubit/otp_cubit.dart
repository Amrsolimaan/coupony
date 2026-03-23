import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/use_cases/send_otp_use_case.dart';
import '../../domain/use_cases/verify_otp_use_case.dart';
import 'auth_state.dart';

/// Manages OTP send and verification flow
///
/// Flow:
/// 1. Screen opens with phone pre-filled → sendOtp() called automatically
/// 2. User enters 4/6-digit code → verifyOtp() called on submit
/// 3. On success → navSignal.toHome or toMerchantDash
/// 4. Resend → sendOtp() again (with cooldown guard)
///
/// Usage in UI:
/// ```dart
/// BlocConsumer<OtpCubit, AuthState>(
///   listener: (context, state) {
///     if (state.navSignal == AuthNavigation.toHome) context.go(AppRouter.home);
///     if (state.navSignal == AuthNavigation.toMerchantDash) context.go(AppRouter.merchantDashboard);
///     if (state.errorMessage != null) showSnackBar(context, state.errorMessage!);
///     if (state.successMessage != null) showSnackBar(context, state.successMessage!, isSuccess: true);
///   },
///   builder: (context, state) { ... },
/// )
/// ```
class OtpCubit extends Cubit<AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final Logger logger;

  // Resend cooldown tracking
  DateTime? _lastSentAt;
  static const _resendCooldownSeconds = 60;

  OtpCubit({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.logger,
  }) : super(const AuthState());

  // ════════════════════════════════════════════════════════
  // SAFE EMIT
  // ════════════════════════════════════════════════════════

  void _safeEmit(AuthState newState) {
    if (!isClosed) emit(newState);
  }

  // ════════════════════════════════════════════════════════
  // SEND OTP
  // ════════════════════════════════════════════════════════

  Future<void> sendOtp(String phone) async {
    if (state.isLoading) return;

    logger.i('Sending OTP to: ${_maskPhone(phone)}');
    _safeEmit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      navSignal: AuthNavigation.none,
      otpPhone: phone,
    ));

    final result = await sendOtpUseCase(phone);

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
        logger.i('OTP sent successfully to ${_maskPhone(phone)}');
        _lastSentAt = DateTime.now();
        _safeEmit(state.copyWith(
          isLoading: false,
          isOtpSent: true,
          otpPhone: phone,
          successMessage: 'otp_sent_success',
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // RESEND OTP
  // ════════════════════════════════════════════════════════

  /// Resend OTP with cooldown guard (60 seconds between requests)
  Future<void> resendOtp() async {
    final phone = state.otpPhone;
    if (phone == null) {
      logger.w('Cannot resend OTP — no phone number in state');
      return;
    }

    // Enforce cooldown
    if (_lastSentAt != null) {
      final elapsed = DateTime.now().difference(_lastSentAt!).inSeconds;
      if (elapsed < _resendCooldownSeconds) {
        final remaining = _resendCooldownSeconds - elapsed;
        logger.d('Resend cooldown active — $remaining seconds remaining');
        _safeEmit(state.copyWith(
          errorMessage: 'otp_resend_cooldown_$remaining',
        ));
        return;
      }
    }

    await sendOtp(phone);
  }

  // ════════════════════════════════════════════════════════
  // VERIFY OTP
  // ════════════════════════════════════════════════════════

  Future<void> verifyOtp({required String phone, required String otp}) async {
    if (state.isLoading) return;

    if (otp.trim().isEmpty) {
      _safeEmit(state.copyWith(errorMessage: 'otp_empty_error'));
      return;
    }

    logger.i('Verifying OTP for: ${_maskPhone(phone)}');
    _safeEmit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      navSignal: AuthNavigation.none,
    ));

    final result = await verifyOtpUseCase(phone: phone, otp: otp.trim());

    result.fold(
      (failure) {
        logger.e('OTP verification failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
      (user) {
        logger.i('OTP verified — role: ${user.role}');
        final nav = user.role == 'merchant'
            ? AuthNavigation.toMerchantDash
            : AuthNavigation.toHome;
        _safeEmit(state.copyWith(
          isLoading: false,
          user: user,
          isOtpSent: false,
          successMessage: 'otp_verified_success',
          navSignal: nav,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // NAVIGATION HELPERS
  // ════════════════════════════════════════════════════════

  void clearNavSignal() {
    _safeEmit(state.copyWith(navSignal: AuthNavigation.none));
  }

  void clearMessages() {
    _safeEmit(state.copyWith(errorMessage: null, successMessage: null));
  }

  // ════════════════════════════════════════════════════════
  // COMPUTED HELPERS (for UI)
  // ════════════════════════════════════════════════════════

  /// Seconds remaining before resend is allowed (0 = can resend now)
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

  String _maskPhone(String phone) {
    if (phone.length < 6) return '****';
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }
}
