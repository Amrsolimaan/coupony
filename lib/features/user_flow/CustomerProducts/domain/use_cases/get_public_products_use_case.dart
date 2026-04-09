import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/paginated_result.dart';
import '../entities/public_product.dart';
import '../repositories/public_products_repository.dart';

class GetPublicProductsParams {
  final int page;
  final int perPage;
  final String? categoryId;
  final String? search;
  final bool? featured;

  const GetPublicProductsParams({
    this.page = 1,
    this.perPage = 15,
    this.categoryId,
    this.search,
    this.featured,
  });

  GetPublicProductsParams copyWith({
    int? page,
    int? perPage,
    String? categoryId,
    String? search,
    bool? featured,
    bool clearCategoryId = false,
    bool clearSearch = false,
    bool clearFeatured = false,
  }) {
    return GetPublicProductsParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      search: clearSearch ? null : search ?? this.search,
      featured: clearFeatured ? null : featured ?? this.featured,
    );
  }
}

class GetPublicProductsUseCase {
  final PublicProductsRepository repository;

  const GetPublicProductsUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<PublicProduct>>> call(
    GetPublicProductsParams params,
  ) {
    return repository.getPublicProducts(params);
  }
}
