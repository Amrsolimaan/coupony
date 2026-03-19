import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';

/// App Cached Image Widget
/// Atomic component for displaying network images with caching
/// 
/// Features:
/// - Automatic caching via CachedNetworkImage
/// - Professional shimmer loading effect
/// - Error state with fallback icon
/// - Customizable border radius and fit
/// - Consistent with app theme
class AppCachedImage extends StatelessWidget {
  /// Image URL to load
  final String imageUrl;

  /// Width of the image container
  final double? width;

  /// Height of the image container
  final double? height;

  /// Border radius for rounded corners
  final BorderRadius? borderRadius;

  /// How the image should fit in the container
  final BoxFit fit;

  /// Placeholder widget during loading (if null, uses shimmer)
  final Widget? placeholder;

  /// Error widget (if null, uses default error icon)
  final Widget? errorWidget;

  /// Background color for the container
  final Color? backgroundColor;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12.r),
      child: Container(
        width: width,
        height: height,
        color: backgroundColor ?? AppColors.grey200,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) =>
              placeholder ?? _buildShimmerPlaceholder(),
          errorWidget: (context, url, error) =>
              errorWidget ?? _buildErrorWidget(),
        ),
      ),
    );
  }

  /// Build shimmer loading effect
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        color: AppColors.grey200,
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppColors.error.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.error,
          size: 48.w,
        ),
      ),
    );
  }
}

/// Circular variant for profile pictures, avatars, etc.
class AppCachedImageCircular extends StatelessWidget {
  /// Image URL to load
  final String imageUrl;

  /// Diameter of the circular image
  final double size;

  /// Border width (optional)
  final double? borderWidth;

  /// Border color (optional)
  final Color? borderColor;

  const AppCachedImageCircular({
    super.key,
    required this.imageUrl,
    required this.size,
    this.borderWidth,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth != null
            ? Border.all(
                color: borderColor ?? AppColors.primary,
                width: borderWidth!,
              )
            : null,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildShimmerPlaceholder(),
          errorWidget: (context, url, error) => _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.surface,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.grey200,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.error.withValues(alpha: 0.1),
      ),
      child: Center(
        child: Icon(
          Icons.person_outline,
          color: AppColors.error,
          size: size * 0.5,
        ),
      ),
    );
  }
}
