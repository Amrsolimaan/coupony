import 'package:coupony/features/user_flow/CustomerOnboarding/domain/repositories/onboarding_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import '../../../features/auth/domain/use_cases/resend_reset_code_use_case.dart';
import '../../../features/auth/domain/use_cases/reset_password_use_case.dart';
import '../../../features/auth/domain/use_cases/send_otp_use_case.dart';
import '../../../features/auth/domain/use_cases/send_reset_code_use_case.dart';
import '../../../features/auth/domain/use_cases/verify_otp_use_case.dart';
import '../../../features/auth/domain/use_cases/verify_reset_code_use_case.dart';
import '../../../features/auth/domain/use_cases/google_sign_in_use_case.dart';
import '../../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../../features/auth/presentation/cubit/login_cubit.dart';
import '../../../features/auth/presentation/cubit/otp_cubit.dart';
import '../../../features/auth/presentation/cubit/register_cubit.dart';
import '../../../features/auth/presentation/cubit/reset_password_cubit.dart';
import '../../../features/auth/presentation/cubit/google_sign_in_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_role_cubit.dart';
import '../../../features/auth/presentation/cubit/persona_cubit.dart';
import '../../../features/auth/domain/use_cases/resolve_persona_use_case.dart';

void registerAuthDependencies(GetIt sl) {
  // ════════════════════════════════════════════════════════
  // DATA SOURCES
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () =>
        AuthRemoteDataSourceImpl(client: sl<DioClient>(), logger: sl<Logger>()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl<SecureStorageService>(),
      sharedPrefs: sl<SharedPreferences>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // REPOSITORY
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      notificationService: sl<NotificationService>(),
      onboardingRepository: sl<OnboardingRepository>(),
      networkInfo: sl<NetworkInfo>(),
      cacheService: sl<LocalCacheService>(),
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
  sl.registerLazySingleton(() => SendResetCodeUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResendResetCodeUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyResetCodeUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl<AuthRepository>()));

  // ════════════════════════════════════════════════════════
  // CUBITS
  // ════════════════════════════════════════════════════════

  // ── PersonaCubit — single authority for Theme + Route ─────────────────────
  // Registered FIRST so ProfileRemoteDataSource can inject it.
  sl.registerLazySingleton<ResolvePersonaUseCase>(
    () => const ResolvePersonaUseCase(),
  );

  sl.registerLazySingleton<PersonaCubit>(
    () => PersonaCubit(
      resolvePersonaUseCase: sl<ResolvePersonaUseCase>(),
      authLocalDs:           sl<AuthLocalDataSource>(),
      secureStorage:         sl<SecureStorageService>(),
      prefs:                 sl<SharedPreferences>(),
    ),
  );

  // AuthRoleCubit — kept for backward compatibility during migration.
  // @deprecated: use PersonaCubit for all new code.
  // ✅ Now uses SharedPreferences to persist role preference across logout
  sl.registerLazySingleton<AuthRoleCubit>(
    () => AuthRoleCubit(sl<SharedPreferences>()),
  );

  // Other Cubits - Factory (new instance per screen)
  sl.registerFactory<LoginCubit>(
    () => LoginCubit(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      repository: sl<AuthRepository>(),
      logger: sl<Logger>(),
    ),
  );

  sl.registerFactory<RegisterCubit>(
    () => RegisterCubit(
      registerUseCase: sl<RegisterUseCase>(),
      logger: sl<Logger>(),
    ),
  );

  sl.registerFactory<OtpCubit>(
    () => OtpCubit(
      sendOtpUseCase: sl<SendOtpUseCase>(),
      verifyOtpUseCase: sl<VerifyOtpUseCase>(),
      verifyResetCodeUseCase: sl<VerifyResetCodeUseCase>(),
      resendResetCodeUseCase: sl<ResendResetCodeUseCase>(),
      logger: sl<Logger>(),
    ),
  );

  sl.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(
      sendResetCodeUseCase: sl<SendResetCodeUseCase>(),
      logger: sl<Logger>(),
    ),
  );

  sl.registerFactory<ResetPasswordCubit>(
    () => ResetPasswordCubit(
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
      resendResetCodeUseCase: sl<ResendResetCodeUseCase>(),
      logger: sl<Logger>(),
    ),
  );

  sl.registerFactory<GoogleSignInCubit>(
    () => GoogleSignInCubit(
      googleSignInUseCase: sl<GoogleSignInUseCase>(),
      logger: sl<Logger>(),
    ),
  );
}
