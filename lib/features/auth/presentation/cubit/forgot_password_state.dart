import 'package:equatable/equatable.dart';
import '../../data/models/password_reset_response_model.dart';

// ════════════════════════════════════════════════════════
// NAVIGATION SIGNAL
// ════════════════════════════════════════════════════════

enum ForgotPasswordNavigation {
  none,
  toResetPassword, // Code sent → proceed to OTP + new-password screen
}

// ════════════════════════════════════════════════════════
// STATE
// ════════════════════════════════════════════════════════

class ForgotPasswordState extends Equatable {
  // ── Loading ───────────────────────────────────────────
  final bool isLoading;

  // ── Feedback ──────────────────────────────────────────
  /// Localization key — resolved by the UI via [AppLocalizations]
  final String? errorMessage;

  /// Localization key — resolved by the UI via [AppLocalizations]
  final String? successMessage;

  // ── Navigation ────────────────────────────────────────
  final ForgotPasswordNavigation navSignal;

  // ── Data ──────────────────────────────────────────────
  /// Returned by the API: contains expiry metadata for the UI countdown timer.
  final PasswordResetResponseModel? resetResponse;

  /// Email submitted — passed to the next screen so it doesn't need re-entry.
  final String? submittedEmail;

  const ForgotPasswordState({
    this.isLoading       = false,
    this.errorMessage,
    this.successMessage,
    this.navSignal       = ForgotPasswordNavigation.none,
    this.resetResponse,
    this.submittedEmail,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    ForgotPasswordNavigation? navSignal,
    PasswordResetResponseModel? resetResponse,
    String? submittedEmail,
  }) {
    return ForgotPasswordState(
      isLoading:      isLoading      ?? this.isLoading,
      errorMessage:   errorMessage,   // nullable — pass null to clear
      successMessage: successMessage, // nullable — pass null to clear
      navSignal:      navSignal      ?? this.navSignal,
      resetResponse:  resetResponse  ?? this.resetResponse,
      submittedEmail: submittedEmail ?? this.submittedEmail,
    );
  }

  @override
  List<Object?> get props => [
    isLoading, errorMessage, successMessage,
    navSignal, resetResponse, submittedEmail,
  ];

  @override
  String toString() =>
      'ForgotPasswordState(loading: $isLoading, nav: $navSignal, '
      'email: $submittedEmail)';
}
