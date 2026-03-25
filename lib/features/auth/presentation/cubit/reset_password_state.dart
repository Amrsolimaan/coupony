import 'package:equatable/equatable.dart';

// ════════════════════════════════════════════════════════
// NAVIGATION SIGNAL
// ════════════════════════════════════════════════════════

enum ResetPasswordNavigation {
  none,
  toLogin, // Password reset success → go back to login
}

// ════════════════════════════════════════════════════════
// PASSWORD STRENGTH MODEL
// ════════════════════════════════════════════════════════

/// Drives the UI strength-meter checkmarks.
/// Each flag maps to one visual requirement row.
class PasswordStrength extends Equatable {
  final bool hasMinLength;  // 8+ characters
  final bool hasDigit;      // at least one digit
  final bool hasUppercase;  // at least one uppercase letter
  final bool hasLowercase;  // at least one lowercase letter

  const PasswordStrength({
    this.hasMinLength = false,
    this.hasDigit     = false,
    this.hasUppercase = false,
    this.hasLowercase = false,
  });

  /// All four criteria met → password is strong enough to submit.
  bool get isStrong =>
      hasMinLength && hasDigit && hasUppercase && hasLowercase;

  /// Counts how many criteria are satisfied (0–4).
  int get score =>
      (hasMinLength ? 1 : 0) +
      (hasDigit     ? 1 : 0) +
      (hasUppercase ? 1 : 0) +
      (hasLowercase ? 1 : 0);

  /// Compute strength from a raw password string.
  factory PasswordStrength.fromPassword(String password) {
    return PasswordStrength(
      hasMinLength: password.length >= 8,
      hasDigit:     password.contains(RegExp(r'\d')),
      hasUppercase: password.contains(RegExp(r'[A-Z]')),
      hasLowercase: password.contains(RegExp(r'[a-z]')),
    );
  }

  static const empty = PasswordStrength();

  @override
  List<Object?> get props =>
      [hasMinLength, hasDigit, hasUppercase, hasLowercase];
}

// ════════════════════════════════════════════════════════
// STATE
// ════════════════════════════════════════════════════════

class ResetPasswordState extends Equatable {
  // ── Loading ───────────────────────────────────────────
  final bool isLoading;

  /// Separate loading flag for the resend-code button (non-blocking).
  final bool isResending;

  // ── Feedback ──────────────────────────────────────────
  /// Localization key — resolved by the UI via [AppLocalizations]
  final String? errorMessage;

  /// Localization key — resolved by the UI via [AppLocalizations]
  final String? successMessage;

  // ── Navigation ────────────────────────────────────────
  final ResetPasswordNavigation navSignal;

  // ── Password Strength ─────────────────────────────────
  final PasswordStrength passwordStrength;

  const ResetPasswordState({
    this.isLoading        = false,
    this.isResending      = false,
    this.errorMessage,
    this.successMessage,
    this.navSignal        = ResetPasswordNavigation.none,
    this.passwordStrength = PasswordStrength.empty,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    bool? isResending,
    String? errorMessage,
    String? successMessage,
    ResetPasswordNavigation? navSignal,
    PasswordStrength? passwordStrength,
  }) {
    return ResetPasswordState(
      isLoading:        isLoading        ?? this.isLoading,
      isResending:      isResending      ?? this.isResending,
      errorMessage:     errorMessage,     // nullable — pass null to clear
      successMessage:   successMessage,   // nullable — pass null to clear
      navSignal:        navSignal        ?? this.navSignal,
      passwordStrength: passwordStrength ?? this.passwordStrength,
    );
  }

  @override
  List<Object?> get props => [
    isLoading, isResending, errorMessage, successMessage,
    navSignal, passwordStrength,
  ];

  @override
  String toString() =>
      'ResetPasswordState(loading: $isLoading, resending: $isResending, '
      'nav: $navSignal, strength: ${passwordStrength.score}/4)';
}
