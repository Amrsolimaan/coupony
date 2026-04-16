import 'package:dartz/dartz.dart';

import 'package:coupony/core/errors/failures.dart';
import '../../domain/entities/home_banner_entity.dart';
import '../../domain/entities/home_category_entity.dart';
import '../../domain/entities/home_offer_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_mock_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl();

  @override
  Future<Either<Failure, List<HomeCategoryEntity>>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(HomeMockDataSource.categories);
  }

  @override
  Future<Either<Failure, List<HomeBannerEntity>>> getBanners() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(HomeMockDataSource.banners);
  }

  @override
  Future<Either<Failure, List<HomeOfferEntity>>> getPersonalizedOffers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(HomeMockDataSource.personalizedOffers);
  }

  @override
  Future<Either<Failure, List<HomeOfferEntity>>> getTravelOffers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(HomeMockDataSource.travelOffers);
  }

  @override
  Future<Either<Failure, List<HomeOfferEntity>>> getEgyptOffers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(HomeMockDataSource.egyptOffers);
  }

  @override
  Future<Either<Failure, List<HomeOfferEntity>>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(HomeMockDataSource.favorites);
  }
}
