import 'package:coupony/core/errors/failures.dart';
import 'package:coupony/core/network/network_info.dart';
import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/category_entity.dart';
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
    } on Exception catch (e) {
      logger.e('CreateStore failed: $e');
      return Left(ServerFailure('error_create_store_server'));
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
    } on Exception catch (e) {
      logger.e('GetCategories failed: $e');
      return Left(ServerFailure('auth_error_server'));
    }
  }
}
