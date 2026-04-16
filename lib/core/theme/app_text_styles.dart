import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Font Constants for Manual Usage
  static const String Main_Font_arabic = 'PlaypenSansArabic';
  static const String Sec_Font_arabic = 'Amiri';
  static const String Main_Font_english = 'Inter';
  static const String Main_Font_logo = 'Pacifico';

  // Base Font Family
  static const String fontFamily = 'Cairo';

  // ═══════════════════════════════════════════════════════════════════════════
  // DYNAMIC TEXT STYLE FACTORY
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Creates a custom TextStyle with automatic font selection based on locale.
  /// 
  /// Parameters:
  /// - [context]: Required for locale detection
  /// - [fontSize]: Font size (will be converted to .sp automatically)
  /// - [fontWeight]: Font weight (default: FontWeight.normal)
  /// - [color]: Text color (default: AppColors.textPrimary)
  /// - [height]: Line height multiplier
  /// - [letterSpacing]: Letter spacing
  /// - [fontFamily]: Custom font family (overrides automatic selection)
  /// - [useSecondaryArabic]: Use Amiri instead of NotoNaskhArabic for Arabic (ignored if fontFamily is provided)

  /// Examples:
  /// ```dart
  /// // Automatic font selection (Arabic → NotoNaskhArabic, English → Urbanist)
  /// Text(
  ///   'مرحباً',
  ///   style: AppTextStyles.customStyle(
  ///     context,
  ///     fontSize: 26,
  ///     fontWeight: FontWeight.w700,
  ///   ),
  /// )
  /// 
  /// // Use secondary Arabic font (Amiri)
  /// Text(
  ///   'عنوان',
  ///   style: AppTextStyles.customStyle(
  ///     context,
  ///     fontSize: 24,
  ///     useSecondaryArabic: true,
  ///   ),
  /// )
  /// 
  /// // Override with custom font (e.g., Pacifico for logo)
  /// Text(
  ///   'Coupony',
  ///   style: AppTextStyles.customStyle(
  ///     context,
  ///     fontSize: 64,
  ///     fontFamily: AppTextStyles.Main_Font_logo,
  ///   ),
  /// )
  /// ```
  static TextStyle customStyle(
    BuildContext context, {
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    String? fontFamily,
    bool useSecondaryArabic = false,
  }) {
    // If custom fontFamily is provided, use it directly
    String selectedFont;
    if (fontFamily != null) {
      selectedFont = fontFamily;
    } else {
      // Automatic font selection based on locale
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      if (isArabic) {
        selectedFont = useSecondaryArabic ? Sec_Font_arabic : Main_Font_arabic;
      } else {
        selectedFont = Main_Font_english;
      }
    }

    return TextStyle(
      fontFamily: selectedFont,
      fontSize: fontSize.sp,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? AppColors.textPrimary,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

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
