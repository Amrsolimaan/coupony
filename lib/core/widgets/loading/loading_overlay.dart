import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'coupony_loading_indicator.dart';

/// Loading Overlay
///
/// A reusable wrapper widget that shows a loading indicator
/// with a blur effect over the screen content.
///
/// Features:
/// - Modal barrier to prevent user interaction
/// - Blur effect for premium feel
/// - Customizable loading indicator
/// - Context-aware icons
///
/// Usage:
/// ```dart
/// LoadingOverlay(
///   isLoading: state.isSaving,
///   message: 'Saving...',
///   icon: Icons.save,
///   child: YourScreenContent(),
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  /// The screen content
  final Widget child;

  /// Whether to show the loading overlay
  final bool isLoading;

  /// Optional loading message
  final String? message;

  /// Optional icon for the loading indicator
  final IconData? icon;

  /// Optional progress value (0.0 to 1.0)
  /// If null, shows indeterminate loading
  final double? progress;

  /// Size of the loading indicator
  final double indicatorSize;

  /// Blur intensity (sigma value)
  final double blurIntensity;

  /// Background color opacity
  final double backgroundOpacity;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.icon,
    this.progress,
    this.indicatorSize = 120.0,
    this.blurIntensity = 5.0,
    this.backgroundOpacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        child,

        // Loading overlay (only shown when isLoading is true)
        if (isLoading)
          Positioned.fill(
            child: _buildLoadingOverlay(context),
          ),
      ],
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Stack(
      children: [
        // Modal barrier with blur effect
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: Container(
            color: Colors.black.withValues(alpha: backgroundOpacity),
          ),
        ),

        // Loading indicator in center
        Center(
          child: Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: CouponyLoadingIndicator(
              progress: progress ?? 0.0,
              size: indicatorSize,
              centerIcon: icon ?? Icons.hourglass_empty,
              showPercentage: progress != null,
              message: message,
            ),
          ),
        ),
      ],
    );
  }
}

/// Loading Overlay Builder
///
/// A convenience widget that automatically shows/hides loading
/// based on a condition from BlocBuilder or other state management.
///
/// Usage with Bloc:
/// ```dart
/// BlocBuilder<MyCubit, MyState>(
///   builder: (context, state) {
///     return LoadingOverlayBuilder(
///       isLoading: state.isSaving,
///       message: 'Saving preferences...',
///       icon: Icons.save,
///       child: YourScreenContent(),
///     );
///   },
/// )
/// ```
class LoadingOverlayBuilder extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final IconData? icon;
  final double? progress;

  const LoadingOverlayBuilder({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.icon,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      message: message,
      icon: icon,
      progress: progress,
      child: child,
    );
  }
}

/// Context-Aware Loading Icons
///
/// Helper class to provide appropriate icons for different contexts
class LoadingIcons {
  LoadingIcons._();

  /// Saving data locally or to server
  static const IconData saving = Icons.save_outlined;

  /// Uploading files or data
  static const IconData uploading = Icons.cloud_upload_outlined;

  /// Downloading files or data
  static const IconData downloading = Icons.cloud_download_outlined;

  /// Syncing data
  static const IconData syncing = Icons.sync;

  /// Processing or computing
  static const IconData processing = Icons.settings_outlined;

  /// Sending data (email, message, etc.)
  static const IconData sending = Icons.send_outlined;

  /// Loading general data
  static const IconData loading = Icons.hourglass_empty;

  /// Checking or verifying
  static const IconData checking = Icons.check_circle_outline;

  /// Searching
  static const IconData searching = Icons.search;

  /// Refreshing
  static const IconData refreshing = Icons.refresh;
}
