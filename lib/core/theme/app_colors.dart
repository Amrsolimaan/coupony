import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors (Updated to Main Orange)
  static const Color primary = Color(0xFFFF5F01); // اللون الأساسي المطلوب
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
  static const Color textDisabled = Color(0xFFAAAAAA);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Location & Map Colors
  static const Color locationMarker = Color(0xFF7ED957); // Green marker for map

  // Merchant-Specific Colors
  static const Color merchantPrimary = Color(0xFF1976D2);
  static const Color merchantAccent = Color(0xFFFFA726);

  // Grey Shades
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey800 = Color(0xFF424242);

  // Semantic Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
}
