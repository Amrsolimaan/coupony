import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../constants/app_constants.dart';

/// App-wide image cache manager.
///
/// Tied to [AppConstants.productDetailCacheDuration] so that remote images
/// expire in sync with their JSON payloads (30 min default). Capped at 200
/// objects to prevent unbounded disk growth.
///
/// Registered as a lazy singleton in the DI container. Use via:
///   `sl<AppImageCacheManager>()`
/// or directly via the singleton factory:
///   `AppImageCacheManager()`
class AppImageCacheManager extends CacheManager with ImageCacheManager {
  static const _cacheKey = 'coupony_image_cache';

  // Singleton
  static final AppImageCacheManager _instance = AppImageCacheManager._internal();
  factory AppImageCacheManager() => _instance;

  AppImageCacheManager._internal()
      : super(
          Config(
            _cacheKey,
            stalePeriod: AppConstants.productDetailCacheDuration,
            maxNrOfCacheObjects: 200,
          ),
        );
}
