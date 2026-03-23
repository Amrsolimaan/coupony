import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coupony/core/localization/locale_cubit.dart';
import 'package:coupony/core/services/location_service.dart';
import 'package:coupony/core/services/notification_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/storage/local_cache_service.dart';
import '../../core/storage/secure_storage_service.dart';

// Feature Modules
import 'features/auth_injection.dart';
import 'features/onboarding_injection.dart';
import 'features/permissions_injection.dart';

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
  // 2.5. LOCALIZATION
  // ═══════════════════════════════════════════════════════════

  // LocaleCubit - Manages app language (Singleton to persist across app)
  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(sl<FlutterSecureStorage>()),
  );

  // ═══════════════════════════════════════════════════════════
  // 3. FEATURES - ONBOARDING
  // ═══════════════════════════════════════════════════════════
  registerOnboardingDependencies(sl);

  // ═══════════════════════════════════════════════════════════
  // 4. FEATURES - PERMISSIONS
  // ═══════════════════════════════════════════════════════════
  registerPermissionsDependencies(sl);

  // ═══════════════════════════════════════════════════════════
  // 5. FEATURES - AUTH
  // ═══════════════════════════════════════════════════════════
  registerAuthDependencies(sl);

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
  // 6. FEATURES - REPOSITORIES (Coupons & Stores — pending)
  // ═══════════════════════════════════════════════════════════

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
  // 7. FEATURES - CUBITS/BLOCS (Coupons & Stores — pending)
  // ═══════════════════════════════════════════════════════════

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
