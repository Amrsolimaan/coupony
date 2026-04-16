import '../../domain/entities/offer_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER OFFERS STATE
// ─────────────────────────────────────────────────────────────────────────────

abstract class SellerOffersState {
  const SellerOffersState();
}

class SellerOffersInitial extends SellerOffersState {
  final bool isGuest;
  final bool isPending;

  const SellerOffersInitial({
    required this.isGuest,
    required this.isPending,
  });
}

class SellerOffersLoading extends SellerOffersState {
  const SellerOffersLoading();
}

/// Offers list loaded and ready — with tab filtering support.
class SellerOffersDataLoaded extends SellerOffersState {
  final List<OfferEntity> offers;

  /// Index of the active filter tab:
  ///   0 = الكل, 1 = النشطة, 2 = المنتهية, 3 = المجدولة
  final int activeTabIndex;

  const SellerOffersDataLoaded(this.offers, {this.activeTabIndex = 0});

  /// Returns only the offers matching the active tab.
  List<OfferEntity> get filteredOffers {
    switch (activeTabIndex) {
      case 1:
        return offers.where((o) => o.offerStatus == OfferStatus.active).toList();
      case 2:
        return offers.where((o) => o.offerStatus == OfferStatus.expired).toList();
      case 3:
        return offers.where((o) => o.offerStatus == OfferStatus.scheduled).toList();
      default:
        return offers;
    }
  }
}

class SellerOffersLoaded extends SellerOffersState {
  final bool isGuest;
  final bool isPending;

  const SellerOffersLoaded({
    required this.isGuest,
    required this.isPending,
  });
}

class SellerOffersGuest extends SellerOffersState {
  const SellerOffersGuest();
}

class SellerOffersPending extends SellerOffersState {
  const SellerOffersPending();
}

class SellerOffersError extends SellerOffersState {
  final String message;

  const SellerOffersError({required this.message});
}
