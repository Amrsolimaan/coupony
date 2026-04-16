import 'package:equatable/equatable.dart';

import '../../data/datasources/home_mock_datasource.dart';
import '../../domain/entities/home_banner_entity.dart';
import '../../domain/entities/home_category_entity.dart';
import '../../domain/entities/home_offer_entity.dart';
import '../widgets/home_featured_offers_widget.dart';
import '../widgets/home_stores_row_widget.dart';

abstract class CustomerHomeState extends Equatable {
  const CustomerHomeState();

  @override
  List<Object?> get props => [];
}

class CustomerHomeInitial extends CustomerHomeState {
  const CustomerHomeInitial();
}

/// Skeleton mode: data is mock, isLoading=true → Skeletonizer shows shimmer
class CustomerHomeLoaded extends CustomerHomeState {
  final List<HomeCategoryEntity> categories;
  final List<HomeBannerEntity> banners;
  final List<HomeOfferEntity> personalizedOffers;
  final List<HomeOfferEntity> travelOffers;
  final List<HomeOfferEntity> egyptOffers;
  final List<HomeOfferEntity> favorites;
  final List<StoreItem> stores;
  final List<FeaturedOfferItem> featuredOffers;
  final String userName;
  final String userLocation;
  final DateTime promoEndTime;
  final bool isLoading;

  const CustomerHomeLoaded({
    required this.categories,
    required this.banners,
    required this.personalizedOffers,
    required this.travelOffers,
    required this.egyptOffers,
    required this.favorites,
    required this.stores,
    required this.featuredOffers,
    required this.userName,
    required this.userLocation,
    required this.promoEndTime,
    this.isLoading = false,
  });

  /// Skeleton seed — real-shaped data shown under shimmer during loading
  factory CustomerHomeLoaded.skeleton() => CustomerHomeLoaded(
        categories: HomeMockDataSource.categories,
        banners: HomeMockDataSource.banners,
        personalizedOffers: HomeMockDataSource.personalizedOffers,
        travelOffers: HomeMockDataSource.travelOffers,
        egyptOffers: HomeMockDataSource.egyptOffers,
        favorites: HomeMockDataSource.favorites,
        stores: HomeMockDataSource.stores,
        featuredOffers: HomeMockDataSource.featuredOffers,
        userName: 'مريم عبد العزيز',
        userLocation: '2464 Royal Ln. Mesa, New Jersey',
        promoEndTime: HomeMockDataSource.promoEndTime,
        isLoading: true,
      );

  CustomerHomeLoaded copyWith({
    List<HomeCategoryEntity>? categories,
    List<HomeBannerEntity>? banners,
    List<HomeOfferEntity>? personalizedOffers,
    List<HomeOfferEntity>? travelOffers,
    List<HomeOfferEntity>? egyptOffers,
    List<HomeOfferEntity>? favorites,
    List<StoreItem>? stores,
    List<FeaturedOfferItem>? featuredOffers,
    String? userName,
    String? userLocation,
    DateTime? promoEndTime,
    bool? isLoading,
  }) =>
      CustomerHomeLoaded(
        categories: categories ?? this.categories,
        banners: banners ?? this.banners,
        personalizedOffers: personalizedOffers ?? this.personalizedOffers,
        travelOffers: travelOffers ?? this.travelOffers,
        egyptOffers: egyptOffers ?? this.egyptOffers,
        favorites: favorites ?? this.favorites,
        stores: stores ?? this.stores,
        featuredOffers: featuredOffers ?? this.featuredOffers,
        userName: userName ?? this.userName,
        userLocation: userLocation ?? this.userLocation,
        promoEndTime: promoEndTime ?? this.promoEndTime,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [
        categories,
        banners,
        personalizedOffers,
        travelOffers,
        egyptOffers,
        favorites,
        stores,
        featuredOffers,
        userName,
        userLocation,
        promoEndTime,
        isLoading,
      ];
}

class CustomerHomeError extends CustomerHomeState {
  final String message;

  const CustomerHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
