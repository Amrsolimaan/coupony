import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/use_cases/send_reset_code_use_case.dart';
import 'forgot_password_state.dart';

/// Handles the first step of the forgot-password flow:
/// collecting the user's email and triggering the reset-code dispatch.
///
/// Flow:
///   1. User enters email → [sendResetCode] called
///   2a. API success → [navSignal.toResetPassword] (email + expiry info carried in state)
///   2b. API failure → [errorMessage] set (localization key)
///
/// Security note: The API always returns "success" regardless of whether the
/// email exists (prevents account enumeration). The cubit surfaces the generic
/// [forgot_password_code_sent] key to the UI unconditionally on HTTP 2xx.
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final SendResetCodeUseCase sendResetCodeUseCase;
  final Logger logger;

  ForgotPasswordCubit({
    required this.sendResetCodeUseCase,
    required this.logger,
  }) : super(const ForgotPasswordState());

  void _safeEmit(ForgotPasswordState s) {
    if (!isClosed) emit(s);
  }

  // ════════════════════════════════════════════════════════
  // SEND RESET CODE
  // ════════════════════════════════════════════════════════

  Future<void> sendResetCode(String email) async {
    if (state.isLoading) return;

    logger.i('Forgot-password: sending reset code to ${_maskEmail(email)}');
    _safeEmit(state.copyWith(
      isLoading:      true,
      errorMessage:   null,
      successMessage: null,
      navSignal:      ForgotPasswordNavigation.none,
    ));

    final result = await sendResetCodeUseCase(email.trim());

    result.fold(
      (failure) {
        logger.e('Send reset code failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isLoading:    false,
          errorMessage: _mapFailureToKey(failure),
        ));
      },
      (resetResponse) {
        logger.i('Reset code dispatched — expires: ${resetResponse.expiresAt}');
        _safeEmit(state.copyWith(
          isLoading:      false,
          successMessage: 'forgot_password_code_sent',
          navSignal:      ForgotPasswordNavigation.toResetPassword,
          resetResponse:  resetResponse,
          submittedEmail: email.trim(),
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // NAVIGATION / MESSAGE HELPERS
  // ════════════════════════════════════════════════════════

  void clearNavSignal() =>
      _safeEmit(state.copyWith(navSignal: ForgotPasswordNavigation.none));

  void clearMessages() =>
      _safeEmit(state.copyWith(errorMessage: null, successMessage: null));

  // ════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ════════════════════════════════════════════════════════

  String _mapFailureToKey(Failure failure) {
    // Validation errors - show backend message directly
    if (failure is ValidationFailure) return failure.message;
    
    if (failure is NetworkFailure) return 'auth_error_network';
    if (failure is ServerFailure)  return 'auth_error_server';
    return 'auth_error_unexpected';
  }

  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) return '****';
    return '${email[0]}****${email.substring(at)}';
  }
}
