import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/home_banner_entity.dart';
import '../entities/home_category_entity.dart';
import '../entities/home_offer_entity.dart';
import '../repositories/home_repository.dart';

class HomeData {
  final List<HomeCategoryEntity> categories;
  final List<HomeBannerEntity> banners;
  final List<HomeOfferEntity> personalizedOffers;
  final List<HomeOfferEntity> travelOffers;
  final List<HomeOfferEntity> egyptOffers;
  final List<HomeOfferEntity> favorites;

  const HomeData({
    required this.categories,
    required this.banners,
    required this.personalizedOffers,
    required this.travelOffers,
    required this.egyptOffers,
    required this.favorites,
  });
}

class GetHomeDataUseCase {
  final HomeRepository _repository;

  const GetHomeDataUseCase(this._repository);

  Future<Either<Failure, HomeData>> call() async {
    // Run all fetches concurrently using Future.wait for better performance
    final results = await Future.wait([
      _repository.getCategories(),
      _repository.getBanners(),
      _repository.getPersonalizedOffers(),
      _repository.getTravelOffers(),
      _repository.getEgyptOffers(),
      _repository.getFavorites(),
    ]);

    // Check if any request failed
    for (final result in results) {
      if (result.isLeft()) {
        return result.fold((f) => Left(f), (_) => throw StateError(''));
      }
    }

    // All succeeded, extract data with proper casting
    final categories = (results[0] as Either<Failure, List<HomeCategoryEntity>>).getOrElse(() => []);
    final banners = (results[1] as Either<Failure, List<HomeBannerEntity>>).getOrElse(() => []);
    final personalizedOffers = (results[2] as Either<Failure, List<HomeOfferEntity>>).getOrElse(() => []);
    final travelOffers = (results[3] as Either<Failure, List<HomeOfferEntity>>).getOrElse(() => []);
    final egyptOffers = (results[4] as Either<Failure, List<HomeOfferEntity>>).getOrElse(() => []);
    final favorites = (results[5] as Either<Failure, List<HomeOfferEntity>>).getOrElse(() => []);

    return Right(HomeData(
      categories: categories,
      banners: banners,
      personalizedOffers: personalizedOffers,
      travelOffers: travelOffers,
      egyptOffers: egyptOffers,
      favorites: favorites,
    ));
  }
}
