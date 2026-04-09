import 'dart:async' show unawaited;

import 'package:coupony/core/errors/exceptions.dart';
import 'package:coupony/core/errors/failures.dart';
import 'package:coupony/core/network/network_info.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/public_category.dart';
import '../../domain/entities/public_product.dart';
import '../../domain/repositories/public_products_repository.dart';
import '../../domain/use_cases/get_category_products_use_case.dart';
import '../../domain/use_cases/get_public_products_use_case.dart';
import '../datasources/public_products_local_data_source.dart';
import '../datasources/public_products_remote_data_source.dart';

class PublicProductsRepositoryImpl implements PublicProductsRepository {
  final PublicProductsRemoteDataSource remoteDataSource;
  final PublicProductsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  const PublicProductsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.logger,
  });

  // ── LIST PUBLIC PRODUCTS ───────────────────────────────

  /// Whether [params] qualifies as an unfiltered page-1 request.
  bool _isPage1Unfiltered(GetPublicProductsParams params) =>
      params.page == 1 &&
      params.categoryId == null &&
      params.search == null &&
      params.featured == null;

  @override
  Future<Either<Failure, PaginatedResult<PublicProduct>>> getPublicProducts(
    GetPublicProductsParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      // Offline: serve page-1 from cache when available
      if (_isPage1Unfiltered(params)) {
        try {
          final cached = await localDataSource.getCachedProductsPage1();
          logger.i('📦 Offline — serving page-1 products from cache');
          return Right(cached);
        } on CacheException {
          // Fall through to network error
        }
      }
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }
    try {
      final result = await remoteDataSource.getPublicProducts(params);

      // Cache page-1 unfiltered for offline use (fire-and-forget)
      if (_isPage1Unfiltered(params)) {
        unawaited(localDataSource.cacheProductsPage1(result));
      }

      return Right(result);
    } catch (e) {
      logger.e('getPublicProducts failed: $e');
      return Left(_mapToFailure(e));
    }
  }

  // ── PRODUCT DETAILS — API-first, local fallback ────────

  @override
  Future<Either<Failure, PublicProduct>> getProductDetails(
    String productId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final product = await remoteDataSource.getProductDetails(productId);

        // Cache on successful fetch (fire-and-forget)
        unawaited(localDataSource.cacheProductDetail(product));

        return Right(product);
      } on ServerException catch (e) {
        return _fallbackToLocalDetail(productId, e.message);
      } catch (e) {
        return _fallbackToLocalDetail(productId, e.toString());
      }
    } else {
      return _fallbackToLocalDetail(productId, 'error_no_internet_check_network');
    }
  }

  Future<Either<Failure, PublicProduct>> _fallbackToLocalDetail(
    String productId,
    String apiError,
  ) async {
    try {
      final cached = await localDataSource.getCachedProductDetail(productId);
      logger.i('📦 Serving product $productId from cache (API error: $apiError)');
      return Right(cached);
    } on CacheException {
      return Left(ServerFailure(apiError));
    }
  }

  // ── CATEGORIES — API-first, local fallback (1-week TTL) ─

  @override
  Future<Either<Failure, List<PublicCategory>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getCategories();

        // Cache successful response (fire-and-forget)
        unawaited(localDataSource.cacheCategories(categories));

        return Right(categories);
      } on ServerException catch (e) {
        return _fallbackToLocalCategories(e.message);
      } catch (e) {
        return _fallbackToLocalCategories(e.toString());
      }
    } else {
      return _fallbackToLocalCategories('error_no_internet_check_network');
    }
  }

  Future<Either<Failure, List<PublicCategory>>> _fallbackToLocalCategories(
    String apiError,
  ) async {
    try {
      final cached = await localDataSource.getCachedCategories();
      logger.i('📦 Serving ${cached.length} categories from cache '
          '(API error: $apiError)');
      return Right(cached);
    } on CacheException {
      return Left(ServerFailure(apiError));
    }
  }

  // ── CATEGORY PRODUCTS ──────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<PublicProduct>>> getCategoryProducts(
    GetCategoryProductsParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }
    try {
      final result = await remoteDataSource.getCategoryProducts(params);
      return Right(result);
    } catch (e) {
      logger.e('getCategoryProducts failed: $e');
      return Left(_mapToFailure(e));
    }
  }

  // ── FAILURE MAPPING ────────────────────────────────────

  Failure _mapToFailure(dynamic error) {
    final inner = (error is DioException) ? (error.error ?? error) : error;

    if (inner is UnauthorizedException) return UnauthorizedFailure(inner.message);
    if (inner is NotFoundException) return const ServerFailure('error_not_found');
    if (inner is ValidationException) return ValidationFailure(inner.message);
    if (inner is ServerException) return ServerFailure(inner.message);
    if (inner is NetworkException) return NetworkFailure(inner.message);
    if (error is DioException) {
      return ServerFailure('HTTP ${error.response?.statusCode}: ${error.message}');
    }
    return ServerFailure(error.toString());
  }
}
