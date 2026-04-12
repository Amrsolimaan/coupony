import 'package:dartz/dartz.dart';
import 'package:coupony/core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/seller_products_repository.dart';

class UpdateProductStatusUseCase {
  final SellerProductsRepository repository;

  const UpdateProductStatusUseCase(this.repository);

  Future<Either<Failure, Product>> call({
    required String storeId,
    required String productId,
    required String status,
  }) {
    return repository.updateProductStatus(
      storeId: storeId,
      productId: productId,
      status: status,
    );
  }
}
