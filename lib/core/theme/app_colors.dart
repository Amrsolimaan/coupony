import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors (Updated to Main Orange)
  static const Color primary = Color.from(alpha: 1, red: 1, green: 0.373, blue: 0.004); // اللون الأساسي المطلوب
  static const Color primaryOfSeller = Color(0xFF215194); // Seller primary color #215194
  // ignore: constant_identifier_names
  static const Color primary_of_saller = primaryOfSeller; // Deprecated: Use primaryOfSeller
  static const Color primaryDark = Color(0xFFD94E00);
  static const Color primaryLight = Color(0xFFFF8540);

  // Splash Gradient Colors (From your specs)
  static const Color splashGradientStart = Color(0xFFFF5F01);
  static const Color splashGradientEnd = Color(0xFFFF5F01);

  // Accent Colors
  static const Color accent = Color(0xFFFF6584);
  static const Color accentLight = Color(0xFFFF8FA3);

  // Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textDisabled = Color(0xFFAAB2BB);

  // Status Colors - iOS Inspired with Glassmorphism Support
  static const Color success = Color(0xFF34C759);
  static const Color successSoft = Color(0xFF30D158);
  static const Color error = Color(0xFFFF3B30);
  static const Color errorSoft = Color(0xFFFF453A);
  static const Color warning = Color(0xFFFF9500);
  static const Color warningSoft = Color(0xFFFF9F0A);
  static const Color info = Color(0xFF007AFF);
  static const Color infoSoft = Color(0xFF0A84FF);

  // Glassmorphism Colors
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassOverlay = Color(0x1AFFFFFF);
  static const Color glassShadow = Color(0x1A000000);

  // Location & Map Colors
  static const Color locationMarker = Color(0xFF7ED957); // Green marker for map

  // Network Status Colors
  static const Color networkSlow = Color(0xFFFF8C00);      // dark orange
  static const Color networkSlowSoft = Color(0xFFFFAD33);  // soft orange

  // Merchant-Specific Colors
  static const Color merchantPrimary = Color(0xFF1976D2);
  static const Color merchantAccent = Color(0xFFFFA726);

  // Grey Shades
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey800 = Color(0xFF424242);

  // Semantic Colors
  static const Color divider = Color(0xFFE0E0E0);
    static const Color borderField = Color(0xFFFDDBB4);

  static const Color shadow = Color(0x1A000000);
}
