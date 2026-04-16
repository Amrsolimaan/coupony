import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/home_mock_datasource.dart';
import '../../domain/entities/home_offer_entity.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'customer_home_state.dart';

class CustomerHomeCubit extends Cubit<CustomerHomeState> {
  final GetHomeDataUseCase _getHomeData;

  CustomerHomeCubit(this._getHomeData) : super(const CustomerHomeInitial());

  Future<void> loadHomeData() async {
    // Immediately show skeleton with mock data
    emit(CustomerHomeLoaded.skeleton());

    final result = await _getHomeData();

    result.fold(
      (failure) => emit(CustomerHomeError(failure.message)),
      (data) => emit(
        CustomerHomeLoaded(
          categories: data.categories,
          banners: data.banners,
          personalizedOffers: data.personalizedOffers,
          travelOffers: data.travelOffers,
          egyptOffers: data.egyptOffers,
          favorites: data.favorites,
          stores: HomeMockDataSource.stores,
          featuredOffers: HomeMockDataSource.featuredOffers,
          userName: HomeMockDataSource.userName,
          userLocation: HomeMockDataSource.userLocation,
          promoEndTime: HomeMockDataSource.promoEndTime,
          isLoading: false,
        ),
      ),
    );
  }

  void toggleFavorite(String offerId) {
    final current = state;
    if (current is! CustomerHomeLoaded) return;

    HomeOfferEntity toggle(HomeOfferEntity o) =>
        o.id == offerId ? o.copyWith(isFavorite: !o.isFavorite) : o;

    emit(current.copyWith(
      personalizedOffers: current.personalizedOffers.map(toggle).toList(),
      travelOffers: current.travelOffers.map(toggle).toList(),
      egyptOffers: current.egyptOffers.map(toggle).toList(),
      favorites: current.favorites.map(toggle).toList(),
    ));
  }
}
