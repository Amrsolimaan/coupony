import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/reset_password_params.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/password_reset_response_model.dart';
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
    required String email,
    required String password,
    required String role,
  }) async {
    return executeOnlineOperation<UserEntity>(
      operation: () async {
        final user = await remoteDataSource.login(
          email: email,
          password: password,
          role: role,
        );
        await _persistUserAndRegisterFcm(user);
        return user;
      },
    );
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    return executeOnlineOperation<UserEntity>(
      operation: () async {
        final user = await remoteDataSource.register(
          firstName:            firstName,
          lastName:             lastName,
          email:                email,
          phoneNumber:          phoneNumber,
          password:             password,
          passwordConfirmation: passwordConfirmation,
          role:                 role,
        );
        // Only persist if backend returned an access_token (auto-login after register)
        if (user.accessToken != null) {
          await _persistUserAndRegisterFcm(user);
        }
        return user;
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> sendOtp(String email) async {
    return executeOnlineOperation<Unit>(
      operation: () async {
        await remoteDataSource.sendOtp(email: email);
        return unit;
      },
    );
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String email,
    required String code,
  }) async {
    return executeOnlineOperation<UserEntity>(
      operation: () async {
        final user = await remoteDataSource.verifyOtp(
          email: email,
          code:  code,
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
      final token = await localDataSource.getAccessToken();
      return Right(token != null);
    } catch (_) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      // Best-effort API call — DioClient already has the token in headers
      await remoteDataSource.logout();
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
  // RESET CODE VERIFICATION
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, Unit>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    return executeOnlineOperation<Unit>(
      operation: () async {
        await remoteDataSource.verifyResetCode(email: email, code: code);
        return unit;
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // PASSWORD RESET
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, PasswordResetResponseModel>> sendResetCode(String email) async {
    return executeOnlineOperation<PasswordResetResponseModel>(
      operation: () => remoteDataSource.sendResetCode(email: email),
    );
  }

  @override
  Future<Either<Failure, PasswordResetResponseModel>> resendResetCode(String email) async {
    return executeOnlineOperation<PasswordResetResponseModel>(
      operation: () => remoteDataSource.resendResetCode(email: email),
    );
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(ResetPasswordParams params) async {
    return executeOnlineOperation<Unit>(
      operation: () async {
        await remoteDataSource.resetPassword(
          email:                params.email,
          token:                params.token,
          password:             params.password,
          passwordConfirmation: params.passwordConfirmation,
        );
        return unit;
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ════════════════════════════════════════════════════════

  /// Persist access/refresh tokens to secure storage and register FCM token
  /// with the backend. FCM registration is fire-and-forget (non-blocking).
  ///
  /// Also clears the guest flag so the user is treated as authenticated on
  /// the next cold start, not as a visitor.
  Future<void> _persistUserAndRegisterFcm(UserModel user) async {
    await localDataSource.cacheUser(user);
    // A real session supersedes guest mode.
    await localDataSource.cacheGuestStatus(false);

    if (user.accessToken != null) {
      // Non-blocking: fetch FCM token and send to backend
      notificationService.getFCMToken().then((fcmToken) {
        if (fcmToken != null) {
          remoteDataSource.updateFcmToken(fcmToken: fcmToken);
        }
      });
    }
  }
}
