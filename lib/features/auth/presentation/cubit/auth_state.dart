import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

// ════════════════════════════════════════════════════════
// NAVIGATION SIGNALS
// ════════════════════════════════════════════════════════

/// Navigation signals emitted by auth cubits
/// UI listens via BlocConsumer.listener and calls context.go(...)
enum AuthNavigation {
  none,
  toHome,           // Successful login/register → user home
  toMerchantDash,   // Successful login/register → merchant dashboard
  toOtpVerification,// After register → OTP screen
  toLogin,          // After logout or session expiry
  toRegister,       // From login screen
}

// ════════════════════════════════════════════════════════
// AUTH STATE
// ════════════════════════════════════════════════════════

/// Unified state for all auth cubits (Login, Register, OTP)
///
/// Note: Uses a custom state instead of BaseState because auth flow
/// requires navigation signals, multi-step OTP tracking, and
/// role-based routing that don't fit the simple BaseState pattern.
class AuthState extends Equatable {
  // ── Data ──────────────────────────────────────────────
  final UserEntity? user;

  // ── Loading Flags ─────────────────────────────────────
  final bool isLoading;

  // ── OTP ───────────────────────────────────────────────
  final bool isOtpSent;
  final String? otpPhone; // Phone number OTP was sent to

  // ── Feedback ──────────────────────────────────────────
  final String? errorMessage;
  final String? successMessage;

  // ── Navigation ────────────────────────────────────────
  final AuthNavigation navSignal;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isOtpSent = false,
    this.otpPhone,
    this.errorMessage,
    this.successMessage,
    this.navSignal = AuthNavigation.none,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    bool? isOtpSent,
    String? otpPhone,
    String? errorMessage,
    String? successMessage,
    AuthNavigation? navSignal,
  }) {
    return AuthState(
      user:           user ?? this.user,
      isLoading:      isLoading ?? this.isLoading,
      isOtpSent:      isOtpSent ?? this.isOtpSent,
      otpPhone:       otpPhone ?? this.otpPhone,
      errorMessage:   errorMessage,   // nullable — pass null to clear
      successMessage: successMessage, // nullable — pass null to clear
      navSignal:      navSignal ?? this.navSignal,
    );
  }

  // ── Computed ──────────────────────────────────────────

  bool get isAuthenticated => user != null && user!.token != null;

  bool get isMerchant => user?.role == 'merchant';

  @override
  List<Object?> get props => [
    user,
    isLoading,
    isOtpSent,
    otpPhone,
    errorMessage,
    successMessage,
    navSignal,
  ];

  @override
  String toString() =>
      'AuthState('
      'user: ${user?.id}, '
      'loading: $isLoading, '
      'otpSent: $isOtpSent, '
      'nav: $navSignal)';
}
