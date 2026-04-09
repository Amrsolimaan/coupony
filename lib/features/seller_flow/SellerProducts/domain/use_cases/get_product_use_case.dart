import 'package:dartz/dartz.dart';
import 'package:coupony/core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/seller_products_repository.dart';

class GetProductUseCase {
  final SellerProductsRepository repository;

  const GetProductUseCase(this.repository);

  Future<Either<Failure, Product>> call({
    required String storeId,
    required String productId,
  }) {
    return repository.getProduct(storeId: storeId, productId: productId);
  }
}
