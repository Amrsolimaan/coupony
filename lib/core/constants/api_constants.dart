class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.coupony.shop/api/v1';

  // ── Auth ──────────────────────────────────────────────
  static const String login          = '/auth/login';
  static const String register       = '/auth/register';
  static const String sendOtp        = '/auth/otp/send';
  static const String verifyOtp      = '/auth/otp/verify';
  static const String logout         = '/auth/logout';
  static const String refreshToken   = '/auth/refresh';
  static const String updateFcmToken = '/auth/fcm-token';
}
