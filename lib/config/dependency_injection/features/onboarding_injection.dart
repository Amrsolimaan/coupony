import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../../../core/storage/local_cache_service.dart';
import '../../../features/onboarding/data/data_sources/onboarding_local_data_source.dart';
import '../../../features/onboarding/data/data_sources/onboarding_remote_data_source.dart';
import '../../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../../features/onboarding/domain/use_cases/get_onboarding_preferences_use_case.dart';
import '../../../features/onboarding/domain/use_cases/init_interest_scores_use_case.dart';
import '../../../features/onboarding/domain/use_cases/save_onboarding_preferences_use_case.dart';
import '../../../features/onboarding/presentation/cubit/onboarding_flow_cubit.dart';

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

  // Cubit (Factory - new instance each time)
  sl.registerFactory<OnboardingFlowCubit>(
    () => OnboardingFlowCubit(
      savePreferencesUseCase: sl<SaveOnboardingPreferencesUseCase>(),
      getPreferencesUseCase: sl<GetOnboardingPreferencesUseCase>(),
      initInterestScoresUseCase: sl<InitInterestScoresUseCase>(),
      cacheService: sl<LocalCacheService>(),
      logger: sl<Logger>(),
    ),
  );
}
