import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

// ════════════════════════════════════════════════════════
// NAVIGATION SIGNALS
// ════════════════════════════════════════════════════════

/// Navigation signals emitted by auth cubits
/// UI listens via BlocConsumer.listener and calls context.go(...)
enum AuthNavigation {
  none,
  toHome,             // Successful login/verify → user home
  toMerchantDash,     // Successful login/verify → merchant dashboard
  toOtpVerification,  // After register → OTP screen
  toLogin,            // After logout or session expiry
  toRegister,         // From login screen
}

// ════════════════════════════════════════════════════════
// AUTH STATE
// ════════════════════════════════════════════════════════

/// Unified state for LoginCubit, RegisterCubit, and OtpCubit
class AuthState extends Equatable {
  // ── Data ──────────────────────────────────────────────
  final UserEntity? user;

  // ── Loading Flags ─────────────────────────────────────
  final bool isLoading;

  // ── OTP ───────────────────────────────────────────────
  final bool isOtpSent;
  /// Email address the OTP was dispatched to
  final String? otpEmail;

  // ── Feedback ──────────────────────────────────────────
  final String? errorMessage;
  final String? successMessage;

  // ── Navigation ────────────────────────────────────────
  final AuthNavigation navSignal;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isOtpSent = false,
    this.otpEmail,
    this.errorMessage,
    this.successMessage,
    this.navSignal = AuthNavigation.none,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    bool? isOtpSent,
    String? otpEmail,
    String? errorMessage,
    String? successMessage,
    AuthNavigation? navSignal,
  }) {
    return AuthState(
      user:           user           ?? this.user,
      isLoading:      isLoading      ?? this.isLoading,
      isOtpSent:      isOtpSent      ?? this.isOtpSent,
      otpEmail:       otpEmail       ?? this.otpEmail,
      errorMessage:   errorMessage,   // nullable — pass null to clear
      successMessage: successMessage, // nullable — pass null to clear
      navSignal:      navSignal      ?? this.navSignal,
    );
  }

  // ── Computed ──────────────────────────────────────────

  bool get isAuthenticated => user != null && user!.accessToken != null;

  bool get isMerchant => user?.role == 'merchant';

  @override
  List<Object?> get props => [
    user, isLoading, isOtpSent, otpEmail,
    errorMessage, successMessage, navSignal,
  ];

  @override
  String toString() =>
      'AuthState('
      'user: ${user?.id}, '
      'loading: $isLoading, '
      'otpSent: $isOtpSent, '
      'nav: $navSignal)';
}
