import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';
import 'dart:io';

class AppCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'app_image_cache';

  static AppCacheManager? _instance;

  factory AppCacheManager() {
    _instance ??= AppCacheManager._();
    return _instance!;
  }

  AppCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: AppConstants.mediaCacheDuration,
            maxNrOfCacheObjects: 1000,
            repo: JsonCacheInfoRepository(databaseName: key),
            fileSystem: IOFileSystem(key), // ✅ من الباكدج مباشرة
            fileService: HttpFileService(),
          ),
        );

  static Future<String> getCacheDirectory() async {
    final directory = await getTemporaryDirectory();
    return path.join(directory.path, key);
  }

  Future<double> getCacheSizeMB() async {
    try {
      final cacheDir = await getCacheDirectory(); // ✅ بنستخدمها دلوقتي
      final directory = Directory(cacheDir);      // ✅ مش بنكررها

      if (!await directory.exists()) return 0.0;

      int totalSize = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }

  Future<bool> isNearQuota() async {
    final sizeMB = await getCacheSizeMB();
    return sizeMB > (AppConstants.maxMediaCacheSizeMB * 0.8);
  }

  Future<void> clearCache() async {
    await emptyCache();
  }
}

// ✅ الكلاس الكاستم اتحذفت خالص
