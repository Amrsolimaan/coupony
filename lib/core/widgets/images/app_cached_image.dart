import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../storage/app_image_cache_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/image_url_utils.dart';

// ════════════════════════════════════════════════════════════════════════════
// AppCachedImage — rectangular / general purpose
// ════════════════════════════════════════════════════════════════════════════

/// Centralised network-image widget with:
/// - Automatic URL resolution via [ImageUrlUtils.buildFullImageUrl]
/// - Shared [AppImageCacheManager] (30-min TTL, 200-object cap)
/// - Memory-size clamping via [memCacheWidth] / [memCacheHeight] to prevent OOM
/// - Shimmer loading placeholder
/// - Consistent broken-image error state
class AppCachedImage extends StatelessWidget {
  /// Raw or relative image path. Resolved via [ImageUrlUtils.buildFullImageUrl].
  final String imageUrl;

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  /// Override the shimmer placeholder with a custom widget.
  final Widget? placeholder;

  /// Override the default broken-image error icon.
  final Widget? errorWidget;

  final Color? backgroundColor;

  /// Explicit cache key. Defaults to the resolved URL when null.
  final String? cacheKey;

  /// Clamp decoded image width in memory (pixels). Use physical-pixel values.
  /// Prevents OOM when displaying small thumbnails from large source images.
  final int? memCacheWidth;

  /// Clamp decoded image height in memory (pixels).
  final int? memCacheHeight;

  /// Override the shared [AppImageCacheManager]. Useful for tests or special TTLs.
  final CacheManager? cacheManager;

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
    this.cacheKey,
    this.memCacheWidth,
    this.memCacheHeight,
    this.cacheManager,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ImageUrlUtils.buildFullImageUrl(imageUrl);

    // Empty / unresolvable URL — show error state immediately.
    if (resolvedUrl == null) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        child: _buildErrorWidget(),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12.r),
      child: Container(
        width: width,
        height: height,
        color: backgroundColor ?? AppColors.grey200,
        child: CachedNetworkImage(
          imageUrl: resolvedUrl,
          cacheKey: cacheKey ?? resolvedUrl,
          cacheManager: cacheManager ?? AppImageCacheManager(),
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
          placeholder: (context, url) =>
              placeholder ?? _buildShimmerPlaceholder(),
          errorWidget: (context, url, error) =>
              errorWidget ?? _buildErrorWidget(),
        ),
      ),
    );
  }

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

// ════════════════════════════════════════════════════════════════════════════
// AppCachedImageCircular — avatars / profile pictures
// ════════════════════════════════════════════════════════════════════════════

/// Circular variant of [AppCachedImage] for profile photos and avatars.
class AppCachedImageCircular extends StatelessWidget {
  /// Raw or relative image path. Resolved via [ImageUrlUtils.buildFullImageUrl].
  final String imageUrl;

  /// Diameter of the circular image in logical pixels.
  final double size;

  final double? borderWidth;
  final Color? borderColor;

  /// Clamp decoded image size in memory. Defaults to [size] × 2 (2× density).
  final int? memCacheWidth;
  final int? memCacheHeight;

  /// Override the shared [AppImageCacheManager].
  final CacheManager? cacheManager;

  const AppCachedImageCircular({
    super.key,
    required this.imageUrl,
    required this.size,
    this.borderWidth,
    this.borderColor,
    this.memCacheWidth,
    this.memCacheHeight,
    this.cacheManager,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ImageUrlUtils.buildFullImageUrl(imageUrl);
    final memSize = memCacheWidth ?? (size * 2).round();

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
        child: resolvedUrl != null
            ? CachedNetworkImage(
                imageUrl: resolvedUrl,
                cacheKey: resolvedUrl,
                cacheManager: cacheManager ?? AppImageCacheManager(),
                width: size,
                height: size,
                fit: BoxFit.cover,
                memCacheWidth: memSize,
                memCacheHeight: memSize,
                placeholder: (context, url) => _buildShimmerPlaceholder(),
                errorWidget: (context, url, error) => _buildErrorWidget(),
              )
            : _buildErrorWidget(),
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
      color: AppColors.error.withValues(alpha: 0.1),
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
