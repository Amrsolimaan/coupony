import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/public_product.dart';
import '../repositories/public_products_repository.dart';

class GetProductDetailsUseCase {
  final PublicProductsRepository repository;

  const GetProductDetailsUseCase(this.repository);

  Future<Either<Failure, PublicProduct>> call(String productId) {
    return repository.getProductDetails(productId);
  }
}
