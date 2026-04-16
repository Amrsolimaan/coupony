import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../../features/seller_flow/dashboard_seller/data/datasources/seller_store_remote_data_source.dart';
import '../../../features/seller_flow/dashboard_seller/data/repositories/seller_store_repository_impl.dart';
import '../../../features/seller_flow/dashboard_seller/domain/repositories/seller_store_repository.dart';
import '../../../features/seller_flow/dashboard_seller/domain/use_cases/get_store_display_use_case.dart';
import '../../../features/seller_flow/dashboard_seller/domain/use_cases/update_store_profile_use_case.dart';
import '../../../features/seller_flow/dashboard_seller/presentation/cubit/edit_store_info_cubit.dart';
import '../../../features/seller_flow/dashboard_seller/presentation/cubit/seller_store_cubit.dart';

// ════════════════════════════════════════════════════════
// SELLER STORE FEATURE - DEPENDENCY INJECTION
// ════════════════════════════════════════════════════════

void registerSellerStoreDependencies(GetIt sl) {
  // ════════════════════════════════════════════════════════
  // DATA SOURCE
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<SellerStoreRemoteDataSource>(
    () => SellerStoreRemoteDataSourceImpl(
      client: sl<DioClient>(),
      logger: sl<Logger>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // REPOSITORY
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<SellerStoreRepository>(
    () => SellerStoreRepositoryImpl(
      remoteDataSource: sl<SellerStoreRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      logger: sl<Logger>(),
      authLocalDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // USE CASE
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<GetStoreDisplayUseCase>(
    () => GetStoreDisplayUseCase(sl<SellerStoreRepository>()),
  );

  // ════════════════════════════════════════════════════════
  // USE CASE — update store profile
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<UpdateStoreProfileUseCase>(
    () => UpdateStoreProfileUseCase(sl<SellerStoreRepository>()),
  );

  // ════════════════════════════════════════════════════════
  // CUBIT — SellerStoreCubit (factory — new instance per screen)
  // ════════════════════════════════════════════════════════

  sl.registerFactoryParam<SellerStoreCubit, bool, bool>(
    (isGuest, isPending) => SellerStoreCubit(
      getStoreDisplayUseCase: sl<GetStoreDisplayUseCase>(),
      isGuest: isGuest,
      isPending: isPending,
    ),
  );

  // ════════════════════════════════════════════════════════
  // CUBIT — EditStoreInfoCubit (factory — new instance per edit screen)
  // ════════════════════════════════════════════════════════

  sl.registerFactory<EditStoreInfoCubit>(
    () => EditStoreInfoCubit(
      updateStoreProfile: sl<UpdateStoreProfileUseCase>(),
    ),
  );
}
