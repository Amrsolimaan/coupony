class StorageKeys {
  StorageKeys._();

  // ════════════════════════════════════════════════════════
  // SECURE STORAGE KEYS (Sensitive Data - flutter_secure_storage)
  // ════════════════════════════════════════════════════════
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role'; // 'user' or 'merchant'
  static const String fcmToken = 'fcm_token';

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

  /// Seller onboarding preferences box
  static const String sellerOnboardingPreferencesBox =
      'seller_onboarding_preferences_box';

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

  /// Flag persisted after a successful onboarding API submission.
  /// Stored in Hive settingsBox — true means the backend acknowledged completion.
  static const String onboardingCompletedKey = 'onboarding_completed';

  /// Flag persisted after a seller successfully creates their store via the API.
  /// true  → store has been created and submitted for review.
  /// false → seller must complete store creation before accessing the dashboard.
  static const String storeCreatedKey = 'is_store_created';

  /// SecureStorage key: the seller's currently active / selected store ID.
  /// Written by [AuthLocalDataSource.saveSelectedStoreId] and read by the
  /// merchant dashboard to scope API calls to the correct store.
  static const String selectedStoreId = 'selected_store_id';

  /// User-scoped SharedPreferences key: JSON-encoded list of [UserStoreModel]
  /// objects cached from the last successful login response.
  static const String cachedStoresKey = 'cached_stores';

  /// User-scoped SharedPreferences key: comma-separated list of user roles
  /// (e.g., 'seller,customer' or 'seller_pending,customer')
  static const String userRolesKey = 'user_roles';

  /// ⭐ INTEREST TRACKING KEYS
  static const String categoryScoresKey = 'category_scores';
  static const String seenProductsListKey = 'seen_products_list';
  static const String lastDecayDateKey = 'last_decay_date';

  // ════════════════════════════════════════════════════════
  // SETTINGS KEYS
  // ════════════════════════════════════════════════════════

  /// Persisted in SharedPreferences (non-sensitive).
  /// true  → user explicitly chose to browse as a guest.
  /// false → user is logged in (or has never chosen guest mode).
  static const String isGuest = 'is_guest';

  /// Flag to track if user has passed the welcome gateway at least once.
  /// true → user has seen welcome gateway and chose login/guest before.
  /// Used to skip welcome gateway on subsequent app launches after logout.
  static const String hasPassedWelcomeGateway = 'has_passed_welcome_gateway';

  static const String isDarkMode = 'is_dark_mode';
  static const String language = 'app_locale';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String lastCleanupDate = 'last_cleanup_date';
  
  /// User's preferred role (customer/seller) - persists across logout
  /// Stored in SharedPreferences (non-sensitive preference)
  static const String preferredRole = 'preferred_role';

  // Legacy keys (for backward compatibility)
  @Deprecated('Use authToken instead')
  static const String token = 'auth_token';

  @Deprecated('Use isDarkMode instead')
  static const String theme = 'app_theme';

  @Deprecated('Use language instead')
  static const String locale = 'app_locale';

  @Deprecated('Use userData instead')
  static const String user = 'user_data';

  static const String sellerOnboardingPreferencesKey = 'seller_onboarding_preferences';

  // ── Public / Customer Products ─────────────────────────
  /// Hive box for public product detail cache (15-min TTL).
  static const String publicProductsBox = 'public_products_box';

  /// Key prefix for individual product detail entries.
  static const String publicProductDetailPrefix = 'public_product_';

  /// Cache key for the public categories list (stored in categoriesBox).
  static const String publicCategoriesList = 'public_categories_list';

  /// Cache key for page-1 unfiltered public products (offline-first fallback).
  static const String publicProductsPage1Key = 'public_products_page1';
}
