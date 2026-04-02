
import 'package:coupony/features/seller_flow/SellerOnboarding/data/data_sources/onboarding_Seller_local_data_source.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/data/data_sources/onboarding_Seller_remote_data_source.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/data/repositories/onboarding_Seller_repository_impl.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/domain/repositories/onboarding_Seller_repository.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/domain/use_cases/get_onboarding_preferences_use_case.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/domain/use_cases/save_onboarding_preferences_use_case.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/domain/use_cases/submit_onboarding_use_case.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/cubit/onboarding_Seller_flow_cubit.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/data/data_sources/onboarding_local_data_source.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/data/data_sources/onboarding_remote_data_source.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/repositories/onboarding_repository.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/use_cases/fetch_server_preferences_use_case.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/use_cases/get_onboarding_preferences_use_case.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/use_cases/init_interest_scores_use_case.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/use_cases/save_onboarding_preferences_use_case.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/use_cases/submit_onboarding_use_case.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/cubit/onboarding_flow_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../../../core/storage/local_cache_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../features/auth/data/datasources/auth_local_data_source.dart';

void registerOnboardingDependencies(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(cacheService: sl<LocalCacheService>()),
  );

  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(client: sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      localDataSource: sl<OnboardingLocalDataSource>(),
      remoteDataSource: sl<OnboardingRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      cacheService: sl<LocalCacheService>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<SaveOnboardingPreferencesUseCase>(
    () => SaveOnboardingPreferencesUseCase(sl<OnboardingRepository>()),
  );

  sl.registerLazySingleton<GetOnboardingPreferencesUseCase>(
    () => GetOnboardingPreferencesUseCase(sl<OnboardingRepository>()),
  );

  sl.registerLazySingleton<InitInterestScoresUseCase>(
    () => InitInterestScoresUseCase(sl<LocalCacheService>()),
  );

  sl.registerLazySingleton<SubmitOnboardingUseCase>(
    () => SubmitOnboardingUseCase(sl<OnboardingRepository>()),
  );

  sl.registerLazySingleton<FetchServerPreferencesUseCase>(
    () => FetchServerPreferencesUseCase(sl<OnboardingRepository>()),
  );

  // Cubit (Factory - new instance each time)
  sl.registerFactory<OnboardingFlowCubit>(
    () => OnboardingFlowCubit(
      savePreferencesUseCase: sl<SaveOnboardingPreferencesUseCase>(),
      getPreferencesUseCase: sl<GetOnboardingPreferencesUseCase>(),
      initInterestScoresUseCase: sl<InitInterestScoresUseCase>(),
      submitOnboardingUseCase: sl<SubmitOnboardingUseCase>(),
      cacheService: sl<LocalCacheService>(),
      secureStorage: sl<SecureStorageService>(),
      authLocalDataSource: sl<AuthLocalDataSource>(),
      logger: sl<Logger>(),
    ),
  );

  // ── Seller Onboarding ─────────────────────────────────────────────────────

  // Data Sources
  sl.registerLazySingleton<SellerOnboardingLocalDataSource>(
    () => SellerOnboardingLocalDataSourceImpl(
      cacheService: sl<LocalCacheService>(),
    ),
  );

  sl.registerLazySingleton<SellerOnboardingRemoteDataSource>(
    () => SellerOnboardingRemoteDataSourceImpl(client: sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<SellerOnboardingRepository>(
    () => SellerOnboardingRepositoryImpl(
      localDataSource: sl<SellerOnboardingLocalDataSource>(),
      remoteDataSource: sl<SellerOnboardingRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      cacheService: sl<LocalCacheService>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<SaveSellerOnboardingPreferencesUseCase>(
    () => SaveSellerOnboardingPreferencesUseCase(
      sl<SellerOnboardingRepository>(),
    ),
  );

  sl.registerLazySingleton<GetSellerOnboardingPreferencesUseCase>(
    () => GetSellerOnboardingPreferencesUseCase(
      sl<SellerOnboardingRepository>(),
    ),
  );

  sl.registerLazySingleton<SubmitSellerOnboardingUseCase>(
    () => SubmitSellerOnboardingUseCase(sl<SellerOnboardingRepository>()),
  );

  // Cubit (Factory - new instance each time)
  sl.registerFactory<SellerOnboardingFlowCubit>(
    () => SellerOnboardingFlowCubit(
      savePreferencesUseCase: sl<SaveSellerOnboardingPreferencesUseCase>(),
      getPreferencesUseCase: sl<GetSellerOnboardingPreferencesUseCase>(),
      submitOnboardingUseCase: sl<SubmitSellerOnboardingUseCase>(),
      secureStorage: sl<SecureStorageService>(),
      authLocalDataSource: sl<AuthLocalDataSource>(),
      logger: sl<Logger>(),
    ),
  );
}
