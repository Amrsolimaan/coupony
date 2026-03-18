import 'package:dartz/dartz.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../models/permission_status_model.dart';

/// Permission Local Data Source
/// Handles saving/loading permission status from Hive
abstract class PermissionLocalDataSource {
  /// Get saved permission status from local storage
  Future<Either<Failure, PermissionStatusModel?>> getPermissionStatus();

  /// Save permission status to local storage
  Future<Either<Failure, void>> savePermissionStatus(
    PermissionStatusModel model,
  );

  /// Clear all permission data (e.g., on logout)
  Future<Either<Failure, void>> clearPermissionStatus();
}

class PermissionLocalDataSourceImpl implements PermissionLocalDataSource {
  final LocalCacheService cacheService;

  PermissionLocalDataSourceImpl({required this.cacheService});

  @override
  Future<Either<Failure, PermissionStatusModel?>> getPermissionStatus() async {
    try {
      final model = await cacheService.get<PermissionStatusModel>(
        boxName: StorageKeys.permissionsBox,
        key: StorageKeys.permissionStatusKey,
      );

      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get permission status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> savePermissionStatus(
    PermissionStatusModel model,
  ) async {
    try {
      // Skip timestamp for permissions (they don't need TTL validation)
      await cacheService.put<PermissionStatusModel>(
        boxName: StorageKeys.permissionsBox,
        key: StorageKeys.permissionStatusKey,
        value: model,
        skipTimestamp: true, // Permissions don't expire
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to save permission status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearPermissionStatus() async {
    try {
      await cacheService.delete(
        boxName: StorageKeys.permissionsBox,
        key: StorageKeys.permissionStatusKey,
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to clear permission status: $e'));
    }
  }
}
