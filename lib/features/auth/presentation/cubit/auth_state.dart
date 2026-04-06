import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

// ════════════════════════════════════════════════════════
// NAVIGATION SIGNALS
// ════════════════════════════════════════════════════════

/// Navigation signals emitted by auth cubits
/// UI listens via BlocConsumer.listener and calls context.go(...)
enum AuthNavigation {
  none,
  toHome,             // Authenticated + onboarding already done → user home
  toOnboarding,       // Authenticated + onboarding NOT yet done → customer onboarding wizard
  toSellerOnboarding, // Authenticated seller → seller onboarding wizard
  toMerchantDash,     // Seller with completed onboarding → merchant dashboard
  toCreateStore,      // Seller with completed onboarding but no store yet → create store screen
  toOtpVerification,  // After register → OTP screen
  toResetPassword,    // OTP verified (forgotPassword mode) → reset password screen
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
  /// Password carried to the OTP screen (used by the Google Sign-In flow to
  /// identify the account after email verification).
  final String? otpPassword;
  /// The entered OTP code — carried to the next screen in forgotPassword flow
  final String? otpCode;
  /// The reset token returned by the server after verifying reset OTP
  final String? resetToken;

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
    this.otpPassword,
    this.otpCode,
    this.resetToken,
    this.errorMessage,
    this.successMessage,
    this.navSignal = AuthNavigation.none,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    bool? isOtpSent,
    String? otpEmail,
    String? otpPassword,
    String? otpCode,
    String? resetToken,
    String? errorMessage,
    String? successMessage,
    AuthNavigation? navSignal,
  }) {
    return AuthState(
      user:           user           ?? this.user,
      isLoading:      isLoading      ?? this.isLoading,
      isOtpSent:      isOtpSent      ?? this.isOtpSent,
      otpEmail:       otpEmail       ?? this.otpEmail,
      otpPassword:    otpPassword    ?? this.otpPassword,
      otpCode:        otpCode        ?? this.otpCode,
      resetToken:     resetToken     ?? this.resetToken,
      errorMessage:   errorMessage,   // nullable — pass null to clear
      successMessage: successMessage, // nullable — pass null to clear
      navSignal:      navSignal      ?? this.navSignal,
    );
  }

  // ── Computed ──────────────────────────────────────────

  bool get isAuthenticated => user != null && user!.accessToken != null;

  bool get isSeller => user?.role == 'seller';

  @override
  List<Object?> get props => [
    user, isLoading, isOtpSent, otpEmail, otpPassword, otpCode, resetToken,
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
