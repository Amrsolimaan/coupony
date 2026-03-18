import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Permission Constants
/// Contains all dimension constants for permission screens
/// Uses values from the original design
class PermissionConstants {
  PermissionConstants._();

  // ════════════════════════════════════════════════════════
  // ICON SIZES
  // ════════════════════════════════════════════════════════

  /// Main icon size (location, notification icons)
  static double iconSize = 120.w;

  /// Error icon size (in error screens)
  static double errorIconSize = 100.w;

  /// Small icon size (in splash screen)
  static double smallIconSize = 48.w;

  // ════════════════════════════════════════════════════════
  // SPACING
  // ════════════════════════════════════════════════════════

  /// Card internal padding
  static double cardPadding = 32.w;

  /// Large spacing between sections
  static double spacingLarge = 32.h;

  /// Medium spacing between elements
  static double spacingMedium = 24.h;

  /// Small spacing
  static double spacingSmall = 16.h;

  /// Extra small spacing
  static double spacingXSmall = 8.h;

  // ════════════════════════════════════════════════════════
  // BUTTON DIMENSIONS
  // ════════════════════════════════════════════════════════

  /// Primary button height
  static double buttonHeight = 56.h;

  /// Button border radius
  static double buttonRadius = 12.r;

  /// Button horizontal padding
  static double buttonPaddingHorizontal = 24.w;

  /// Spacing between primary and skip buttons
  static double buttonSpacing = 12.h;

  // ════════════════════════════════════════════════════════
  // CARD DIMENSIONS
  // ════════════════════════════════════════════════════════

  /// Card border radius
  static double cardRadius = 24.r;

  /// Card elevation
  static double cardElevation = 0;

  /// Card max width (for responsive design)
  static double cardMaxWidth = 500.w;

  /// Card horizontal margin
  static double cardMarginHorizontal = 24.w;

  // ════════════════════════════════════════════════════════
  // LOADING INDICATOR
  // ════════════════════════════════════════════════════════

  /// Loading progress bar height
  static double progressBarHeight = 6.h;

  /// Loading progress bar radius
  static double progressBarRadius = 3.r;

  // ════════════════════════════════════════════════════════
  // MAP SPECIFIC (for location_map_page)
  // ════════════════════════════════════════════════════════

  /// Bottom sheet height
  static double mapBottomSheetHeight = 200.h;

  /// Map marker size
  static double mapMarkerSize = 40.w;

  /// Current location button size
  static double currentLocationButtonSize = 56.w;
}
