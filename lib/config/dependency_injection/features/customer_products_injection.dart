import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../../../core/storage/local_cache_service.dart';
import '../../../features/user_flow/CustomerProducts/data/datasources/public_products_local_data_source.dart';
import '../../../features/user_flow/CustomerProducts/data/datasources/public_products_remote_data_source.dart';
import '../../../features/user_flow/CustomerProducts/data/repositories/public_products_repository_impl.dart';
import '../../../features/user_flow/CustomerProducts/domain/repositories/public_products_repository.dart';
import '../../../features/user_flow/CustomerProducts/domain/use_cases/get_categories_use_case.dart';
import '../../../features/user_flow/CustomerProducts/domain/use_cases/get_category_products_use_case.dart';
import '../../../features/user_flow/CustomerProducts/domain/use_cases/get_product_details_use_case.dart';
import '../../../features/user_flow/CustomerProducts/domain/use_cases/get_public_products_use_case.dart';
import '../../../features/user_flow/CustomerProducts/presentation/cubit/public_products_cubit.dart';

void registerCustomerProductsDependencies(GetIt sl) {
  // ════════════════════════════════════════════════════════
  // DATA SOURCES
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<PublicProductsRemoteDataSource>(
    () => PublicProductsRemoteDataSourceImpl(
      client: sl<DioClient>(),
      logger: sl<Logger>(),
    ),
  );

  sl.registerLazySingleton<PublicProductsLocalDataSource>(
    () => PublicProductsLocalDataSourceImpl(
      cacheService: sl<LocalCacheService>(),
      logger: sl<Logger>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // REPOSITORY
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<PublicProductsRepository>(
    () => PublicProductsRepositoryImpl(
      remoteDataSource: sl<PublicProductsRemoteDataSource>(),
      localDataSource: sl<PublicProductsLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      logger: sl<Logger>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // USE CASES
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<GetPublicProductsUseCase>(
    () => GetPublicProductsUseCase(sl<PublicProductsRepository>()),
  );

  sl.registerLazySingleton<GetProductDetailsUseCase>(
    () => GetProductDetailsUseCase(sl<PublicProductsRepository>()),
  );

  sl.registerLazySingleton<GetPublicCategoriesUseCase>(
    () => GetPublicCategoriesUseCase(sl<PublicProductsRepository>()),
  );

  sl.registerLazySingleton<GetCategoryProductsUseCase>(
    () => GetCategoryProductsUseCase(sl<PublicProductsRepository>()),
  );

  // ════════════════════════════════════════════════════════
  // CUBIT (factory — new instance per screen)
  // ════════════════════════════════════════════════════════

  sl.registerFactory<PublicProductsCubit>(
    () => PublicProductsCubit(
      getPublicProductsUseCase: sl<GetPublicProductsUseCase>(),
      getProductDetailsUseCase: sl<GetProductDetailsUseCase>(),
      getPublicCategoriesUseCase: sl<GetPublicCategoriesUseCase>(),
      getCategoryProductsUseCase: sl<GetCategoryProductsUseCase>(),
      logger: sl<Logger>(),
    ),
  );
}
