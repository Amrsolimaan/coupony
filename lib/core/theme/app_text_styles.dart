import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Base Font Family
  static const String fontFamily = 'Cairo';

  // --- Onboarding Header (Specific Specs Provided) ---

  static final TextStyle onboardingHeader = GoogleFonts.amiri(
    fontSize: 24.sp,
    fontWeight: FontWeight.w800, // Bold
    fontStyle: FontStyle.normal,
    height: 1.0, // line-height: 140% للعربية
    color: AppColors.primary,
  );

  // Logo Style (Pacifico - 64px)
  static final TextStyle logoStyle = GoogleFonts.pacifico(
    fontSize: 64.sp,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.5, // Line height 150%
  );

  // Headings (Matched with AppTheme)
  static final TextStyle h1 = TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static final TextStyle h2 = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static final TextStyle h3 = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static final TextStyle h4 = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  // Body Text (Matched with AppTheme)
  static final TextStyle bodyLarge = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static final TextStyle bodyMedium = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );

  static final TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );

  // Alias for generic body
  static final TextStyle body = bodyMedium;

  // Special Purpose (Matched with AppTheme)
  static final TextStyle button = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
    fontFamily: fontFamily,
  );

  static final TextStyle caption = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );

  static final TextStyle overline = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
    fontFamily: fontFamily,
  );
}
