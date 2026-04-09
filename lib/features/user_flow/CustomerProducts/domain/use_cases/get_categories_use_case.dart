import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/public_category.dart';
import '../repositories/public_products_repository.dart';

class GetPublicCategoriesUseCase {
  final PublicProductsRepository repository;

  const GetPublicCategoriesUseCase(this.repository);

  Future<Either<Failure, List<PublicCategory>>> call() {
    return repository.getCategories();
  }
}
