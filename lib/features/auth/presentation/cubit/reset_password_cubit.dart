import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/use_cases/resend_reset_code_use_case.dart';
import '../../domain/use_cases/reset_password_params.dart';
import '../../domain/use_cases/reset_password_use_case.dart';
import 'reset_password_state.dart';

/// Handles the second step of the forgot-password flow:
/// OTP entry + new-password input + submission.
///
/// Flow:
///   Password typing → [updatePasswordStrength] drives UI checkmarks in real time.
///   Submit          → [resetPassword] called with email + token + new passwords.
///   Success         → [navSignal.toLogin]
///   HTTP 422        → [errorMessage] = 'reset_password_error_invalid_token'
///   Resend          → [resendCode] (uses separate [isResending] flag)
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordUseCase  resetPasswordUseCase;
  final ResendResetCodeUseCase resendResetCodeUseCase;
  final Logger logger;

  ResetPasswordCubit({
    required this.resetPasswordUseCase,
    required this.resendResetCodeUseCase,
    required this.logger,
  }) : super(const ResetPasswordState());

  void _safeEmit(ResetPasswordState s) {
    if (!isClosed) emit(s);
  }

  // ════════════════════════════════════════════════════════
  // PASSWORD STRENGTH METER
  // ════════════════════════════════════════════════════════

  /// Called on every keystroke in the new-password field.
  /// Updates [state.passwordStrength] so the UI checkmarks react instantly.
  void updatePasswordStrength(String password) {
    _safeEmit(state.copyWith(
      passwordStrength: PasswordStrength.fromPassword(password),
    ));
  }

  // ════════════════════════════════════════════════════════
  // RESET PASSWORD
  // ════════════════════════════════════════════════════════

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (state.isLoading) return;

    logger.i('Reset password attempt for ${_maskEmail(email)} with token: ${token.substring(0, 3)}***');
    _safeEmit(state.copyWith(
      isLoading:      true,
      errorMessage:   null,
      successMessage: null,
      navSignal:      ResetPasswordNavigation.none,
    ));

    final result = await resetPasswordUseCase(
      ResetPasswordParams(
        email:                email,
        token:                token,
        password:             password,
        passwordConfirmation: passwordConfirmation,
      ),
    );

    result.fold(
      (failure) {
        logger.e('Reset password failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isLoading:    false,
          errorMessage: _mapFailureToKey(failure),
        ));
      },
      (_) {
        logger.i('Password reset successfully for ${_maskEmail(email)}');
        _safeEmit(state.copyWith(
          isLoading:      false,
          successMessage: 'reset_password_success',
          navSignal:      ResetPasswordNavigation.toLogin,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // RESEND CODE
  // ════════════════════════════════════════════════════════

  /// Resends the OTP to [email]. Uses [isResending] so the main submit button
  /// remains unaffected and the resend button shows its own spinner.
  Future<void> resendCode(String email) async {
    if (state.isResending) return;

    logger.i('Resending reset code to ${_maskEmail(email)}');
    _safeEmit(state.copyWith(
      isResending:    true,
      errorMessage:   null,
      successMessage: null,
    ));

    final result = await resendResetCodeUseCase(email);

    result.fold(
      (failure) {
        logger.e('Resend code failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isResending:  false,
          errorMessage: _mapFailureToKey(failure),
        ));
      },
      (resetResponse) {
        logger.i('Reset code resent — new expiry: ${resetResponse.expiresAt}');
        _safeEmit(state.copyWith(
          isResending:    false,
          successMessage: 'forgot_password_code_sent',
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // NAVIGATION / MESSAGE HELPERS
  // ════════════════════════════════════════════════════════

  void clearNavSignal() =>
      _safeEmit(state.copyWith(navSignal: ResetPasswordNavigation.none));

  void clearMessages() =>
      _safeEmit(state.copyWith(errorMessage: null, successMessage: null));

  // ════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ════════════════════════════════════════════════════════

  String _mapFailureToKey(Failure failure) {
    // Validation errors - show backend message directly
    if (failure is ValidationFailure) return failure.message;
    
    if (failure is InvalidTokenFailure) return 'reset_password_error_invalid_token';
    if (failure is NetworkFailure)      return 'auth_error_network';
    if (failure is ServerFailure)       return 'reset_password_error_server';
    return 'auth_error_unexpected';
  }

  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) return '****';
    return '${email[0]}****${email.substring(at)}';
  }
}
