import 'package:dartz/dartz.dart';
import 'package:coupony/core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/seller_products_repository.dart';
import 'create_product_use_case.dart';

// ════════════════════════════════════════════════════════
// PARAMS
// ════════════════════════════════════════════════════════

class UpdateProductParams {
  final String storeId;
  final String productId;
  final String? title;
  final String? slug;
  final String? shortDescription;
  final String? description;
  final String? status;
  final bool? isFeatured;
  final List<int>? categoryIds;
  final List<ProductVariantInput>? variants;

  const UpdateProductParams({
    required this.storeId,
    required this.productId,
    this.title,
    this.slug,
    this.shortDescription,
    this.description,
    this.status,
    this.isFeatured,
    this.categoryIds,
    this.variants,
  });
}

// ════════════════════════════════════════════════════════
// USE CASE
// ════════════════════════════════════════════════════════

class UpdateProductUseCase {
  final SellerProductsRepository repository;

  const UpdateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(UpdateProductParams params) {
    return repository.updateProduct(params);
  }
}
