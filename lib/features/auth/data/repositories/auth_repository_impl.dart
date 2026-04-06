import 'package:coupony/features/user_flow/CustomerOnboarding/domain/entities/onboarding_user_type.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/repositories/onboarding_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/storage_keys.dart';
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

      // 1. Clear SharedPreferences session flags FIRST.
      //    clearSessionFlags() needs the userId from SecureStorage to resolve
      //    user-scoped keys — it MUST run before clearUser() deletes the userId.
      await localDataSource.clearSessionFlags();

      // 2. Clear SecureStorage (tokens, userId, role, fcmToken)
      await localDataSource.clearUser();

      // 3. Clear Hive: customer onboarding preferences box.
      //    Without this, a second user logging in on the same device would
      //    inherit the previous user's cached preferences.
      await clearFeatureCache(StorageKeys.onboardingPreferencesBox);

      // 4. Clear Hive: seller onboarding preferences box.
      //    Explicitly wiped so seller data never leaks to another account.
      await clearFeatureCache(StorageKeys.sellerOnboardingPreferencesBox);

      // 5. Revoke Google OAuth grant so the account picker appears on the
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
      final googleUserData = await GoogleSignInService()
          .signInWithGoogleAndGetUserData();

      if (googleUserData == null) {
        print('❌ [REPOSITORY] Google Sign-In was cancelled');
        return const Left(UnexpectedFailure('login_google_cancelled'));
      }

      print('✅ [REPOSITORY] Got Google user data: ${googleUserData['email']}');

      final email = googleUserData['email']!;
      final password = 'google_auth_${googleUserData['id']}';

      // ── Step 1: try login ──────────────────────────────────────────────────
      // 🔧 FIX: For Google Sign-In, do NOT send role to backend.
      // Backend determines role from existing user record.
      // Sending role causes "Invalid Credentials" error.
      try {
        print('🔐 [REPOSITORY] Trying login for: $email');
        final user = await remoteDataSource.login(
          email: email,
          password: password,
          role: null,  // ✅ Google users: backend determines role from DB
        );
        print('✅ [REPOSITORY] Login succeeded');
        await _persistUserAndRegisterFcm(user);
        return Right(user);
      } catch (loginError) {
        final msg = _exceptionMessage(loginError).toLowerCase();
        print('⚠️ [REPOSITORY] Login failed — "$msg"');

        // Account exists but email is not yet verified → go to OTP
        if (_isUnverifiedError(msg)) {
          print('🔐 [REPOSITORY] Account unverified → OTP required');
          return Left(OtpRequiredFailure(email: email, password: password));
        }

        // Account not found → attempt registration
        if (_isNotFoundError(msg)) {
          print('🔐 [REPOSITORY] Account not found → attempting registration');
          return await _registerGoogleUser(
            email: email,
            password: password,
            role: role,
            firstName: googleUserData['firstName'] ?? 'مستخدم',
            lastName: googleUserData['lastName'] ?? 'جديد',
            phoneNumber: googleUserData['phoneNumber'] ?? '+1234567890',
          );
        }

        // Any other login error → surface it
        return Left(_mapException(loginError));
      }
    } catch (e, st) {
      print('❌ [REPOSITORY] Unexpected error in googleSignIn: $e\n$st');
      return Left(_mapException(e));
    }
  }

  /// Registers a new Google-authenticated user.
  /// If registration fails with "already registered" the account exists but is
  /// unverified, so we redirect to OTP instead of surfacing the error.
  /// 
  /// 🔧 FIX: For Google Sign-In, role is sent during registration (new user)
  /// but NOT during login (existing user).
  Future<Either<Failure, UserEntity>> _registerGoogleUser({
    required String email,
    required String password,
    required String role,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // ✅ For NEW Google users, we DO send role during registration
      final user = await remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        passwordConfirmation: password,
        role: role,  // ✅ Role is needed for new user creation
      );
      print('✅ [REPOSITORY] Registration succeeded');
      if (user.accessToken == null) {
        print('🔐 [REPOSITORY] No token received -> OTP Verification required');
        return Left(OtpRequiredFailure(email: email, password: password));
      }
      await _persistUserAndRegisterFcm(user);
      return Right(user);
    } catch (registerError) {
      final msg = _exceptionMessage(registerError).toLowerCase();
      print('⚠️ [REPOSITORY] Registration failed — "$msg"');

      // Email already exists but is unverified → go to OTP
      if (_isAlreadyRegisteredError(msg)) {
        print('🔐 [REPOSITORY] Email exists (unverified) → OTP required');
        return Left(OtpRequiredFailure(email: email, password: password));
      }

      return Left(_mapException(registerError));
    }
  }

  // ── Error-message helpers ────────────────────────────────────────────────

  /// Extracts the human-readable message from an exception thrown by the
  /// remote data source.
  String _exceptionMessage(Object error) {
    if (error is ServerException) return error.message;
    if (error is InvalidTokenException) return error.message;
    if (error is UnauthorizedException) return error.message;
    if (error is NetworkException) return error.message;
    return error.toString();
  }

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

  bool _isUnverifiedError(String msg) =>
      msg.contains('not verified') ||
      msg.contains('unverified') ||
      msg.contains('not activated') ||
      msg.contains('verification code has been sent');

  bool _isNotFoundError(String msg) =>
      msg.contains('not found') ||
      msg.contains('no account') ||
      msg.contains('invalid credentials') ||
      msg.contains('wrong credentials') ||
      msg.contains('selected email is invalid');

  bool _isAlreadyRegisteredError(String msg) =>
      msg.contains('already registered') ||
      msg.contains('already taken') ||
      msg.contains('already exists') ||
      msg.contains('email taken');

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
