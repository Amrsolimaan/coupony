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
  static const String stores         = '/stores';
  static const String createStore    = '/stores';
  static String updateStore(String storeId) => '/stores/$storeId';
  static const String getCategories  = '/store-categories';
  static const String getSocials     = '/socials';

  // ── Profile ───────────────────────────────────────────
  static const String profile         = '/auth/me';

  // ── Addresses ─────────────────────────────────────────
  static const String addresses       = '/me/addresses';
  static String addressById(String id) => '/me/addresses/$id';

  // ── Seller Products ───────────────────────────────────
  static String storeProducts(String storeId) =>
      '/stores/$storeId/products';
  static String storeProductById(String storeId, String productId) =>
      '/stores/$storeId/products/$productId';
  static String storeProductStatus(String storeId, String productId) =>
      '/stores/$storeId/products/$productId/status';

  // ── Public / Customer Products ──���─────────────────────
  static const String publicProducts    = '/products';
  static String publicProductById(String id) => '/products/$id';
  static const String publicCategories  = '/categories';
  static String publicCategoryProducts(String categoryId) =>
      '/categories/$categoryId/products';

  // ── Password Reset ─────────────────────────────────────
  static const String forgotPassword    = '/auth/password/forgot';
  static const String verifyResetOtp    = '/auth/password/verify-otp';
  static const String resendResetCode   = '/auth/password/resend-otp';
  static const String resetPassword     = '/auth/password/reset';
  static const String changePassword    = '/auth/change-password';
}
