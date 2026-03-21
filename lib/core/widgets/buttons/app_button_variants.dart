/// Button Variants and Enums
/// Defines all button types, sizes, and variants used across the app
library;

/// Button size variants
enum AppButtonSize {
  /// Small button (height: 40.h, fontSize: 14.sp)
  small,

  /// Medium button (height: 56.h, fontSize: 16.sp) - Default
  medium,

  /// Large button (height: 64.h, fontSize: 18.sp)
  large,
}

/// Icon position relative to text
enum AppButtonIconPosition {
  /// Icon before text (left in LTR, right in RTL)
  start,

  /// Icon after text (right in LTR, left in RTL)
  end,
}

/// Button variant (for future use - success, error, etc.)
enum AppButtonVariant {
  /// Primary variant (default orange)
  primary,

  /// Success variant (green)
  success,

  /// Error variant (red)
  error,

  /// Warning variant (yellow)
  warning,
}

