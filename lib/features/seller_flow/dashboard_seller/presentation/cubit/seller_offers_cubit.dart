import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/offer_entity.dart';
import 'seller_offers_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER OFFERS CUBIT  —  List management (fetch + delete + tab filter)
// ─────────────────────────────────────────────────────────────────────────────

class SellerOffersCubit extends Cubit<SellerOffersState> {
  SellerOffersCubit({
    required bool isGuest,
    required bool isPending,
  }) : super(SellerOffersInitial(isGuest: isGuest, isPending: isPending)) {
    _initialize(isGuest: isGuest, isPending: isPending);
  }

  /// Internal source-of-truth list; tab filtering operates on top of this.
  List<OfferEntity> _allOffers = [];

  // ── Init ───────────────────────────────────────────────────────────────────

  void _initialize({required bool isGuest, required bool isPending}) {
    if (isGuest) {
      emit(const SellerOffersGuest());
    } else if (isPending) {
      emit(const SellerOffersPending());
    } else {
      loadOffers();
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> loadOffers() async {
    // ✅ Guard: Skip API call if in guest/pending mode
    if (state is SellerOffersGuest || state is SellerOffersPending) {
      return;
    }
    
    emit(const SellerOffersLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    if (isClosed) return;
    _allOffers = OfferEntity.mockList();
    emit(SellerOffersDataLoaded(_allOffers));
  }

  /// Switches the active filter tab and re-emits with the same data.
  void changeTab(int index) {
    final current = state;
    if (current is! SellerOffersDataLoaded) return;
    emit(SellerOffersDataLoaded(_allOffers, activeTabIndex: index));
  }

  /// Removes offer by [id] immediately (optimistic delete).
  void deleteOffer(String id) {
    _allOffers = _allOffers.where((o) => o.id != id).toList(growable: false);
    final tabIndex = _currentTabIndex;
    emit(SellerOffersDataLoaded(_allOffers, activeTabIndex: tabIndex));
  }

  /// Prepends a newly created offer to the list.
  void addOffer(OfferEntity offer) {
    _allOffers = [offer, ..._allOffers];
    emit(SellerOffersDataLoaded(_allOffers, activeTabIndex: _currentTabIndex));
  }

  /// Replaces an edited offer in-place.
  void updateOffer(OfferEntity updated) {
    _allOffers = _allOffers.map((o) => o.id == updated.id ? updated : o).toList();
    emit(SellerOffersDataLoaded(_allOffers, activeTabIndex: _currentTabIndex));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  int get _currentTabIndex =>
      state is SellerOffersDataLoaded ? (state as SellerOffersDataLoaded).activeTabIndex : 0;
}
