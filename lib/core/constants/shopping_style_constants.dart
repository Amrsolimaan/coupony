/// Shopping style constants for onboarding Step 3
/// Keys are language-agnostic — used for storage & API
class ShoppingStyleConstants {
  ShoppingStyleConstants._();

  // ════════════════════════════════════════════════════════
  // SHOPPING STYLE KEYS (Language-Agnostic)
  // ════════════════════════════════════════════════════════
  static const String online = 'online';
  static const String basedOnOffer = 'based_on_offer';
  static const String inStore = 'in_store';
  static const String bestDiscount = 'best_discount';

  // ════════════════════════════════════════════════════════
  // ALL SHOPPING STYLES LIST (Ordered as in design)
  // ════════════════════════════════════════════════════════
  static const List<String> allShoppingStyles = [
    online,
    basedOnOffer,
    inStore,
    bestDiscount,
  ];

  // ════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════

  /// Validate if a key is a valid shopping style
  static bool isValidStyle(String key) {
    return allShoppingStyles.contains(key);
  }

  /// Get localized name for shopping style
  /// Note: UI will handle localization using AppLocalizations
  static String getStyleKey(String styleOption) {
    switch (styleOption) {
      case online:
        return 'shoppingOnline'; // Key in l10n files
      case basedOnOffer:
        return 'shoppingBasedOnOffer';
      case inStore:
        return 'shoppingInStore';
      case bestDiscount:
        return 'shoppingBestDiscount';
      default:
        return styleOption;
    }
  }

  /// Check if at least one style is selected (validation)
  static bool hasValidSelection(List<String> selectedStyles) {
    return selectedStyles.isNotEmpty &&
        selectedStyles.every((style) => isValidStyle(style));
  }
}
