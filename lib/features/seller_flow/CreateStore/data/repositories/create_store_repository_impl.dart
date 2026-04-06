import 'package:coupony/core/errors/exceptions.dart';
import 'package:coupony/core/errors/failures.dart';
import 'package:coupony/core/network/network_info.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/social_platform_entity.dart';
import '../../domain/repositories/create_store_repository.dart';
import '../../domain/use_cases/create_store_use_case.dart';
import '../data_sources/create_store_remote_data_source.dart';

class CreateStoreRepositoryImpl implements CreateStoreRepository {
  final CreateStoreRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  const CreateStoreRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.logger,
  });

  @override
  Future<Either<Failure, bool>> createStore(CreateStoreParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }

    try {
      final result = await remoteDataSource.createStore(params);
      return Right(result);
    } catch (e) {
      logger.e('CreateStore failed: $e');
      return Left(_mapToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }

    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      logger.e('GetCategories failed: type=${e.runtimeType}, error=$e');
      if (e is DioException) {
        logger.e(
          'DioException → status=${e.response?.statusCode}, '
          'innerType=${e.error?.runtimeType}, inner=${e.error}',
        );
      }
      return Left(_mapToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<SocialPlatformEntity>>> getSocialPlatforms() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }

    try {
      final platforms = await remoteDataSource.getSocialPlatforms();
      return Right(platforms);
    } catch (e) {
      logger.e('GetSocialPlatforms failed: type=${e.runtimeType}, error=$e');
      if (e is DioException) {
        logger.e(
          'DioException → status=${e.response?.statusCode}, '
          'innerType=${e.error?.runtimeType}, inner=${e.error}',
        );
      }
      return Left(_mapToFailure(e));
    }
  }

  /// Unwraps [DioException] (the error interceptor wraps our custom exceptions
  /// inside it) and maps to the appropriate [Failure] subtype.
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
      return ServerFailure('HTTP ${error.response?.statusCode}: ${error.message}');
    }
    return ServerFailure(error.toString());
  }
}
