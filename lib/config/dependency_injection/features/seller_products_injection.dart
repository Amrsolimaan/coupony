import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../../../features/seller_flow/SellerCreateProduct/data/datasources/seller_products_remote_data_source.dart';
import '../../../features/seller_flow/SellerCreateProduct/data/repositories/seller_products_repository_impl.dart';
import '../../../features/seller_flow/SellerCreateProduct/domain/repositories/seller_products_repository.dart';
import '../../../features/seller_flow/SellerCreateProduct/domain/use_cases/create_product_use_case.dart';
import '../../../features/seller_flow/SellerCreateProduct/domain/use_cases/delete_product_use_case.dart';
import '../../../features/seller_flow/SellerCreateProduct/domain/use_cases/get_product_use_case.dart';
import '../../../features/seller_flow/SellerCreateProduct/domain/use_cases/list_products_use_case.dart';
import '../../../features/seller_flow/SellerCreateProduct/domain/use_cases/update_product_status_use_case.dart';
import '../../../features/seller_flow/SellerCreateProduct/domain/use_cases/update_product_use_case.dart';
import '../../../features/seller_flow/SellerCreateProduct/presentation/cubit/seller_products_cubit.dart';

void registerSellerProductsDependencies(GetIt sl) {
  // ════════════════════════════════════════════════════════
  // DATA SOURCE
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<SellerProductsRemoteDataSource>(
    () => SellerProductsRemoteDataSourceImpl(
      client: sl<DioClient>(),
      logger: sl<Logger>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // REPOSITORY
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<SellerProductsRepository>(
    () => SellerProductsRepositoryImpl(
      remoteDataSource: sl<SellerProductsRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      logger: sl<Logger>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // USE CASES
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<ListProductsUseCase>(
    () => ListProductsUseCase(sl<SellerProductsRepository>()),
  );

  sl.registerLazySingleton<CreateProductUseCase>(
    () => CreateProductUseCase(sl<SellerProductsRepository>()),
  );

  sl.registerLazySingleton<GetProductUseCase>(
    () => GetProductUseCase(sl<SellerProductsRepository>()),
  );

  sl.registerLazySingleton<UpdateProductUseCase>(
    () => UpdateProductUseCase(sl<SellerProductsRepository>()),
  );

  sl.registerLazySingleton<UpdateProductStatusUseCase>(
    () => UpdateProductStatusUseCase(sl<SellerProductsRepository>()),
  );

  sl.registerLazySingleton<DeleteProductUseCase>(
    () => DeleteProductUseCase(sl<SellerProductsRepository>()),
  );

  // ════════════════════════════════════════════════════════
  // CUBIT (factory — new instance per screen)
  // ════════════════════════════════════════════════════════

  sl.registerFactory<SellerProductsCubit>(
    () => SellerProductsCubit(
      listProductsUseCase: sl<ListProductsUseCase>(),
      createProductUseCase: sl<CreateProductUseCase>(),
      getProductUseCase: sl<GetProductUseCase>(),
      updateProductUseCase: sl<UpdateProductUseCase>(),
      updateProductStatusUseCase: sl<UpdateProductStatusUseCase>(),
      deleteProductUseCase: sl<DeleteProductUseCase>(),
      logger: sl<Logger>(),
    ),
  );
}
