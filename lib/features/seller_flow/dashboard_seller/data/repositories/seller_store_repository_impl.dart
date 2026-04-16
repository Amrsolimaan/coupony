import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../../../auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/store_display_entity.dart';
import '../../domain/repositories/seller_store_repository.dart';
import '../../domain/use_cases/update_store_profile_use_case.dart';
import '../datasources/seller_store_remote_data_source.dart';

// ════════════════════════════════════════════════════════
// SELLER STORE REPOSITORY IMPLEMENTATION
// ════════════════════════════════════════════════════════

class SellerStoreRepositoryImpl implements SellerStoreRepository {
  final SellerStoreRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;
  final AuthLocalDataSource authLocalDataSource;

  const SellerStoreRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.logger,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, StoreDisplayEntity>> getStoreDisplay() async {
    // Check network connectivity
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }

    try {
      // Fetch stores from API
      final stores = await remoteDataSource.getStores();

      // Check if user has any stores
      if (stores.isEmpty) {
        logger.w('⚠️ No stores found for this user');
        return const Left(ServerFailure('No stores found for this user'));
      }

      // Get the selected store ID from local storage
      final selectedStoreId = await authLocalDataSource.getSelectedStoreId();
      
      // If a store is selected, find it in the list
      if (selectedStoreId != null && selectedStoreId.isNotEmpty) {
        try {
          final selectedStore = stores.firstWhere(
            (store) => store.id == selectedStoreId,
          );
          logger.i('✅ Found selected store: ${selectedStore.name} (ID: $selectedStoreId)');
          return Right(selectedStore);
        } catch (e) {
          logger.w('⚠️ Selected store (ID: $selectedStoreId) not found in list, using fallback');
        }
      } else {
        logger.w('⚠️ No selected store ID found, using fallback');
      }

      // Fallback 1: Try to find the first active store
      try {
        final activeStore = stores.firstWhere(
          (store) => store.status == 'active',
        );
        logger.i('✅ Using first active store: ${activeStore.name}');
        return Right(activeStore);
      } catch (e) {
        logger.w('⚠️ No active store found, using first store in list');
      }

      // Fallback 2: Return the first store in the list
      logger.i('✅ Using first store: ${stores.first.name}');
      return Right(stores.first);
    } catch (e) {
      logger.e('❌ GetStoreDisplay failed: $e');
      return Left(_mapToFailure(e));
    }
  }

  @override
  Future<Either<Failure, StoreDisplayEntity>> updateStoreProfile(
    UpdateStoreProfileParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('error_no_internet_check_network'));
    }
    try {
      final updated = await remoteDataSource.updateStoreProfile(params);
      logger.i('✅ Store profile updated: ${updated.name}');
      return Right(updated);
    } catch (e) {
      logger.e('❌ updateStoreProfile failed: $e');
      return Left(_mapToFailure(e));
    }
  }

  /// Maps exceptions to appropriate Failure types.
  /// Unwraps DioException to get the inner exception.
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
