import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coupon/core/services/location_service.dart';
import 'package:coupon/core/services/notification_service.dart';
import 'package:coupon/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/storage/local_cache_service.dart';
import '../../core/storage/secure_storage_service.dart';

// Onboarding Feature
import '../../features/onboarding/data/data_sources/onboarding_local_data_source.dart';
import '../../features/onboarding/data/data_sources/onboarding_remote_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/use_cases/get_onboarding_preferences_use_case.dart';
import '../../features/onboarding/domain/use_cases/init_interest_scores_use_case.dart';
import '../../features/onboarding/domain/use_cases/save_onboarding_preferences_use_case.dart';
import '../../features/onboarding/presentation/cubit/onboarding_flow_cubit.dart';

// Permission Feature
import '../../features/permissions/data/data_sources/permission_local_data_source.dart';
import '../../features/permissions/data/repositories/permission_repository_impl.dart';
import '../../features/permissions/domain/repositories/permission_repository.dart';
import '../../features/permissions/domain/use_cases/check_permission_status_use_case.dart';
import '../../features/permissions/domain/use_cases/determine_next_permission_step_use_case.dart';
import '../../features/permissions/domain/use_cases/request_location_permission_use_case.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
/// Must be called in main() after LocalCacheService().init()
Future<void> init() async {
  // ═══════════════════════════════════════════════════════════
  // 1. EXTERNAL DEPENDENCIES
  // ═══════════════════════════════════════════════════════════

  // FlutterSecureStorage - Used by SecureStorageService and DioClient
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(),
    ),
  );

  // Connectivity - Used by NetworkInfo
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Logger - Used throughout the app
  sl.registerLazySingleton<Logger>(() => Logger());

  // ═══════════════════════════════════════════════════════════
  // 2. CORE SERVICES
  // ═══════════════════════════════════════════════════════════

  // Location Service
  sl.registerLazySingleton<LocationService>(
    () => LocationService(logger: sl<Logger>()),
  );

  // Notification Service
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(logger: sl<Logger>()),
  );
  // ═══════════════════════════════════════════════════════════

  // Storage Services
  // ─────────────────

  // LocalCacheService - Register the singleton instance (already initialized in main())
  // IMPORTANT: LocalCacheService uses Singleton pattern internally,
  // so we register the existing instance, not create a new one
  sl.registerLazySingleton<LocalCacheService>(() => LocalCacheService());

  // SecureStorageService - Wrapper around FlutterSecureStorage
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl<FlutterSecureStorage>()),
  );

  // Network Services
  // ─────────────────

  // NetworkInfo - Checks internet connectivity
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // DioClient - HTTP client with interceptors
  // IMPORTANT: DioClient creates its own interceptors internally,
  // so we only pass FlutterSecureStorage
  sl.registerLazySingleton<DioClient>(
    () => DioClient(sl<FlutterSecureStorage>()),
  );

  // ═══════════════════════════════════════════════════════════
  // 3. FEATURES - ONBOARDING
  // ═══════════════════════════════════════════════════════════

  // Data Sources
  // ─────────────────
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(cacheService: sl<LocalCacheService>()),
  );

  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(client: sl<DioClient>()),
  );

  // Repository
  // ─────────────────
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      localDataSource: sl<OnboardingLocalDataSource>(),
      remoteDataSource: sl<OnboardingRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      cacheService: sl<LocalCacheService>(),
    ),
  );

  // Use Cases
  // ─────────────────
  sl.registerLazySingleton<SaveOnboardingPreferencesUseCase>(
    () => SaveOnboardingPreferencesUseCase(sl<OnboardingRepository>()),
  );

  sl.registerLazySingleton<GetOnboardingPreferencesUseCase>(
    () => GetOnboardingPreferencesUseCase(sl<OnboardingRepository>()),
  );

  sl.registerLazySingleton<InitInterestScoresUseCase>(
    () => InitInterestScoresUseCase(sl<LocalCacheService>()),
  );

  // Cubit (Factory - new instance each time)
  // ─────────────────
  sl.registerFactory<OnboardingFlowCubit>(
    () => OnboardingFlowCubit(
      savePreferencesUseCase: sl<SaveOnboardingPreferencesUseCase>(),
      getPreferencesUseCase: sl<GetOnboardingPreferencesUseCase>(),
      initInterestScoresUseCase: sl<InitInterestScoresUseCase>(),
      cacheService: sl<LocalCacheService>(),
      logger: sl<Logger>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════
  // 4. FEATURES - PERMISSIONS
  // ═══════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<PermissionLocalDataSource>(
    () => PermissionLocalDataSourceImpl(cacheService: sl<LocalCacheService>()),
  );

  // Repository
  sl.registerLazySingleton<PermissionRepository>(
    () => PermissionRepositoryImpl(
      localDataSource: sl<PermissionLocalDataSource>(),
      locationService: sl<LocationService>(),
      notificationService: sl<NotificationService>(),
      logger: sl<Logger>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<CheckPermissionStatusUseCase>(
    () => CheckPermissionStatusUseCase(sl<PermissionRepository>()),
  );

  sl.registerLazySingleton<RequestLocationPermissionUseCase>(
    () => RequestLocationPermissionUseCase(sl<PermissionRepository>()),
  );

  sl.registerLazySingleton<DetermineNextPermissionStepUseCase>(
    () => DetermineNextPermissionStepUseCase(),
  );

  // Cubit
  sl.registerFactory<PermissionFlowCubit>(
    () => PermissionFlowCubit(
      checkPermissionStatusUseCase: sl<CheckPermissionStatusUseCase>(),
      requestLocationPermissionUseCase: sl<RequestLocationPermissionUseCase>(),
      determineNextPermissionStepUseCase: sl<DetermineNextPermissionStepUseCase>(),
      repository: sl<PermissionRepository>(),
      logger: sl<Logger>(),
      notificationService: sl<NotificationService>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════
  // 5. FEATURES - DATA SOURCES
  // ═══════════════════════════════════════════════════════════

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

  // Coupons Feature
  // ─────────────────
  // TODO: Register Coupons Data Sources when implemented
  // sl.registerLazySingleton<CouponsRemoteDataSource>(
  //   () => CouponsRemoteDataSourceImpl(client: sl<DioClient>()),
  // );
  // sl.registerLazySingleton<CouponsLocalDataSource>(
  //   () => CouponsLocalDataSourceImpl(cacheService: sl<LocalCacheService>()),
  // );

  // Stores Feature
  // ─────────────────
  // TODO: Register Stores Data Sources when implemented
  // sl.registerLazySingleton<StoresRemoteDataSource>(
  //   () => StoresRemoteDataSourceImpl(client: sl<DioClient>()),
  // );
  // sl.registerLazySingleton<StoresLocalDataSource>(
  //   () => StoresLocalDataSourceImpl(cacheService: sl<LocalCacheService>()),
  // );

  // ═══════════════════════════════════════════════════════════
  // 6. FEATURES - REPOSITORIES
  // ═══════════════════════════════════════════════════════════

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

  // Coupons Repository
  // ─────────────────
  // TODO: Register Coupons Repository when implemented
  // sl.registerLazySingleton<CouponsRepository>(
  //   () => CouponsRepositoryImpl(
  //     remoteDataSource: sl<CouponsRemoteDataSource>(),
  //     localDataSource: sl<CouponsLocalDataSource>(),
  //     networkInfo: sl<NetworkInfo>(),
  //     cacheService: sl<LocalCacheService>(),
  //   ),
  // );

  // Stores Repository
  // ─────────────────
  // TODO: Register Stores Repository when implemented
  // sl.registerLazySingleton<StoresRepository>(
  //   () => StoresRepositoryImpl(
  //     remoteDataSource: sl<StoresRemoteDataSource>(),
  //     localDataSource: sl<StoresLocalDataSource>(),
  //     networkInfo: sl<NetworkInfo>(),
  //     cacheService: sl<LocalCacheService>(),
  //   ),
  // );

  // ═══════════════════════════════════════════════════════════
  // 7. FEATURES - CUBITS/BLOCS (Factory - New instance each time)
  // أضف هذا السطر ليعرف البرنامج وجود الـ Cubit
  // تسجيل الـ Cubit الخاص بك (تأكد من مطابقة الـ Constructor)

  // ═══════════════════════════════════════════════════════════

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

  // Coupons Cubits
  // ─────────────────
  // TODO: Register Coupons Cubits when implemented
  // sl.registerFactory<CouponsCubit>(
  //   () => CouponsCubit(repository: sl<CouponsRepository>()),
  // );
  // sl.registerFactory<CouponDetailsCubit>(
  //   () => CouponDetailsCubit(repository: sl<CouponsRepository>()),
  // );

  // Stores Cubits
  // ─────────────────
  // TODO: Register Stores Cubits when implemented
  // sl.registerFactory<StoresCubit>(
  //   () => StoresCubit(repository: sl<StoresRepository>()),
  // );
  // sl.registerFactory<StoreDetailsCubit>(
  //   () => StoreDetailsCubit(repository: sl<StoresRepository>()),
  // );
}

/// Reset all registrations (useful for testing)
Future<void> reset() async {
  await sl.reset();
}
