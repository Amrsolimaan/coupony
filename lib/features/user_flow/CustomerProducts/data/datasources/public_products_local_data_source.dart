import 'dart:convert';

import 'package:coupony/core/constants/app_constants.dart';
import 'package:coupony/core/constants/storage_keys.dart';
import 'package:coupony/core/errors/exceptions.dart';
import 'package:coupony/core/storage/local_cache_service.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/paginated_result.dart';
import '../models/public_category_model.dart';
import '../models/public_product_model.dart';

// ════════════════════════════════════════════════════════
// ABSTRACT
// ════════════════════════════════════════════════════════

abstract class PublicProductsLocalDataSource {
  /// Returns cached categories (2-hour TTL). Throws [CacheException] on miss.
  Future<List<PublicCategoryModel>> getCachedCategories();

  /// Caches the categories list.
  Future<void> cacheCategories(List<PublicCategoryModel> categories);

  /// Returns a cached product detail by ID (30-min TTL). Throws on miss.
  Future<PublicProductModel> getCachedProductDetail(String productId);

  /// Caches a single product detail.
  Future<void> cacheProductDetail(PublicProductModel product);

  /// Returns the cached page-1 unfiltered products (30-min TTL).
  /// Throws [CacheException] on miss. Used as offline-first fallback.
  Future<PaginatedResult<PublicProductModel>> getCachedProductsPage1();

  /// Caches the page-1 unfiltered products result for offline use.
  Future<void> cacheProductsPage1(PaginatedResult<PublicProductModel> result);
}

// ════════════════════════════════════════════════════════
// IMPLEMENTATION
// ════════════════════════════════════════════════════════

class PublicProductsLocalDataSourceImpl
    implements PublicProductsLocalDataSource {
  final LocalCacheService cacheService;
  final Logger logger;

  const PublicProductsLocalDataSourceImpl({
    required this.cacheService,
    required this.logger,
  });

  // ── CATEGORIES ─────────────────────────────────────────

  @override
  Future<List<PublicCategoryModel>> getCachedCategories() async {
    try {
      final raw = await cacheService.get<String>(
        boxName: StorageKeys.categoriesBox,
        key: StorageKeys.publicCategoriesList,
        maxAge: AppConstants.categoriesCacheDuration,
      );

      if (raw == null) {
        throw const CacheException('No cached categories');
      }

      final list = jsonDecode(raw) as List<dynamic>;
      final categories = list
          .map((j) =>
              PublicCategoryModel.fromJson(j as Map<String, dynamic>))
          .toList();

      logger.d('📦 Loaded ${categories.length} categories from cache');
      return categories;
    } on CacheException {
      rethrow;
    } catch (e) {
      logger.w('⚠️ getCachedCategories error: $e');
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheCategories(List<PublicCategoryModel> categories) async {
    try {
      final raw = jsonEncode(categories.map((c) => c.toJson()).toList());
      await cacheService.put<String>(
        boxName: StorageKeys.categoriesBox,
        key: StorageKeys.publicCategoriesList,
        value: raw,
      );
      logger.d('💾 Cached ${categories.length} categories');
    } catch (e) {
      logger.w('⚠️ cacheCategories error (non-fatal): $e');
    }
  }

  // ── PRODUCT DETAIL ─────────────────────────────────────

  @override
  Future<PublicProductModel> getCachedProductDetail(String productId) async {
    final key = '${StorageKeys.publicProductDetailPrefix}$productId';
    try {
      final raw = await cacheService.get<String>(
        boxName: StorageKeys.publicProductsBox,
        key: key,
        maxAge: AppConstants.productDetailCacheDuration, // 30 min TTL
      );

      if (raw == null) {
        throw CacheException('No cached detail for product $productId');
      }

      logger.d('📦 Loaded product detail from cache: id=$productId');
      return PublicProductModel.decode(raw);
    } on CacheException {
      rethrow;
    } catch (e) {
      logger.w('⚠️ getCachedProductDetail error: $e');
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheProductDetail(PublicProductModel product) async {
    final key = '${StorageKeys.publicProductDetailPrefix}${product.id}';
    try {
      await cacheService.put<String>(
        boxName: StorageKeys.publicProductsBox,
        key: key,
        value: product.encode(),
      );
      logger.d('💾 Cached product detail: id=${product.id}');
    } catch (e) {
      logger.w('⚠️ cacheProductDetail error (non-fatal): $e');
    }
  }

  // ── PAGE-1 OFFLINE CACHE ────────────────────────────────

  @override
  Future<PaginatedResult<PublicProductModel>> getCachedProductsPage1() async {
    try {
      final raw = await cacheService.get<String>(
        boxName: StorageKeys.publicProductsBox,
        key: StorageKeys.publicProductsPage1Key,
        maxAge: AppConstants.productDetailCacheDuration, // 30 min TTL
      );

      if (raw == null) {
        throw const CacheException('No cached page-1 products');
      }

      final map = jsonDecode(raw) as Map<String, dynamic>;
      final itemsList = map['items'] as List<dynamic>;
      final items = itemsList
          .map((j) => PublicProductModel.fromJson(j as Map<String, dynamic>))
          .toList();

      final result = PaginatedResult<PublicProductModel>(
        items: items,
        currentPage: (map['currentPage'] as num).toInt(),
        lastPage: (map['lastPage'] as num).toInt(),
        perPage: (map['perPage'] as num).toInt(),
        total: (map['total'] as num).toInt(),
      );

      logger.d('📦 Loaded ${items.length} page-1 products from cache');
      return result;
    } on CacheException {
      rethrow;
    } catch (e) {
      logger.w('⚠️ getCachedProductsPage1 error: $e');
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheProductsPage1(
    PaginatedResult<PublicProductModel> result,
  ) async {
    try {
      final raw = jsonEncode({
        'items': result.items.map((p) => p.toJson()).toList(),
        'currentPage': result.currentPage,
        'lastPage': result.lastPage,
        'perPage': result.perPage,
        'total': result.total,
      });

      await cacheService.put<String>(
        boxName: StorageKeys.publicProductsBox,
        key: StorageKeys.publicProductsPage1Key,
        value: raw,
      );
      logger.d('💾 Cached ${result.items.length} page-1 products for offline use');
    } catch (e) {
      logger.w('⚠️ cacheProductsPage1 error (non-fatal): $e');
    }
  }
}
