import 'package:coupony/core/constants/api_constants.dart';
import 'package:coupony/core/errors/exceptions.dart';
import 'package:coupony/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../domain/use_cases/create_product_use_case.dart';
import '../../domain/use_cases/list_products_use_case.dart';
import '../../domain/use_cases/update_product_use_case.dart';
import '../models/product_model.dart';

// ════════════════════════════════════════════════════════
// ABSTRACT
// ════════════════════════════════════════════════════════

abstract class SellerProductsRemoteDataSource {
  Future<List<ProductModel>> listProducts(ListProductsParams params);
  Future<ProductModel> createProduct(CreateProductParams params);
  Future<ProductModel> getProduct({
    required String storeId,
    required String productId,
  });
  Future<ProductModel> updateProduct(UpdateProductParams params);
  Future<ProductModel> updateProductStatus({
    required String storeId,
    required String productId,
    required String status,
  });
  Future<void> deleteProduct({
    required String storeId,
    required String productId,
  });
}

// ════════════════════════════════════════════════════════
// IMPLEMENTATION
// ════════════════════════════════════════════════════════

class SellerProductsRemoteDataSourceImpl
    implements SellerProductsRemoteDataSource {
  final DioClient client;
  final Logger logger;

  const SellerProductsRemoteDataSourceImpl({
    required this.client,
    required this.logger,
  });

  // ── LIST ──────────────────────────────────────────────

  @override
  Future<List<ProductModel>> listProducts(ListProductsParams params) async {
    final endpoint = ApiConstants.storeProducts(params.storeId);
    try {
      logger.i('📥 GET $endpoint | status=${params.status} '
          'search=${params.search} is_featured=${params.isFeatured} '
          'per_page=${params.perPage}');

      final queryParams = <String, dynamic>{
        'per_page': params.perPage,
        if (params.status != null && params.status!.isNotEmpty)
          'status': params.status,
        if (params.search != null && params.search!.isNotEmpty)
          'search': params.search,
        if (params.isFeatured != null)
          'is_featured': params.isFeatured! ? '1' : '0',
      };

      final response = await client.get(
        endpoint,
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      final list = data['data'] as List<dynamic>? ?? [];

      logger.i('✅ LIST PRODUCTS — ${list.length} items returned');

      return list
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ LIST PRODUCTS ERROR: ${e.response?.statusCode} — '
          '${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ LIST PRODUCTS UNEXPECTED: $e');
      throw ServerException(e.toString());
    }
  }

  // ── CREATE ────────────────────────────────────────────

  @override
  Future<ProductModel> createProduct(CreateProductParams params) async {
    final endpoint = ApiConstants.storeProducts(params.storeId);
    try {
      logger.i('📤 POST $endpoint — creating product "${params.title}"');

      final formData = await ProductModel.toCreateFormData(params);

      // Detailed log for method-spoofing verification
      logger.d('📋 FormData fields:');
      for (final f in formData.fields) {
        logger.d('   ${f.key} = ${f.value}');
      }
      logger.d('📎 FormData files: ${formData.files.map((f) => f.key).toList()}');

      final response = await client.post(
        endpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final responseData = response.data as Map<String, dynamic>? ?? {};
      final productJson =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      logger.i('✅ CREATE PRODUCT — id=${productJson['id']}');
      return ProductModel.fromJson(productJson);
    } on DioException catch (e) {
      logger.e('❌ CREATE PRODUCT ERROR: ${e.response?.statusCode} — '
          '${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ CREATE PRODUCT UNEXPECTED: $e');
      throw ServerException(e.toString());
    }
  }

  // ── GET ONE ───────────────────────────────────────────

  @override
  Future<ProductModel> getProduct({
    required String storeId,
    required String productId,
  }) async {
    final endpoint = ApiConstants.storeProductById(storeId, productId);
    try {
      logger.i('📥 GET $endpoint');

      final response = await client.get(endpoint);
      final responseData = response.data as Map<String, dynamic>? ?? {};
      final productJson =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      logger.i('✅ GET PRODUCT — id=$productId');
      return ProductModel.fromJson(productJson);
    } on DioException catch (e) {
      logger.e('❌ GET PRODUCT ERROR: ${e.response?.statusCode} — '
          '${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ GET PRODUCT UNEXPECTED: $e');
      throw ServerException(e.toString());
    }
  }

  // ── UPDATE (PUT/JSON) ──────────────────────────────────

  @override
  Future<ProductModel> updateProduct(UpdateProductParams params) async {
    final endpoint =
        ApiConstants.storeProductById(params.storeId, params.productId);
    try {
      logger.i('📝 PUT $endpoint — updating product "${params.productId}"');

      final body = ProductModel.toUpdateJson(params);
      logger.d('📋 Update body: $body');

      final response = await client.put(endpoint, data: body);
      final responseData = response.data as Map<String, dynamic>? ?? {};
      final productJson =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      logger.i('✅ UPDATE PRODUCT — id=${params.productId}');
      return ProductModel.fromJson(productJson);
    } on DioException catch (e) {
      logger.e('❌ UPDATE PRODUCT ERROR: ${e.response?.statusCode} — '
          '${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ UPDATE PRODUCT UNEXPECTED: $e');
      throw ServerException(e.toString());
    }
  }

  // ── UPDATE STATUS (POST + _method=PATCH) ──────────────

  @override
  Future<ProductModel> updateProductStatus({
    required String storeId,
    required String productId,
    required String status,
  }) async {
    final endpoint =
        ApiConstants.storeProductStatus(storeId, productId);
    try {
      logger.i('🔄 POST $endpoint — spoofing PATCH, status="$status"');

      final formData = ProductModel.toStatusFormData(status);

      // Log all fields for method-spoofing verification
      logger.d('📋 FormData fields (status update):');
      for (final f in formData.fields) {
        logger.d('   ${f.key} = ${f.value}');
      }

      final response = await client.post(
        endpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final responseData = response.data as Map<String, dynamic>? ?? {};
      final productJson =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      logger.i('✅ UPDATE STATUS — id=$productId status=$status');
      return ProductModel.fromJson(productJson);
    } on DioException catch (e) {
      logger.e('❌ UPDATE STATUS ERROR: ${e.response?.statusCode} — '
          '${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ UPDATE STATUS UNEXPECTED: $e');
      throw ServerException(e.toString());
    }
  }

  // ── DELETE ────────────────────────────────────────────

  @override
  Future<void> deleteProduct({
    required String storeId,
    required String productId,
  }) async {
    final endpoint = ApiConstants.storeProductById(storeId, productId);
    try {
      logger.i('🗑️  DELETE $endpoint');

      await client.delete(endpoint);

      logger.i('✅ DELETE PRODUCT — id=$productId');
    } on DioException catch (e) {
      logger.e('❌ DELETE PRODUCT ERROR: ${e.response?.statusCode} — '
          '${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ DELETE PRODUCT UNEXPECTED: $e');
      throw ServerException(e.toString());
    }
  }

  // ── HELPER ────────────────────────────────────────────

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
