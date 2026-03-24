import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/use_cases/register_use_case.dart';
import 'auth_state.dart';

/// Manages new user registration
///
/// Flow:
/// 1. User fills form → register() called
/// 2a. Backend returns access_token → auto-login → navSignal.toHome / toMerchantDash
/// 2b. No token → OTP required → navSignal.toOtpVerification (email passed via state.otpEmail)
class RegisterCubit extends Cubit<AuthState> {
  final RegisterUseCase registerUseCase;
  final Logger logger;

  RegisterCubit({
    required this.registerUseCase,
    required this.logger,
  }) : super(const AuthState());

  void _safeEmit(AuthState s) {
    if (!isClosed) emit(s);
  }

  // ════════════════════════════════════════════════════════
  // REGISTER
  // ════════════════════════════════════════════════════════

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (state.isLoading) return;

    logger.i('Register attempt — email: ${_maskEmail(email)}');
    _safeEmit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      navSignal: AuthNavigation.none,
    ));

    final result = await registerUseCase(
      firstName:            firstName,
      lastName:             lastName,
      email:                email,
      phoneNumber:          phoneNumber,
      password:             password,
      passwordConfirmation: passwordConfirmation,
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

        if (user.accessToken != null) {
          // Backend auto-logged-in the user
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
          // No token → OTP email verification required
          _safeEmit(state.copyWith(
            isLoading: false,
            user: user,
            isOtpSent: true,
            otpEmail: email,
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

  void clearNavSignal() => _safeEmit(state.copyWith(navSignal: AuthNavigation.none));
  void clearMessages()  => _safeEmit(state.copyWith(errorMessage: null, successMessage: null));
  void goToLogin()      => _safeEmit(state.copyWith(navSignal: AuthNavigation.toLogin));

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════

  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) return '****';
    return '${email[0]}****${email.substring(at)}';
  }
}
