import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../../../../core/repositories/base_repository.dart';
import '../../../../../core/storage/local_cache_service.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/use_cases/update_profile_params.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl extends BaseRepository implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required NetworkInfo networkInfo,
    required LocalCacheService cacheService,
  }) : super(networkInfo: networkInfo, cacheService: cacheService);

  // ──────────────────────────────────────────────────────────────────────────
  // GET PROFILE
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> getProfile() {
    return executeOnlineOperation<UserEntity>(
      operation: () async {
        final result = await remoteDataSource.getProfile();
        await localDataSource.cacheStores(result.stores);
        await localDataSource.cacheStoreCreated(result.isStoreCreated);
        return result;
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // UPDATE PROFILE
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
    UpdateProfileParams params,
  ) {
    return executeOnlineOperation<UserEntity>(
      operation: () async {
        final updatedUser = await remoteDataSource.updateProfile(params);

        // Preserve the stored tokens so the cached user remains authenticated.
        final accessToken  = await localDataSource.getAccessToken();
        final refreshToken = await localDataSource.getRefreshToken();

        final userToCache = updatedUser.copyWith(
          accessToken:  accessToken,
          refreshToken: refreshToken,
        );

        await localDataSource.cacheUser(userToCache);
        return userToCache;
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DELETE ACCOUNT
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> deleteAccount(String password) {
    return executeOnlineOperation<Unit>(
      operation: () async {
        await remoteDataSource.deleteAccount(password);

        // Clear local session after successful deletion.
        await localDataSource.clearSessionFlags();
        await localDataSource.clearUser();

        return unit;
      },
    );
  }
}
