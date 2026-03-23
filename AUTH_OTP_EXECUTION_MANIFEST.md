# COUPONY — AUTH & OTP EXECUTION MANIFEST
> For Claude Code CLI. Execute steps in order. Do not skip.
> Base URL: `https://api.coupony.shop/api/v1`
> Architecture: Clean Architecture + Modular DI (GetIt)
> State: flutter_bloc (Cubit) + dartz Either

---

## CODEBASE SCAN FINDINGS

### TODOs Identified (injection_container.dart)
- `// TODO: Register Auth Data Sources when implemented` → lines ~107-115
- `// TODO: Register Auth Repository when implemented` → lines ~140-150
- `// TODO: Register Auth Cubits when implemented` → lines ~170-185

### Empty Placeholder Files (all 3 are blank)
- `lib/features/auth/data/datasources/auth_remote_data_source.dart` — EMPTY
- `lib/features/auth/data/models/user_model.dart` — EMPTY
- `lib/features/auth/data/repositories/auth_repository_impl.dart` — EMPTY

### Existing Infrastructure to Wire Into
- `DioClient` → already has `AuthInterceptor` injecting Bearer tokens
- `SecureStorageService` → wraps `FlutterSecureStorage`, keys in `StorageKeys`
- `StorageKeys.authToken`, `.refreshToken`, `.userId`, `.userRole` → already defined
- `BaseRepository.executeOnlineOperation()` → use for all auth write ops
- `NotificationService.getFCMToken()` → call after login to register device
- `NotificationService.deleteFCMToken()` → call on logout
- `AuthInterceptor.onError` → 401 handler is a stub, needs logout trigger
- `app_router.dart` → `LoginScreen` and `RegisterScreen` are placeholder widgets

### Missing Domain Contracts
- `AuthRepository` has no `sendOtp()`, `verifyOtp()`, `refreshToken()` methods
- No `AuthLocalDataSource` abstract class exists
- No use cases exist under `lib/features/auth/domain/use_cases/`
- No `AuthCubit` / `LoginCubit` / `OtpCubit` exist

---

## EXECUTION PLAN OVERVIEW

```
STEP 1  → api_constants.dart          (update base URL + add all endpoints)
STEP 2  → storage_keys.dart           (add fcmToken key)
STEP 3  → exceptions.dart             (add NetworkException)
STEP 4  → user_entity.dart            (extend with phone + fcmToken)
STEP 5  → auth_repository.dart        (add OTP + refresh contracts)
STEP 6  → user_model.dart             (AuthModel with fromJson/toJson)
STEP 7  → auth_remote_data_source.dart (implement all API calls)
STEP 8  → auth_local_data_source.dart  (CREATE — token persistence)
STEP 9  → auth_repository_impl.dart   (implement full repository)
STEP 10 → use cases (4 files)         (Login, Register, VerifyOtp, Logout)
STEP 11 → auth_cubit + states (3 files)(LoginCubit, RegisterCubit, OtpCubit)
STEP 12 → auth_injection.dart         (CREATE — modular DI module)
STEP 13 → injection_container.dart    (activate auth module, remove TODOs)
STEP 14 → auth_interceptor.dart       (wire 401 → logout trigger)
STEP 15 → app_router.dart             (replace placeholder screens)
```

---

---

## STEP 1 — `lib/core/constants/api_constants.dart`
**Action:** REPLACE entire file content.

```dart
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.coupony.shop/api/v1';

  // ── Auth ──────────────────────────────────────────────
  static const String login           = '/auth/login';
  static const String register        = '/auth/register';
  static const String sendOtp         = '/auth/otp/send';
  static const String verifyOtp       = '/auth/otp/verify';
  static const String logout          = '/auth/logout';
  static const String refreshToken    = '/auth/refresh';
  static const String updateFcmToken  = '/auth/fcm-token';
}
```

---

## STEP 2 — `lib/core/constants/storage_keys.dart`
**Action:** ADD one key inside the SECURE STORAGE section (after `userRole`).

