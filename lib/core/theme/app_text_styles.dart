import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Base Font Family
  static const String fontFamily = 'Cairo';

  // --- Onboarding Header (Specific Specs Provided) ---

  // Arabic version - using Amiri font (perfect for Arabic)
  static final TextStyle onboardingHeader = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    height: 1.4,
    color: AppColors.primary,
  );

  // English version - using Nunito font (clean and modern for English)
  static final TextStyle onboardingHeaderEnglish = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 26.sp,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    height: 1.3,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  // Logo Style (Pacifico - 64px)
  static final TextStyle logoStyle = TextStyle(
    fontFamily: 'Pacifico',
    fontSize: 64.sp,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.5,
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
