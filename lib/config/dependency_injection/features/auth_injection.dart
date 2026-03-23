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
  // ════════════════════════════════════════════════════════
  // DATA SOURCES
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl<DioClient>()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl<SecureStorageService>()),
  );

  // ════════════════════════════════════════════════════════
  // REPOSITORY
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource:    sl<AuthRemoteDataSource>(),
      localDataSource:     sl<AuthLocalDataSource>(),
      notificationService: sl<NotificationService>(),
      networkInfo:         sl<NetworkInfo>(),
      cacheService:        sl<LocalCacheService>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // USE CASES
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SendOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));

  // ════════════════════════════════════════════════════════
  // CUBITS  (Factory — new instance per screen)
  // ════════════════════════════════════════════════════════

  sl.registerFactory<LoginCubit>(
    () => LoginCubit(
      loginUseCase:  sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      repository:    sl<AuthRepository>(),
      logger:        sl<Logger>(),
    ),
  );

  sl.registerFactory<RegisterCubit>(
    () => RegisterCubit(
      registerUseCase: sl<RegisterUseCase>(),
      logger:          sl<Logger>(),
    ),
  );

  sl.registerFactory<OtpCubit>(
    () => OtpCubit(
      sendOtpUseCase:   sl<SendOtpUseCase>(),
      verifyOtpUseCase: sl<VerifyOtpUseCase>(),
      logger:           sl<Logger>(),
    ),
  );
}