```dart
// Add after: static const String userRole = 'user_role';
static const String fcmToken = 'fcm_token';
```

---

## STEP 3 — `lib/core/errors/exceptions.dart`
**Action:** ADD `NetworkException` at the bottom of the file.

```dart
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}
```

---

## STEP 4 — `lib/features/auth/domain/entities/user_entity.dart`
**Action:** REPLACE entire file. Extends entity with `phone` and `fcmToken`.

```dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;       // 'user' | 'merchant'
  final String? token;
  final String? refreshToken;
  final String? fcmToken;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.token,
    this.refreshToken,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [id, name, email, phone, role, token, refreshToken, fcmToken];
}
```

---

## STEP 5 — `lib/features/auth/domain/repositories/auth_repository.dart`
**Action:** REPLACE entire file. Adds OTP + refresh contracts.

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  });

  /// Send OTP to phone number
  Future<Either<Failure, Unit>> sendOtp(String phone);

  /// Verify OTP — returns authenticated UserEntity on success
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<Either<Failure, UserEntity>> refreshToken();

  Future<Either<Failure, bool>> checkAuthStatus();

  Future<Either<Failure, Unit>> logout();
}
```

---

## STEP 6 — `lib/features/auth/data/models/user_model.dart`
**Action:** REPLACE entire file (was empty). Full AuthModel with fromJson/toJson.

```dart
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.token,
    super.refreshToken,
    super.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handles both flat and nested token structures
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return UserModel(
      id:           data['id'] as int,
      name:         data['name'] as String,
      email:        data['email'] as String,
      phone:        data['phone'] as String,
      role:         data['role'] as String? ?? 'user',
      token:        json['token'] as String? ?? data['token'] as String?,
      refreshToken: json['refresh_token'] as String? ?? data['refresh_token'] as String?,
      fcmToken:     data['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'name':          name,
    'email':         email,
    'phone':         phone,
    'role':          role,
    'token':         token,
    'refresh_token': refreshToken,
    'fcm_token':     fcmToken,
  };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? token,
    String? refreshToken,
    String? fcmToken,
  }) {
    return UserModel(
      id:           id ?? this.id,
      name:         name ?? this.name,
      email:        email ?? this.email,
      phone:        phone ?? this.phone,
      role:         role ?? this.role,
      token:        token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      fcmToken:     fcmToken ?? this.fcmToken,
    );
  }
}
```

---

---

## STEP 7 — `lib/features/auth/data/datasources/auth_remote_data_source.dart`
**Action:** REPLACE entire file (was empty). Full remote data source.

```dart
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String phone, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  });
  Future<void> sendOtp(String phone);
  Future<UserModel> verifyOtp({required String phone, required String otp});
  Future<UserModel> refreshToken(String refreshToken);
  Future<void> logout(String token);
  Future<void> updateFcmToken({required String token, required String fcmToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login({required String phone, required String password}) async {
    try {
      final response = await client.post(
        ApiConstants.login,
        data: {'phone': phone, 'password': password},
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  }) async {
    try {
      final response = await client.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        },
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendOtp(String phone) async {
    try {
      await client.post(ApiConstants.sendOtp, data: {'phone': phone});
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyOtp({required String phone, required String otp}) async {
    try {
      final response = await client.post(
        ApiConstants.verifyOtp,
        data: {'phone': phone, 'otp': otp},
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> refreshToken(String refreshToken) async {
    try {
      final response = await client.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await client.post(ApiConstants.logout);
    } catch (_) {
      // Best-effort — always clear local state regardless
    }
  }

  @override
  Future<void> updateFcmToken({required String token, required String fcmToken}) async {
    try {
      await client.post(
        ApiConstants.updateFcmToken,
        data: {'fcm_token': fcmToken},
      );
    } catch (_) {
      // Non-critical — silent fail
    }
  }
}
```

---

## STEP 8 — `lib/features/auth/data/datasources/auth_local_data_source.dart`
**Action:** CREATE new file. Token persistence layer.

```dart
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  Future<String?> getToken();
  Future<String?> getRefreshToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      if (user.token != null) {
        await secureStorage.write(StorageKeys.authToken, user.token!);
      }
      if (user.refreshToken != null) {
        await secureStorage.write(StorageKeys.refreshToken, user.refreshToken!);
      }
      if (user.fcmToken != null) {
        await secureStorage.write(StorageKeys.fcmToken, user.fcmToken!);
      }
      await secureStorage.write(StorageKeys.userId, user.id.toString());
      await secureStorage.write(StorageKeys.userRole, user.role);
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final token   = await secureStorage.read(StorageKeys.authToken);
      final userId  = await secureStorage.read(StorageKeys.userId);
      final role    = await secureStorage.read(StorageKeys.userRole);

      if (token == null || userId == null) return null;

      // Minimal cached user — enough to restore session
      return UserModel(
        id:    int.tryParse(userId) ?? 0,
        name:  '',
        email: '',
        phone: '',
        role:  role ?? 'user',
        token: token,
        refreshToken: await secureStorage.read(StorageKeys.refreshToken),
        fcmToken:     await secureStorage.read(StorageKeys.fcmToken),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await secureStorage.delete(StorageKeys.authToken);
    await secureStorage.delete(StorageKeys.refreshToken);
    await secureStorage.delete(StorageKeys.userId);
    await secureStorage.delete(StorageKeys.userRole);
    await secureStorage.delete(StorageKeys.fcmToken);
  }

  @override
  Future<String?> getToken() => secureStorage.read(StorageKeys.authToken);

  @override
  Future<String?> getRefreshToken() => secureStorage.read(StorageKeys.refreshToken);
}
```

---

---

## STEP 9 — `lib/features/auth/data/repositories/auth_repository_impl.dart`
**Action:** REPLACE entire file (was empty). Full repository wiring BaseRepository.

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
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

  @override
  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  }) async {
    return executeOnlineOperation<UserEntity>(
      operation: () async {
        final user = await remoteDataSource.login(phone: phone, password: password);
        await _persistUserAndFcm(user);
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
          name: name, email: email, password: password, phone: phone, role: role,
        );
        await _persistUserAndFcm(user);
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
        final user = await remoteDataSource.verifyOtp(phone: phone, otp: otp);
        await _persistUserAndFcm(user);
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
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        await remoteDataSource.logout(token);
      }
      await notificationService.deleteFCMToken();
      await localDataSource.clearUser();
      return const Right(unit);
    } catch (e) {
      // Always clear local state even if API call fails
      await localDataSource.clearUser();
      return const Right(unit);
    }
  }

  // ── Private Helpers ──────────────────────────────────────────────────────

  /// Persist user tokens + register FCM device token with backend
  Future<void> _persistUserAndFcm(UserModel user) async {
    await localDataSource.cacheUser(user);

    // Register FCM token with backend (non-blocking)
    if (user.token != null) {
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
```

---

## STEP 10 — Use Cases (CREATE 4 files)

### `lib/features/auth/domain/use_cases/login_use_case.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String phone,
    required String password,
  }) => repository.login(phone: phone, password: password);
}
```

### `lib/features/auth/domain/use_cases/register_use_case.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  }) => repository.register(
        name: name, email: email, password: password, phone: phone, role: role,
      );
}
```

### `lib/features/auth/domain/use_cases/send_otp_use_case.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;
  SendOtpUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String phone) => repository.sendOtp(phone);
}
```

### `lib/features/auth/domain/use_cases/verify_otp_use_case.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String phone,
    required String otp,
  }) => repository.verifyOtp(phone: phone, otp: otp);
}
```

### `lib/features/auth/domain/use_cases/logout_use_case.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() => repository.logout();
}
```

---

---

## STEP 11 — Cubits (CREATE 3 files)

### `lib/features/auth/presentation/cubit/auth_state.dart`
```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState { const AuthInitial(); }
class AuthLoading extends AuthState { const AuthLoading(); }
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override List<Object?> get props => [message];
}

