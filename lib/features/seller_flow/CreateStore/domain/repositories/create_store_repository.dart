import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/category_entity.dart';
import '../entities/social_platform_entity.dart';
import '../use_cases/create_store_use_case.dart';

abstract class CreateStoreRepository {
  /// POST /api/v1/stores — creates a new store for the authenticated seller.
  Future<Either<Failure, bool>> createStore(CreateStoreParams params);

  /// GET /api/v1/categories — fetches the list of available categories.
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// GET /api/v1/socials — fetches the list of available social media platforms.
  Future<Either<Failure, List<SocialPlatformEntity>>> getSocialPlatforms();
}
