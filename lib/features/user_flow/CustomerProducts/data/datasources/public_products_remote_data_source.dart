import 'package:coupony/core/constants/api_constants.dart';
import 'package:coupony/core/errors/exceptions.dart';
import 'package:coupony/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/use_cases/get_category_products_use_case.dart';
import '../../domain/use_cases/get_public_products_use_case.dart';
import '../models/public_category_model.dart';
import '../models/public_product_model.dart';

// ════════════════════════════════════════════════════════
// ABSTRACT
// ════════════════════════════════════════════════════════

abstract class PublicProductsRemoteDataSource {
  Future<PaginatedResult<PublicProductModel>> getPublicProducts(
    GetPublicProductsParams params,
  );
  Future<PublicProductModel> getProductDetails(String productId);
  Future<List<PublicCategoryModel>> getCategories();
  Future<PaginatedResult<PublicProductModel>> getCategoryProducts(
    GetCategoryProductsParams params,
  );
}

// ════════════════════════════════════════════════════════
// IMPLEMENTATION
// ════════════════════════════════════════════════════════

class PublicProductsRemoteDataSourceImpl
    implements PublicProductsRemoteDataSource {
  final DioClient client;
  final Logger logger;

  const PublicProductsRemoteDataSourceImpl({
    required this.client,
    required this.logger,
  });

  // ── LIST PUBLIC PRODUCTS ───────────────────────────────

  @override
  Future<PaginatedResult<PublicProductModel>> getPublicProducts(
    GetPublicProductsParams params,
  ) async {
    const endpoint = ApiConstants.publicProducts;
    try {
      final query = <String, dynamic>{
        'page': params.page,
        'per_page': params.perPage,
        if (params.categoryId != null && params.categoryId!.isNotEmpty)
          'category': params.categoryId,
        if (params.search != null && params.search!.isNotEmpty)
          'search': params.search,
        if (params.featured != null)
          'featured': params.featured! ? '1' : '0',
      };

      logger.i('📥 GET $endpoint | page=${params.page} '
          'category=${params.categoryId} search=${params.search} '
          'featured=${params.featured} per_page=${params.perPage}');

      final response = await client.get(endpoint, queryParameters: query);

      final result = _parsePaginatedResponse(response.data);
      logger.i('✅ LIST PUBLIC PRODUCTS — page=${params.page} '
          'total=${result.total} items=${result.items.length}');
      return result;
    } on DioException catch (e) {
      logger.e('❌ LIST PUBLIC PRODUCTS ERROR: ${e.response?.statusCode} — '
          '${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ LIST PUBLIC PRODUCTS UNEXPECTED: $e');
      throw ServerException(e.toString());
    }
  }

  // ── SHOW PUBLIC PRODUCT ────────────────────────────────

  @override
  Future<PublicProductModel> getProductDetails(String productId) async {
    final endpoint = ApiConstants.publicProductById(productId);
    try {
      logger.i('📥 GET $endpoint');

      final response = await client.get(endpoint);
      final responseData = response.data as Map<String, dynamic>? ?? {};
      final productJson =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      logger.i('✅ GET PUBLIC PRODUCT — id=$productId');
      return PublicProductModel.fromJson(productJson);
    } on DioException catch (e) {
      logger.e('❌ GET PUBLIC PRODUCT ERROR: ${e.response?.statusCode} — '
          '${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ GET PUBLIC PRODUCT UNEXPECTED: $e');
      throw ServerException(e.toString());
    }
  }

  // ── LIST CATEGORIES ─────────────────────────────────────

  @override
  Future<List<PublicCategoryModel>> getCategories() async {
    const endpoint = ApiConstants.publicCategories;
    try {
      logger.i('📥 GET $endpoint');

      final response = await client.get(endpoint);
      final data = response.data;

      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        list = data['data'] as List;
      } else {
        list = [];
      }

      final categories = list
          .map((j) =>
              PublicCategoryModel.fromJson(j as Map<String, dynamic>))
          .toList();

      logger.i('✅ LIST CATEGORIES — ${categories.length} items');
      return categories;
    } on DioException catch (e) {
      logger.e('❌ LIST CATEGORIES ERROR: ${e.response?.statusCode} — '
          '${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ LIST CATEGORIES UNEXPECTED: $e');
      throw ServerException(e.toString());
    }
  }

  // ── LIST CATEGORY PRODUCTS ─────────────────────────────

  @override
  Future<PaginatedResult<PublicProductModel>> getCategoryProducts(
    GetCategoryProductsParams params,
  ) async {
    final endpoint = ApiConstants.publicCategoryProducts(params.categoryId);
    try {
      final query = <String, dynamic>{
        'page': params.page,
        'per_page': params.perPage,
      };

      logger.i('📥 GET $endpoint | page=${params.page} '
          'per_page=${params.perPage}');

      final response = await client.get(endpoint, queryParameters: query);

      final result = _parsePaginatedResponse(response.data);
      logger.i('✅ LIST CATEGORY PRODUCTS — '
          'category=${params.categoryId} page=${params.page} '
          'total=${result.total} items=${result.items.length}');
      return result;
    } on DioException catch (e) {
      logger.e('❌ LIST CATEGORY PRODUCTS ERROR: ${e.response?.statusCode} — '
          '${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ LIST CATEGORY PRODUCTS UNEXPECTED: $e');
      throw ServerException(e.toString());
    }
  }

  // ── HELPERS ────────────────────────────────────────────

  /// Parse a standard Laravel paginated response:
  /// { "data": [...], "meta": { "current_page": 1, "last_page": 3, ... } }
  /// or the data directly as a list.
  PaginatedResult<PublicProductModel> _parsePaginatedResponse(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return PaginatedResult(
        items: [],
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 0,
      );
    }

    final dataField = raw['data'];
    final List<dynamic> list =
        dataField is List ? dataField : [];

    final items = list
        .map((j) => PublicProductModel.fromJson(j as Map<String, dynamic>))
        .toList();

    // Pagination meta can be at root level or nested under 'meta'
    final meta = raw['meta'] as Map<String, dynamic>? ??
        raw['pagination'] as Map<String, dynamic>? ??
        raw;

    return PaginatedResult(
      items: items,
      currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
      perPage: (meta['per_page'] as num?)?.toInt() ?? 15,
      total: (meta['total'] as num?)?.toInt() ?? items.length,
    );
  }

  Never _rethrow(DioException e) {
    if (e.error is ValidationException) throw e.error as ValidationException;
    if (e.error is UnauthorizedException) throw e.error as UnauthorizedException;
    if (e.error is NotFoundException) throw e.error as NotFoundException;
    if (e.error is ServerException) throw e.error as ServerException;

    final data = e.response?.data;
    final message = (data is Map<String, dynamic>)
        ? data['message'] as String? ?? 'Network error'
        : 'Network error';
    throw ServerException(message);
  }
}
