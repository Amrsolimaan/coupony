import 'package:get_it/get_it.dart';

import '../../../features/user_flow/CustomerHome/data/repositories/home_repository_impl.dart';
import '../../../features/user_flow/CustomerHome/domain/repositories/home_repository.dart';
import '../../../features/user_flow/CustomerHome/domain/usecases/get_home_data_usecase.dart';
import '../../../features/user_flow/CustomerHome/presentation/cubit/customer_home_cubit.dart';

void registerCustomerHomeDependencies(GetIt sl) {
  // Repository
  sl.registerLazySingleton<HomeRepository>(() => const HomeRepositoryImpl());

  // Use Case
  sl.registerLazySingleton<GetHomeDataUseCase>(
    () => GetHomeDataUseCase(sl<HomeRepository>()),
  );

  // Cubit — factory so each page gets a fresh instance
  sl.registerFactory<CustomerHomeCubit>(
    () => CustomerHomeCubit(sl<GetHomeDataUseCase>()),
  );
}
