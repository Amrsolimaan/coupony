class StorageKeys {
  StorageKeys._();

  // ════════════════════════════════════════════════════════
  // SECURE STORAGE KEYS (Sensitive Data - flutter_secure_storage)
  // ════════════════════════════════════════════════════════
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role'; // 'user' or 'merchant'

  // ════════════════════════════════════════════════════════
  // HIVE BOX NAMES (Local Cache)
  // ════════════════════════════════════════════════════════
  static const String couponsBox = 'coupons_box';
  static const String storesBox = 'stores_box';
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String categoriesBox = 'categories_box';

  /// Onboarding user preferences (selected categories before auth)
  static const String onboardingPreferencesBox = 'onboarding_preferences_box';

  /// ⭐ NEW: Permission status (location, notification)
  static const String permissionsBox = 'permissions_box';

  /// ⚠️ CRITICAL: This box stores ONLY metadata (paths, sizes, timestamps)
  /// Actual media files are stored in file system
  static const String mediaMetadataBox = 'media_metadata_box';

  // ════════════════════════════════════════════════════════
  // CACHE KEYS (Inside Boxes)
  // ════════════════════════════════════════════════════════
  static const String couponsList = 'coupons_list';
  static const String storesList = 'stores_list';
  static const String categoriesList = 'categories_list';
  static const String featuredCoupons = 'featured_coupons';
  static const String nearbyStores = 'nearby_stores';
  static const String userData = 'user_data';

  /// Key for storing onboarding preferences inside the box
  static const String onboardingPreferencesKey = 'user_onboarding_preferences';

  /// ⭐ NEW: Key for storing permission status inside the box
  static const String permissionStatusKey = 'permission_status';

  /// ⭐ INTEREST TRACKING KEYS
  static const String categoryScoresKey = 'category_scores';
  static const String seenProductsListKey = 'seen_products_list';
  static const String lastDecayDateKey = 'last_decay_date';

  // ════════════════════════════════════════════════════════
  // SETTINGS KEYS
  // ════════════════════════════════════════════════════════
  static const String isDarkMode = 'is_dark_mode';
  static const String language = 'app_locale';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String lastCleanupDate = 'last_cleanup_date';

  // Legacy keys (for backward compatibility)
  @Deprecated('Use authToken instead')
  static const String token = 'auth_token';

  @Deprecated('Use isDarkMode instead')
  static const String theme = 'app_theme';

  @Deprecated('Use language instead')
  static const String locale = 'app_locale';

  @Deprecated('Use userData instead')
  static const String user = 'user_data';
}
