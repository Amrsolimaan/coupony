import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/local_cache_service.dart';
import '../../../features/permissions/data/data_sources/location_geocoding_data_source.dart';
import '../../../features/permissions/data/data_sources/permission_local_data_source.dart';
import '../../../features/permissions/data/repositories/permission_repository_impl.dart';
import '../../../features/permissions/domain/repositories/permission_repository.dart';
import '../../../features/permissions/domain/use_cases/check_permission_status_use_case.dart';
import '../../../features/permissions/domain/use_cases/determine_next_permission_step_use_case.dart';
import '../../../features/permissions/domain/use_cases/get_address_from_coordinates_use_case.dart';
import '../../../features/permissions/domain/use_cases/request_location_permission_use_case.dart';
import '../../../features/permissions/presentation/cubit/permission_flow_cubit.dart';

void registerPermissionsDependencies(GetIt sl) {
  // ── Data Sources ───────────────────────────────────────────────────────────

  sl.registerLazySingleton<PermissionLocalDataSource>(
    () => PermissionLocalDataSourceImpl(cacheService: sl<LocalCacheService>()),
  );

  sl.registerLazySingleton<LocationGeocodingDataSource>(
    () => LocationGeocodingDataSourceImpl(logger: sl<Logger>()),
  );

  // ── Repository ─────────────────────────────────────────────────────────────

  sl.registerLazySingleton<PermissionRepository>(
    () => PermissionRepositoryImpl(
      localDataSource: sl<PermissionLocalDataSource>(),
      locationService: sl<LocationService>(),
      notificationService: sl<NotificationService>(),
      geocodingDataSource: sl<LocationGeocodingDataSource>(),
      logger: sl<Logger>(),
    ),
  );

  // ── Use Cases ──────────────────────────────────────────────────────────────

  sl.registerLazySingleton<CheckPermissionStatusUseCase>(
    () => CheckPermissionStatusUseCase(sl<PermissionRepository>()),
  );

  sl.registerLazySingleton<RequestLocationPermissionUseCase>(
    () => RequestLocationPermissionUseCase(sl<PermissionRepository>()),
  );

  sl.registerLazySingleton<DetermineNextPermissionStepUseCase>(
    () => DetermineNextPermissionStepUseCase(),
  );

  sl.registerLazySingleton<GetAddressFromCoordinatesUseCase>(
    () => GetAddressFromCoordinatesUseCase(sl<PermissionRepository>()),
  );

  // ── Cubit (factory — new instance each time) ───────────────────────────────

  sl.registerFactory<PermissionFlowCubit>(
    () => PermissionFlowCubit(
      checkPermissionStatusUseCase: sl<CheckPermissionStatusUseCase>(),
      requestLocationPermissionUseCase: sl<RequestLocationPermissionUseCase>(),
      determineNextPermissionStepUseCase:
          sl<DetermineNextPermissionStepUseCase>(),
      geocodingUseCase: sl<GetAddressFromCoordinatesUseCase>(),
      repository: sl<PermissionRepository>(),
      logger: sl<Logger>(),
      notificationService: sl<NotificationService>(),
    ),
  );
}
