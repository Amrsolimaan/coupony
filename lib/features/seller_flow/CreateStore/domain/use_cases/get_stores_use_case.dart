import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../auth/data/models/user_store_model.dart';
import '../repositories/create_store_repository.dart';

/// Use case for fetching the authenticated seller's stores list.
/// 
/// Returns the full store details including status, rejection_reason, etc.
class GetStoresUseCase {
  final CreateStoreRepository repository;

  const GetStoresUseCase(this.repository);

  Future<Either<Failure, List<UserStoreModel>>> call() async {
    return await repository.getStores();
  }
}
