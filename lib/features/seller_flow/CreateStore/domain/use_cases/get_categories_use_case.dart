import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/category_entity.dart';
import '../repositories/create_store_repository.dart';

class GetCategoriesUseCase {
  final CreateStoreRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<CategoryEntity>>> call() {
    return repository.getCategories();
  }
}