// OTP-specific states
class OtpSent extends AuthState { const OtpSent(); }
class OtpVerified extends AuthState {
  final UserEntity user;
  const OtpVerified(this.user);
  @override List<Object?> get props => [user];
}
```

### `lib/features/auth/presentation/cubit/login_cubit.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/login_use_case.dart';
import 'auth_state.dart';

class LoginCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;

  LoginCubit({required this.loginUseCase}) : super(const AuthInitial());

  Future<void> login({required String phone, required String password}) async {
    emit(const AuthLoading());
    final result = await loginUseCase(phone: phone, password: password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user)    => emit(AuthAuthenticated(user)),
    );
  }
}
```

### `lib/features/auth/presentation/cubit/register_cubit.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/register_use_case.dart';
import 'auth_state.dart';

class RegisterCubit extends Cubit<AuthState> {
  final RegisterUseCase registerUseCase;

  RegisterCubit({required this.registerUseCase}) : super(const AuthInitial());

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  }) async {
    emit(const AuthLoading());
    final result = await registerUseCase(
      name: name, email: email, password: password, phone: phone, role: role,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user)    => emit(AuthAuthenticated(user)),
    );
  }
}
```

### `lib/features/auth/presentation/cubit/otp_cubit.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/send_otp_use_case.dart';
import '../../domain/use_cases/verify_otp_use_case.dart';
import 'auth_state.dart';

