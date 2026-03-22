import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Category constants for onboarding preferences
/// Keys are language-agnostic — used for storage & API
class CategoryConstants {
  CategoryConstants._();

  // ════════════════════════════════════════════════════════
  // CATEGORY KEYS (Language-Agnostic)
  // ════════════════════════════════════════════════════════
  static const String restaurants = 'restaurants';
  static const String fashion = 'fashion';
  static const String supermarket = 'supermarket';
  static const String electronics = 'electronics';
  static const String pharmacy = 'pharmacy';
  static const String beauty = 'beauty';
  static const String travel = 'travel';
  static const String other = 'other';

  // ════════════════════════════════════════════════════════
  // ALL CATEGORIES LIST (Ordered as in design)
  // ════════════════════════════════════════════════════════
  static const List<String> allCategories = [
    restaurants,
    fashion,
    supermarket,
    electronics,
    pharmacy,
    beauty,
    travel,
    other,
  ];

  // ════════════════════════════════════════════════════════
  // CATEGORY ICONS (Material IconData)
  // ════════════════════════════════════════════════════════
  static const Map<String, IconData> categoryIcons = {
    restaurants: Icons.fastfood,
    fashion: Icons.checkroom,
    supermarket: Icons.shopping_cart,
    electronics: Icons.devices,
    pharmacy: Icons.local_pharmacy,
    beauty: Icons.face_retouching_natural,
    travel: Icons.flight,
    other: Icons.category,
  };

  // ════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════

  /// Get icon for category key
  static IconData getIcon(String categoryKey) {
    return categoryIcons[categoryKey] ?? Icons.category;
  }

  /// Get localized name for category key
  static String getCategoryName(String categoryKey, BuildContext context) {
    // Note: Assuming standard AppLocalizations.
    // If not generated yet, this might show an error until "flutter gen-l10n" is run.
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return categoryKey;

    switch (categoryKey) {
      case restaurants:
        return localizations.categoryRestaurants;
      case fashion:
        return localizations.categoryFashion;
      case supermarket:
        return localizations.categorySupermarket;
      case electronics:
        return localizations.categoryElectronics;
      case pharmacy:
        return localizations.categoryPharmacy;
      case beauty:
        return localizations.categoryBeauty;
      case travel:
        return localizations.categoryTravel;
      case other:
        return localizations.categoryOther;
      default:
        return categoryKey;
    }
  }

  /// Validate if a key is a valid category
  static bool isValidCategory(String key) {
    return allCategories.contains(key);
  }
}
