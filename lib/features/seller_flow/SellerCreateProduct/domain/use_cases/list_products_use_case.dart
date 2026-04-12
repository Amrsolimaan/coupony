import 'package:dartz/dartz.dart';
import 'package:coupony/core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/seller_products_repository.dart';

class ListProductsParams {
  final String storeId;
  final String? status;
  final String? search;
  final bool? isFeatured;
  final int perPage;

  const ListProductsParams({
    required this.storeId,
    this.status,
    this.search,
    this.isFeatured,
    this.perPage = 15,
  });
}

class ListProductsUseCase {
  final SellerProductsRepository repository;

  const ListProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call(ListProductsParams params) {
    return repository.listProducts(params);
  }
}
