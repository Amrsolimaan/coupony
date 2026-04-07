class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.coupony.shop/api/v1';

  // ── Auth ──────────────────────────────────────────────
  static const String login          = '/auth/login';
  static const String register       = '/auth/register';
  static const String googleAuth     = '/auth/google';
  static const String sendOtp        = '/auth/otp/send';
  static const String verifyOtp      = '/auth/otp/verify';
  static const String logout         = '/auth/logout';
  static const String refreshToken   = '/auth/refresh';
  static const String updateFcmToken = '/auth/fcm-token';

  // ── Stores ────────────────────────────────────────────
  static const String createStore    = '/stores';
  static const String getCategories  = '/store-categories';
  static const String getSocials     = '/socials';

  // ── Password Reset ─────────────────────────────────────
  static const String forgotPassword    = '/auth/password/forgot';
  static const String verifyResetOtp    = '/auth/password/verify-otp';
  static const String resendResetCode   = '/auth/password/resend-otp';
  static const String resetPassword     = '/auth/password/reset';
}
