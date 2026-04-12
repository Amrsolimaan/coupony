import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../repositories/create_store_repository.dart';
import 'create_store_use_case.dart';

class UpdateStoreUseCase {
  final CreateStoreRepository repository;

  const UpdateStoreUseCase(this.repository);

  Future<Either<Failure, bool>> call(String storeId, CreateStoreParams params) {
    return repository.updateStore(storeId, params);
  }
}
