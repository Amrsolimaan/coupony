import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_offers_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER OFFERS CUBIT
// ─────────────────────────────────────────────────────────────────────────────

class SellerOffersCubit extends Cubit<SellerOffersState> {
  SellerOffersCubit({
    required bool isGuest,
    required bool isPending,
  }) : super(SellerOffersInitial(isGuest: isGuest, isPending: isPending)) {
    _initialize();
  }

  // ── Initialize ─────────────────────────────────────────────────────────────
  void _initialize() {
    final currentState = state;
    
    if (currentState is SellerOffersInitial) {
      if (currentState.isGuest) {
        emit(const SellerOffersGuest());
      } else if (currentState.isPending) {
        emit(const SellerOffersPending());
      } else {
        emit(SellerOffersLoaded(
          isGuest: currentState.isGuest,
          isPending: currentState.isPending,
        ));
      }
    }
  }

  // ── Load Offers Data ───────────────────────────────────────────────────────
  Future<void> loadOffers() async {
    try {
      emit(const SellerOffersLoading());
      
      // TODO: Implement actual data loading logic here
      await Future.delayed(const Duration(seconds: 1));
      
      final currentState = state;
      if (currentState is SellerOffersInitial) {
        emit(SellerOffersLoaded(
          isGuest: currentState.isGuest,
          isPending: currentState.isPending,
        ));
      }
    } catch (e) {
      emit(SellerOffersError(message: e.toString()));
    }
  }
}
