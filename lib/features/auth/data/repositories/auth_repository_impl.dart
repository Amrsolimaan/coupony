import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NotificationService notificationService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.notificationService,
    required NetworkInfo networkInfo,
    required LocalCacheService cacheService,
  }) : super(networkInfo: networkInfo, cacheService: cacheService);

  // ════════════════════════════════════════════════════════
  // AUTH OPERATIONS
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  }) async {
    return executeOnlineOperation<UserEntity>(
      operation: () async {
        final user = await remoteDataSource.login(
          phone: phone,
          password: password,
        );
        await _persistUserAndRegisterFcm(user);
        return user;
      },
    );
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  }) async {
    return executeOnlineOperation<UserEntity>(
      operation: () async {
        final user = await remoteDataSource.register(
          name: name,
          email: email,
          password: password,
          phone: phone,
          role: role,
        );
        // Only persist if backend returned a token (auto-login after register)
        if (user.token != null) {
          await _persistUserAndRegisterFcm(user);
        }
        return user;
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> sendOtp(String phone) async {
    return executeOnlineOperation<Unit>(
      operation: () async {
        await remoteDataSource.sendOtp(phone);
        return unit;
      },
    );
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return executeOnlineOperation<UserEntity>(
      operation: () async {
        final user = await remoteDataSource.verifyOtp(
          phone: phone,
          otp: otp,
        );
        await _persistUserAndRegisterFcm(user);
        return user;
      },
    );
  }

  @override
  Future<Either<Failure, UserEntity>> refreshToken() async {
    try {
      final storedRefreshToken = await localDataSource.getRefreshToken();
      if (storedRefreshToken == null) {
        return const Left(UnauthorizedFailure('No refresh token stored'));
      }
      return executeOnlineOperation<UserEntity>(
        operation: () async {
          final user = await remoteDataSource.refreshToken(storedRefreshToken);
          await localDataSource.cacheUser(user);
          return user;
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAuthStatus() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null);
    } catch (_) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        // Best-effort API call — don't await failure
        await remoteDataSource.logout(token);
      }
      // Delete FCM token from Firebase (non-blocking)
      notificationService.deleteFCMToken();
      // Always clear local credentials
      await localDataSource.clearUser();
      return const Right(unit);
    } catch (e) {
      // Even on unexpected error, clear local state
      await localDataSource.clearUser();
      return const Right(unit);
    }
  }

  // ════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ════════════════════════════════════════════════════════

  /// Persist user tokens to secure storage and register FCM device token
  /// with the backend. FCM registration is fire-and-forget (non-blocking).
  Future<void> _persistUserAndRegisterFcm(UserModel user) async {
    await localDataSource.cacheUser(user);

    if (user.token != null) {
      // Non-blocking: get FCM token and send to backend
      notificationService.getFCMToken().then((fcmToken) {
        if (fcmToken != null) {
          remoteDataSource.updateFcmToken(
            token: user.token!,
            fcmToken: fcmToken,
          );
        }
      });
    }
  }
}
