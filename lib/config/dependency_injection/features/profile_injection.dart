import 'package:coupony/features/Profile/data/datasources/profile_remote_data_source.dart';
import 'package:coupony/features/Profile/data/datasources/address_remote_data_source.dart';
import 'package:coupony/features/Profile/data/repositories/profile_repository_impl.dart';
import 'package:coupony/features/Profile/domain/repositories/profile_repository.dart';
import 'package:coupony/features/Profile/domain/use_cases/delete_account_use_case.dart';
import 'package:coupony/features/Profile/domain/use_cases/get_profile_use_case.dart';
import 'package:coupony/features/Profile/domain/use_cases/update_profile_use_case.dart';
import 'package:coupony/features/Profile/presentation/cubit/Customer_Profile_cubit.dart';
import 'package:coupony/features/Profile/presentation/cubit/change_password_cubit.dart';
import 'package:coupony/features/Profile/data/data_sources/address_local_data_source.dart';
import 'package:coupony/features/Profile/data/repositories/address_repository_impl.dart';
import 'package:coupony/features/Profile/domain/repositories/address_repository.dart';
import 'package:coupony/features/Profile/presentation/cubit/address_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../../../core/storage/local_cache_service.dart';
import '../../../features/auth/data/datasources/auth_local_data_source.dart';


void registerProfileDependencies(GetIt sl) {
  // ════════════════════════════════════════════════════════
  // DATA SOURCES
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      client: sl<DioClient>(),
      logger: sl<Logger>(),
    ),
  );

  // Address Remote Data Source
  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(
      client: sl<DioClient>(),
      logger: sl<Logger>(),
    ),
  );

  // Address Local Data Source
  sl.registerLazySingleton<AddressLocalDataSource>(
    () => AddressLocalDataSourceImpl(),
  );

  // ════════════════════════════════════════════════════════
  // REPOSITORY
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl<ProfileRemoteDataSource>(),
      localDataSource:  sl<AuthLocalDataSource>(),
      networkInfo:      sl<NetworkInfo>(),
      cacheService:     sl<LocalCacheService>(),
    ),
  );

  // Address Repository (Hybrid: API + Hive)
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(
      remoteDataSource: sl<AddressRemoteDataSource>(),
      localDataSource:  sl<AddressLocalDataSource>(),
      networkInfo:      sl<NetworkInfo>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // USE CASES
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton(() => GetProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl<ProfileRepository>()));

  // ════════════════════════════════════════════════════════
  // CUBITS
  // ════════════════════════════════════════════════════════

  // Factory — a fresh cubit is created each time the profile screen is opened.
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getProfileUseCase:    sl<GetProfileUseCase>(),
      updateProfileUseCase: sl<UpdateProfileUseCase>(),
      deleteAccountUseCase: sl<DeleteAccountUseCase>(),
      logger:               sl<Logger>(),
    ),
  );

  // Address Cubit
  sl.registerFactory<AddressCubit>(
    () => AddressCubit(
      repository: sl<AddressRepository>(),
      logger:     sl<Logger>(),
    ),
  );

  // Change Password Cubit
  sl.registerFactory<ChangePasswordCubit>(
    () => ChangePasswordCubit(
      client: sl<DioClient>(),
      logger: sl<Logger>(),
    ),
  );
}