class OtpCubit extends Cubit<AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;

  OtpCubit({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
  }) : super(const AuthInitial());

  Future<void> sendOtp(String phone) async {
    emit(const AuthLoading());
    final result = await sendOtpUseCase(phone);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_)       => emit(const OtpSent()),
    );
  }

  Future<void> verifyOtp({required String phone, required String otp}) async {
    emit(const AuthLoading());
    final result = await verifyOtpUseCase(phone: phone, otp: otp);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user)    => emit(OtpVerified(user)),
    );
  }
}
```

---

## STEP 12 — `lib/config/dependency_injection/features/auth_injection.dart`
**Action:** CREATE new file. Mirrors the pattern of `onboarding_injection.dart`.

```dart
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/local_cache_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/use_cases/login_use_case.dart';
import '../../../features/auth/domain/use_cases/logout_use_case.dart';
import '../../../features/auth/domain/use_cases/register_use_case.dart';
import '../../../features/auth/domain/use_cases/send_otp_use_case.dart';
import '../../../features/auth/domain/use_cases/verify_otp_use_case.dart';
import '../../../features/auth/presentation/cubit/login_cubit.dart';
import '../../../features/auth/presentation/cubit/otp_cubit.dart';
import '../../../features/auth/presentation/cubit/register_cubit.dart';

void registerAuthDependencies(GetIt sl) {
  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl<DioClient>()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl<SecureStorageService>()),
  );

  // ── Repository ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource:    sl<AuthRemoteDataSource>(),
      localDataSource:     sl<AuthLocalDataSource>(),
      notificationService: sl<NotificationService>(),
      networkInfo:         sl<NetworkInfo>(),
      cacheService:        sl<LocalCacheService>(),
    ),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SendOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));

  // ── Cubits (Factory — new instance per screen) ────────────────────────────
  sl.registerFactory<LoginCubit>(
    () => LoginCubit(loginUseCase: sl<LoginUseCase>()),
  );

  sl.registerFactory<RegisterCubit>(
    () => RegisterCubit(registerUseCase: sl<RegisterUseCase>()),
  );

  sl.registerFactory<OtpCubit>(
    () => OtpCubit(
      sendOtpUseCase:   sl<SendOtpUseCase>(),
      verifyOtpUseCase: sl<VerifyOtpUseCase>(),
    ),
  );
}
```

---

---

## STEP 13 — `lib/config/dependency_injection/injection_container.dart`
**Action:** TWO targeted edits.

### Edit A — Add import at top of file (after existing feature imports)
```dart
// ADD this line after: import 'features/permissions_injection.dart';
import 'features/auth_injection.dart';
```

### Edit B — Activate auth module (replace the entire Auth TODO block in section 5)
Find this block:
```dart
  // Auth Feature
  // ─────────────────
  // TODO: Register Auth Data Sources when implemented
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(client: sl<DioClient>()),
  // );
  // sl.registerLazySingleton<AuthLocalDataSource>(
  //   () => AuthLocalDataSourceImpl(
  //     secureStorage: sl<SecureStorageService>(),
  //     cacheService: sl<LocalCacheService>(),
  //   ),
  // );
