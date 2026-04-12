import 'package:coupony/features/user_flow/CustomerOnboarding/domain/entities/onboarding_user_type.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/repositories/onboarding_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/google_sign_in_service.dart';
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
  final OnboardingRepository _onboardingRepository;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.notificationService,
    required OnboardingRepository onboardingRepository,
    required NetworkInfo networkInfo,
    required LocalCacheService cacheService,
  }) : _onboardingRepository = onboardingRepository,
       super(networkInfo: networkInfo, cacheService: cacheService);

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
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
          passwordConfirmation: passwordConfirmation,
          role: role,
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
        final user = await remoteDataSource.verifyOtp(email: email, code: code);
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
    } catch (_) {
      // Network failure is non-fatal for logout — always clear local state
    } finally {
      // Delete FCM token from Firebase (non-blocking)
      notificationService.deleteFCMToken();

      // 1. Hard reset: wipe ALL Hive boxes from disk + clear SharedPreferences.
      //    This ensures isStoreCreated, onboarding flags, and every user-scoped
      //    key are destroyed so no data leaks to a subsequent account.
      await cacheService.deleteAllData();

      // 2. Clear SecureStorage (tokens, userId, role, selectedStoreId, fcmToken).
      //    Done after deleteAllData() because SecureStorage is managed separately.
      await localDataSource.clearUser();

      // 3. Revoke Google OAuth grant so the account picker appears on the
      //    next Google Sign-In instead of silently reusing the cached session.
      await GoogleSignInService().signOut();
    }
    return const Right(unit);
  }

  // ════════════════════════════════════════════════════════
  // RESET CODE VERIFICATION
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, String>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    return executeOnlineOperation<String>(
      operation: () async {
        final resetToken = await remoteDataSource.verifyResetCode(
          email: email,
          code: code,
        );
        return resetToken;
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // PASSWORD RESET
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, PasswordResetResponseModel>> sendResetCode(
    String email,
  ) async {
    return executeOnlineOperation<PasswordResetResponseModel>(
      operation: () => remoteDataSource.sendResetCode(email: email),
    );
  }

  @override
  Future<Either<Failure, PasswordResetResponseModel>> resendResetCode(
    String email,
  ) async {
    return executeOnlineOperation<PasswordResetResponseModel>(
      operation: () => remoteDataSource.resendResetCode(email: email),
    );
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(
    ResetPasswordParams params,
  ) async {
    return executeOnlineOperation<Unit>(
      operation: () async {
        await remoteDataSource.resetPassword(
          email: params.email,
          token: params.token,
          password: params.password,
          passwordConfirmation: params.passwordConfirmation,
        );
        return unit;
      },
    );
  }

  @override
  Future<Either<Failure, UserEntity>> googleSignIn({
    required String role,
  }) async {
    print('🔐 [REPOSITORY] Starting Google Sign-In for role: $role');

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return const Left(NetworkFailure('error_no_internet'));

    try {
      // ── Step 1: Get idToken from Google ────────────────────────────────────
      final idToken = await GoogleSignInService()
          .signInWithGoogleAndGetIdToken();

      if (idToken == null) {
        print('❌ [REPOSITORY] Google Sign-In was cancelled');
        return const Left(UnexpectedFailure('login_google_cancelled'));
      }

      print('✅ [REPOSITORY] Got Google ID token');

      // ── Step 2: Send idToken to backend ────────────────────────────────────
      print('🔐 [REPOSITORY] Calling /auth/google endpoint...');
      final user = await remoteDataSource.googleSignIn(
        idToken: idToken,
        role: role,
      );
      
      print('✅ [REPOSITORY] Google authentication succeeded');
      await _persistUserAndRegisterFcm(user);
      return Right(user);

    } catch (e, st) {
      print('❌ [REPOSITORY] Unexpected error in googleSignIn: $e\n$st');
      return Left(_mapException(e));
    }
  }

  // ── Error-message helpers ────────────────────────────────────────────────

  /// Maps a data-source exception to the corresponding [Failure] type.
  Failure _mapException(Object error) {
    if (error is InvalidTokenException)
      return InvalidTokenFailure(error.message);
    if (error is ValidationException) return ValidationFailure(error.message);
    if (error is UnauthorizedException)
      return UnauthorizedFailure(error.message);
    if (error is ServerException) return ServerFailure(error.message);
    if (error is NetworkException) return NetworkFailure(error.message);
    if (error is CacheException) return CacheFailure(error.message);
    return UnexpectedFailure(error.toString());
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
    print('💾 _persistUserAndRegisterFcm - Starting persistence for user:');
    print('  - ID: ${user.id}');
    print('  - Email: ${user.email}');
    print('  - Role: ${user.role}');
    print('  - isOnboardingCompleted: ${user.isOnboardingCompleted}');
    print('  - Has Access Token: ${user.accessToken != null}');

    await localDataSource.cacheUser(user);
    print('✅ User cached successfully');

    // A real session supersedes guest mode.
    await localDataSource.cacheGuestStatus(false);
    print('✅ Guest status cleared');

    if (user.accessToken != null) {
      // Non-blocking: fetch FCM token and send to backend
      notificationService.getFCMToken().then((fcmToken) {
        if (fcmToken != null) {
          print(
            '📱 FCM Token obtained, sending to backend: ${fcmToken.substring(0, 20)}...',
          );
          remoteDataSource.updateFcmToken(fcmToken: fcmToken);
        }
      });
    }

    print('💾 _persistUserAndRegisterFcm - Completed successfully');

    if (user.isOnboardingCompleted) {
      _onboardingRepository.fetchAndCacheFromServer(
        userType: user.role == 'seller'
            ? OnboardingUserType.seller
            : OnboardingUserType.customer,
      );
    }
  }
}
