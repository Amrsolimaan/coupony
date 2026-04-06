import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/social_platform_entity.dart';
import '../repositories/create_store_repository.dart';

/// Use case for fetching available social media platforms.
/// 
/// Returns a list of platforms (Facebook, Instagram, etc.) that the user
/// can select when adding social links to their store.
class GetSocialPlatformsUseCase {
  final CreateStoreRepository repository;

  const GetSocialPlatformsUseCase(this.repository);

  Future<Either<Failure, List<SocialPlatformEntity>>> call() {
    return repository.getSocialPlatforms();
  }
}