```
Replace with:
```dart
  // ═══════════════════════════════════════════════════════════
  // 5. FEATURES - AUTH
  // ═══════════════════════════════════════════════════════════
  registerAuthDependencies(sl);
```

### Edit C — Remove the Auth Repository TODO block (section 6)
Delete these lines entirely:
```dart
  // Auth Repository
  // ─────────────────
  // TODO: Register Auth Repository when implemented
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     remoteDataSource: sl<AuthRemoteDataSource>(),
  //     localDataSource: sl<AuthLocalDataSource>(),
  //     networkInfo: sl<NetworkInfo>(),
  //     cacheService: sl<LocalCacheService>(),
  //   ),
  // );
```

### Edit D — Remove the Auth Cubits TODO block (section 7)
Delete these lines entirely:
```dart
  // Auth Cubits
  // ─────────────────
  // TODO: Register Auth Cubits when implemented
  // sl.registerFactory<LoginCubit>(
  //   () => LoginCubit(repository: sl<AuthRepository>()),
  // );
  // sl.registerFactory<RegisterCubit>(
  //   () => RegisterCubit(repository: sl<AuthRepository>()),
  // );
  // sl.registerFactory<AuthCubit>(
  //   () => AuthCubit(repository: sl<AuthRepository>()),
  // );
```

---

## STEP 14 — `lib/core/network/interceptors/auth_interceptor.dart`
**Action:** Wire the 401 handler to trigger logout via `SecureStorageService`.
The current `onError` is a stub. Replace the `onError` method body:

```dart
// REPLACE the existing onError method with:
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode == 401) {
    // Clear all auth tokens on 401 — forces re-login
    await secureStorage.delete(key: StorageKeys.authToken);
    await secureStorage.delete(key: StorageKeys.refreshToken);
    await secureStorage.delete(key: StorageKeys.userId);
    await secureStorage.delete(key: StorageKeys.userRole);
    // NOTE: Navigation to /login is handled by GoRouter redirect guard
    // which checks auth status on each route change
  }
  super.onError(err, handler);
}
```

Also add the missing import at the top of `auth_interceptor.dart`:
```dart
import '../../constants/storage_keys.dart';
```

---

## STEP 15 — `lib/config/routes/app_router.dart`
**Action:** Replace the placeholder `LoginScreen` and `RegisterScreen` widgets
with real screen imports once the UI screens are built.

For now, add an auth guard redirect. Add this inside `GoRouter(...)`:

```dart
// ADD redirect logic inside GoRouter constructor:
redirect: (context, state) async {
  final storage = sl<SecureStorageService>();
  final token = await storage.read(StorageKeys.authToken);
  final isLoggedIn = token != null;
  final isOnAuthRoute = state.matchedLocation == AppRouter.login ||
                        state.matchedLocation == AppRouter.register;

  if (!isLoggedIn && !isOnAuthRoute &&
      state.matchedLocation != AppRouter.splash &&
      state.matchedLocation.startsWith('/onboarding') == false &&
      state.matchedLocation.startsWith('/permission') == false &&
      state.matchedLocation != AppRouter.welcomeGateway &&
      state.matchedLocation != AppRouter.languageSelection) {
    return AppRouter.login;
  }
  return null;
},
```

Add required imports at top:
```dart
import '../../config/dependency_injection/injection_container.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/storage/secure_storage_service.dart';
```

---

## STEP 16 — `lib/core/services/notification_service.dart`
**Action:** Activate the `sendTokenToBackend` TODO (line ~155).
This is now handled by `AuthRepositoryImpl._persistUserAndFcm()` via
`remoteDataSource.updateFcmToken()`. The `sendTokenToBackend` method
in `NotificationService` can remain as a no-op or be removed.

No code change required here — the TODO is resolved architecturally.

---

## FINAL FILE TREE (Auth Feature — Complete)

```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth_remote_data_source.dart   ✅ STEP 7
│   │   └── auth_local_data_source.dart    ✅ STEP 8 (NEW)
│   ├── models/
│   │   └── user_model.dart                ✅ STEP 6
│   └── repositories/
│       └── auth_repository_impl.dart      ✅ STEP 9
├── domain/
│   ├── entities/
│   │   └── user_entity.dart               ✅ STEP 4
│   ├── repositories/
│   │   └── auth_repository.dart           ✅ STEP 5
│   └── use_cases/
│       ├── login_use_case.dart            ✅ STEP 10
│       ├── register_use_case.dart         ✅ STEP 10
│       ├── send_otp_use_case.dart         ✅ STEP 10
│       ├── verify_otp_use_case.dart       ✅ STEP 10
│       └── logout_use_case.dart           ✅ STEP 10
└── presentation/
    ├── cubit/
    │   ├── auth_state.dart                ✅ STEP 11
    │   ├── login_cubit.dart               ✅ STEP 11
    │   ├── register_cubit.dart            ✅ STEP 11
    │   └── otp_cubit.dart                 ✅ STEP 11
    └── pages/
        ├── login_screen.dart              ⏳ UI (future session)
        ├── register_screen.dart           ⏳ UI (future session)
        └── otp_verification_screen.dart   ⏳ UI (future session)

