import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../../../core/services/location_service.dart';
import '../../../features/seller_flow/CreateStore/data/data_sources/create_store_remote_data_source.dart';
import '../../../features/seller_flow/CreateStore/data/repositories/create_store_repository_impl.dart';
import '../../../features/seller_flow/CreateStore/domain/repositories/create_store_repository.dart';
import '../../../features/seller_flow/CreateStore/domain/use_cases/create_store_use_case.dart';
import '../../../features/seller_flow/CreateStore/domain/use_cases/get_categories_use_case.dart';
import '../../../features/seller_flow/CreateStore/presentation/cubit/create_store_cubit.dart';

void registerCreateStoreDependencies(GetIt sl) {
  // ════════════════════════════════════════════════════════
  // DATA SOURCE
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<CreateStoreRemoteDataSource>(
    () => CreateStoreRemoteDataSourceImpl(
      client: sl<DioClient>(),
      logger: sl<Logger>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // REPOSITORY
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<CreateStoreRepository>(
    () => CreateStoreRepositoryImpl(
      remoteDataSource: sl<CreateStoreRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      logger: sl<Logger>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // USE CASES
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<CreateStoreUseCase>(
    () => CreateStoreUseCase(sl<CreateStoreRepository>()),
  );

  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<CreateStoreRepository>()),
  );

  // ════════════════════════════════════════════════════════
  // CUBIT (factory — new instance per screen)
  // ════════════════════════════════════════════════════════

  sl.registerFactory<CreateStoreCubit>(
    () => CreateStoreCubit(
      createStoreUseCase: sl<CreateStoreUseCase>(),
      getCategoriesUseCase: sl<GetCategoriesUseCase>(),
      locationService: sl<LocationService>(),
      logger: sl<Logger>(),
    ),
  );
}
