import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/use_cases/register_use_case.dart';
import 'auth_state.dart';

/// Manages new user and merchant registration
///
/// Flow:
/// 1. User fills form → calls register()
/// 2. On success → emits navSignal.toOtpVerification (if OTP required)
///    OR navSignal.toHome / toMerchantDash (if auto-login after register)
///
/// Usage in UI:
/// ```dart
/// BlocConsumer<RegisterCubit, AuthState>(
///   listener: (context, state) {
///     if (state.navSignal == AuthNavigation.toOtpVerification) {
///       context.go(AppRouter.otpVerification, extra: state.otpPhone);
///     }
///     if (state.errorMessage != null) showSnackBar(context, state.errorMessage!);
///   },
///   builder: (context, state) { ... },
/// )
/// ```
class RegisterCubit extends Cubit<AuthState> {
  final RegisterUseCase registerUseCase;
  final Logger logger;

  RegisterCubit({
    required this.registerUseCase,
    required this.logger,
  }) : super(const AuthState());

  // ════════════════════════════════════════════════════════
  // SAFE EMIT
  // ════════════════════════════════════════════════════════

  void _safeEmit(AuthState newState) {
    if (!isClosed) emit(newState);
  }

  // ════════════════════════════════════════════════════════
  // REGISTER
  // ════════════════════════════════════════════════════════

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  }) async {
    if (state.isLoading) return;

    logger.i('Register attempt — role: $role, phone: ${_maskPhone(phone)}');
    _safeEmit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      navSignal: AuthNavigation.none,
    ));

    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );

    result.fold(
      (failure) {
        logger.e('Registration failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
      (user) {
        logger.i('Registration successful — role: ${user.role}');

        // If backend returns a token immediately → auto-login
        if (user.token != null) {
          final nav = user.role == 'merchant'
              ? AuthNavigation.toMerchantDash
              : AuthNavigation.toHome;
          _safeEmit(state.copyWith(
            isLoading: false,
            user: user,
            successMessage: 'register_success',
            navSignal: nav,
          ));
        } else {
          // No token → OTP verification required
          _safeEmit(state.copyWith(
            isLoading: false,
            user: user,
            isOtpSent: true,
            otpPhone: phone,
            successMessage: 'register_otp_sent',
            navSignal: AuthNavigation.toOtpVerification,
          ));
        }
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

  void goToLogin() {
    _safeEmit(state.copyWith(navSignal: AuthNavigation.toLogin));
  }

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════

  String _maskPhone(String phone) {
    if (phone.length < 6) return '****';
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }
}