lib/config/dependency_injection/features/
└── auth_injection.dart                    ✅ STEP 12 (NEW)
```

---

## DEPENDENCY FLOW DIAGRAM

```
DioClient ──────────────────────────────────────────────────────────────────┐
SecureStorageService ────────────────────────────────────────────────────┐  │
NotificationService ──────────────────────────────────────────────────┐  │  │
NetworkInfo ────────────────────────────────────────────────────────┐  │  │  │
LocalCacheService ────────────────────────────────────────────────┐  │  │  │  │
                                                                   ↓  ↓  ↓  ↓  ↓
AuthLocalDataSourceImpl ←── SecureStorageService
AuthRemoteDataSourceImpl ←── DioClient
AuthRepositoryImpl ←── AuthRemoteDataSource + AuthLocalDataSource
                        + NotificationService + NetworkInfo + LocalCacheService
LoginUseCase / RegisterUseCase / SendOtpUseCase / VerifyOtpUseCase / LogoutUseCase ←── AuthRepository
LoginCubit ←── LoginUseCase
RegisterCubit ←── RegisterUseCase
OtpCubit ←── SendOtpUseCase + VerifyOtpUseCase
```

---

## CRITICAL NOTES FOR CLI

1. **Execution order matters** — Steps 1-5 (contracts/entities) before Steps 6-9 (implementations).
2. **No code generation needed** — `UserModel` is hand-written (no `json_serializable`/`freezed` in pubspec).
3. **`AuthInterceptor` already injects Bearer tokens** — `DioClient` wires it automatically. No changes to `DioClient` needed.
4. **FCM registration is non-blocking** — `_persistUserAndFcm` uses fire-and-forget `.then()`. Never `await` it.
5. **Logout always clears local state** — even if the API call fails. This is intentional.
6. **`AuthLocalDataSource` stores a minimal user** — full profile fetch should be a separate `/me` endpoint call post-login.
7. **OTP flow**: `sendOtp(phone)` → user enters code → `verifyOtp(phone, otp)` → returns `UserEntity` with token.
8. **Router guard** (Step 15) requires `sl` to be initialized before `GoRouter` is created — verify `main.dart` calls `await init()` before `runApp()`.
