import 'package:coupony/core/errors/exceptions.dart';
import 'package:coupony/core/errors/failures.dart';
import 'package:coupony/core/network/network_info.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/seller_products_repository.dart';
import '../../domain/use_cases/create_product_use_case.dart';
import '../../domain/use_cases/list_products_use_case.dart';
import '../../domain/use_cases/update_product_use_case.dart';
import '../datasources/seller_products_remote_data_source.dart';

class SellerProductsRepositoryImpl implements SellerProductsRepository {
  final SellerProductsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  const SellerProductsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.logger,
  });

  // ── LIST ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Product>>> listProducts(
    ListProductsParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }
    try {
      final products = await remoteDataSource.listProducts(params);
      return Right(products);
    } catch (e) {
      logger.e('ListProducts failed: $e');
      return Left(_mapToFailure(e));
    }
  }

  // ── CREATE ────────────────────────────────────────────

  @override
  Future<Either<Failure, Product>> createProduct(
    CreateProductParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }
    try {
      final product = await remoteDataSource.createProduct(params);
      return Right(product);
    } catch (e) {
      logger.e('CreateProduct failed: $e');
      return Left(_mapToFailure(e));
    }
  }

  // ── GET ONE ───────────────────────────────────────────

  @override
  Future<Either<Failure, Product>> getProduct({
    required String storeId,
    required String productId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }
    try {
      final product = await remoteDataSource.getProduct(
        storeId: storeId,
        productId: productId,
      );
      return Right(product);
    } catch (e) {
      logger.e('GetProduct failed: $e');
      return Left(_mapToFailure(e));
    }
  }

  // ── UPDATE ────────────────────────────────────────────

  @override
  Future<Either<Failure, Product>> updateProduct(
    UpdateProductParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }
    try {
      final product = await remoteDataSource.updateProduct(params);
      return Right(product);
    } catch (e) {
      logger.e('UpdateProduct failed: $e');
      return Left(_mapToFailure(e));
    }
  }

  // ── UPDATE STATUS ─────────────────────────────────────

  @override
  Future<Either<Failure, Product>> updateProductStatus({
    required String storeId,
    required String productId,
    required String status,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }
    try {
      final product = await remoteDataSource.updateProductStatus(
        storeId: storeId,
        productId: productId,
        status: status,
      );
      return Right(product);
    } catch (e) {
      logger.e('UpdateProductStatus failed: $e');
      return Left(_mapToFailure(e));
    }
  }

  // ── DELETE ────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> deleteProduct({
    required String storeId,
    required String productId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }
    try {
      await remoteDataSource.deleteProduct(
        storeId: storeId,
        productId: productId,
      );
      return const Right(null);
    } catch (e) {
      logger.e('DeleteProduct failed: $e');
      return Left(_mapToFailure(e));
    }
  }

  // ── HELPER ────────────────────────────────────────────

  Failure _mapToFailure(dynamic error) {
    final inner = (error is DioException) ? (error.error ?? error) : error;

    if (inner is UnauthorizedException) {
      return UnauthorizedFailure(inner.message);
    }
    if (inner is NotFoundException) {
      return const ServerFailure('error_not_found');
    }
    if (inner is ValidationException) {
      return ValidationFailure(inner.message);
    }
    if (inner is ServerException) {
      return ServerFailure(inner.message);
    }
    if (inner is NetworkException) {
      return NetworkFailure(inner.message);
    }
    if (error is DioException) {
      return ServerFailure(
          'HTTP ${error.response?.statusCode}: ${error.message}');
    }
    return ServerFailure(error.toString());
  }
}
