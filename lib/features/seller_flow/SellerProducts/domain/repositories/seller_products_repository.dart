import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/product.dart';
import '../use_cases/create_product_use_case.dart';
import '../use_cases/list_products_use_case.dart';
import '../use_cases/update_product_use_case.dart';

abstract class SellerProductsRepository {
  /// GET /stores/{storeId}/products
  Future<Either<Failure, List<Product>>> listProducts(ListProductsParams params);

  /// POST /stores/{storeId}/products  (multipart/form-data)
  Future<Either<Failure, Product>> createProduct(CreateProductParams params);

  /// GET /stores/{storeId}/products/{productId}
  Future<Either<Failure, Product>> getProduct({
    required String storeId,
    required String productId,
  });

  /// PUT /stores/{storeId}/products/{productId}  (JSON)
  Future<Either<Failure, Product>> updateProduct(UpdateProductParams params);

  /// POST /stores/{storeId}/products/{productId}/status  (_method=PATCH)
  Future<Either<Failure, Product>> updateProductStatus({
    required String storeId,
    required String productId,
    required String status,
  });

  /// DELETE /stores/{storeId}/products/{productId}
  Future<Either<Failure, void>> deleteProduct({
    required String storeId,
    required String productId,
  });
}
