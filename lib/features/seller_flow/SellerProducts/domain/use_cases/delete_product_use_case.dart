import 'package:dartz/dartz.dart';
import 'package:coupony/core/errors/failures.dart';
import '../repositories/seller_products_repository.dart';

class DeleteProductUseCase {
  final SellerProductsRepository repository;

  const DeleteProductUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String storeId,
    required String productId,
  }) {
    return repository.deleteProduct(storeId: storeId, productId: productId);
  }
}
