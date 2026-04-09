import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/paginated_result.dart';
import '../entities/public_category.dart';
import '../entities/public_product.dart';
import '../use_cases/get_category_products_use_case.dart';
import '../use_cases/get_public_products_use_case.dart';

abstract class PublicProductsRepository {
  /// GET /products  — paginated, filterable
  Future<Either<Failure, PaginatedResult<PublicProduct>>> getPublicProducts(
    GetPublicProductsParams params,
  );

  /// GET /products/{id}
  Future<Either<Failure, PublicProduct>> getProductDetails(String productId);

  /// GET /categories  — cached locally for 1 week
  Future<Either<Failure, List<PublicCategory>>> getCategories();

  /// GET /categories/{id}/products  — paginated
  Future<Either<Failure, PaginatedResult<PublicProduct>>> getCategoryProducts(
    GetCategoryProductsParams params,
  );
}
