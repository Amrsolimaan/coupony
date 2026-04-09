import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/paginated_result.dart';
import '../entities/public_product.dart';
import '../repositories/public_products_repository.dart';

class GetCategoryProductsParams {
  final String categoryId;
  final int page;
  final int perPage;

  const GetCategoryProductsParams({
    required this.categoryId,
    this.page = 1,
    this.perPage = 15,
  });

  GetCategoryProductsParams copyWith({int? page, int? perPage}) {
    return GetCategoryProductsParams(
      categoryId: categoryId,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}

class GetCategoryProductsUseCase {
  final PublicProductsRepository repository;

  const GetCategoryProductsUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<PublicProduct>>> call(
    GetCategoryProductsParams params,
  ) {
    return repository.getCategoryProducts(params);
  }
}
