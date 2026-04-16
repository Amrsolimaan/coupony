import 'package:coupony/features/Profile/data/datasources/profile_remote_data_source.dart';
import 'package:coupony/features/Profile/data/datasources/address_remote_data_source.dart';
import 'package:coupony/features/Profile/data/datasources/report_remote_data_source.dart';
import 'package:coupony/features/Profile/data/repositories/profile_repository_impl.dart';
import 'package:coupony/features/Profile/data/repositories/report_repository_impl.dart';
import 'package:coupony/features/Profile/domain/repositories/profile_repository.dart';
import 'package:coupony/features/Profile/domain/repositories/report_repository.dart';
import 'package:coupony/features/Profile/domain/use_cases/delete_account_use_case.dart';
import 'package:coupony/features/Profile/domain/use_cases/get_profile_use_case.dart';
import 'package:coupony/features/Profile/domain/use_cases/update_profile_use_case.dart';
import 'package:coupony/features/Profile/domain/use_cases/submit_customer_report_use_case.dart';
import 'package:coupony/features/Profile/domain/use_cases/submit_seller_report_use_case.dart';
import 'package:coupony/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:coupony/features/Profile/presentation/cubit/Customer_Profile_cubit.dart';
import 'package:coupony/features/Profile/presentation/cubit/change_password_cubit.dart';
import 'package:coupony/features/Profile/presentation/cubit/stores_display_cubit.dart';
import 'package:coupony/features/Profile/presentation/cubit/report_problem_cubit.dart';
import 'package:coupony/features/Profile/data/data_sources/address_local_data_source.dart';
import 'package:coupony/features/Profile/data/repositories/address_repository_impl.dart';
import 'package:coupony/features/Profile/domain/repositories/address_repository.dart';
import 'package:coupony/features/Profile/presentation/cubit/address_cubit.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/use_cases/get_stores_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../../../core/storage/local_cache_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../../features/auth/presentation/cubit/persona_cubit.dart';


void registerProfileDependencies(GetIt sl) {
  // ════════════════════════════════════════════════════════
  // DATA SOURCES
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      client:       sl<DioClient>(),
      logger:       sl<Logger>(),
      secureStorage: sl<SecureStorageService>(),
      personaCubit: sl<PersonaCubit>(), // breaks X-User-Role circular dependency
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

  // Report Remote Data Source
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(
      client: sl<DioClient>(),
      logger: sl<Logger>(),
    ),
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

  // Report Repository
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      remoteDataSource: sl<ReportRemoteDataSource>(),
      networkInfo:      sl<NetworkInfo>(),
    ),
  );

  // ════════════════════════════════════════════════════════
  // USE CASES
  // ════════════════════════════════════════════════════════

  sl.registerLazySingleton(() => GetProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => SubmitCustomerReportUseCase(sl<ReportRepository>()));
  sl.registerLazySingleton(() => SubmitSellerReportUseCase(sl<ReportRepository>()));

  // ════════════════════════════════════════════════════════
  // CUBITS
  // ════════════════════════════════════════════════════════

  // Factory — a fresh cubit is created each time the profile screen is opened.
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getProfileUseCase:    sl<GetProfileUseCase>(),
      updateProfileUseCase: sl<UpdateProfileUseCase>(),
      deleteAccountUseCase: sl<DeleteAccountUseCase>(),
      logoutUseCase:        sl<LogoutUseCase>(),
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

  // Stores Display Cubit (with caching + selectedStoreId tracking)
  sl.registerFactory<StoresDisplayCubit>(
    () => StoresDisplayCubit(
      sl<GetStoresUseCase>(),
      sl<AuthLocalDataSource>(),
    ),
  );

  // Report Problem Cubit
  sl.registerFactory<ReportProblemCubit>(
    () => ReportProblemCubit(
      submitCustomerReportUseCase: sl<SubmitCustomerReportUseCase>(),
      submitSellerReportUseCase:   sl<SubmitSellerReportUseCase>(),
      logger:                      sl<Logger>(),
    ),
  );
}
