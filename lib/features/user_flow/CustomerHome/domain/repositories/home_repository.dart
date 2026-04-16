import 'package:dartz/dartz.dart';

import 'package:coupony/core/errors/failures.dart';
import '../entities/home_banner_entity.dart';
import '../entities/home_category_entity.dart';
import '../entities/home_offer_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<HomeCategoryEntity>>> getCategories();
  Future<Either<Failure, List<HomeBannerEntity>>> getBanners();
  Future<Either<Failure, List<HomeOfferEntity>>> getPersonalizedOffers();
  Future<Either<Failure, List<HomeOfferEntity>>> getTravelOffers();
  Future<Either<Failure, List<HomeOfferEntity>>> getEgyptOffers();
  Future<Either<Failure, List<HomeOfferEntity>>> getFavorites();
}
