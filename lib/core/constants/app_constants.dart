class AppConstants {
  AppConstants._();

  // ════════════════════════════════════════════════════════
  // PAGINATION
  // ════════════════════════════════════════════════════════
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // ════════════════════════════════════════════════════════
  // CACHE TTL (Time To Live)
  // ════════════════════════════════════════════════════════
  /// Coupons cache duration (15 minutes - frequently updated)
  static const Duration couponsCacheDuration = Duration(minutes: 15);

  /// Stores cache duration (1 hour - relatively stable)
  static const Duration storesCacheDuration = Duration(hours: 1);

  /// User data cache duration (1 day)
  static const Duration userCacheDuration = Duration(days: 1);

  /// Categories cache duration (1 week - rarely changes)
  static const Duration categoriesCacheDuration = Duration(days: 7);

  /// Media files cache duration (7 days) ✅ ADDED
  static const Duration mediaCacheDuration = Duration(days: 7);

  // ════════════════════════════════════════════════════════
  // MEDIA STORAGE QUOTA (Anti-Bloat Protection) ✅ ADDED
  // ════════════════════════════════════════════════════════
  /// Maximum media cache size in MB
  /// When exceeded, oldest files are deleted automatically
  static const int maxMediaCacheSizeMB = 200; // 200 MB max

  /// Background cleanup threshold (starts cleaning when reached)
  static const int mediaQuotaWarningMB = 150; // 150 MB

  // ════════════════════════════════════════════════════════
  // MAP CONFIGURATION
  // ════════════════════════════════════════════════════════
  static const double defaultZoom = 14.0;
  static const double defaultLatitude = 24.7136; // Riyadh (example)
  static const double defaultLongitude = 46.6753;

  // ════════════════════════════════════════════════════════
  // IMAGE CONSTRAINTS
  // ════════════════════════════════════════════════════════
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // ════════════════════════════════════════════════════════
  // VALIDATION
  // ════════════════════════════════════════════════════════
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;

  // ════════════════════════════════════════════════════════
  // CLEANUP SCHEDULE ✅ ADDED
  // ════════════════════════════════════════════════════════
  /// How often to run automatic cleanup (on app start + background)
  static const Duration cleanupInterval = Duration(hours: 24);
}
