import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_store_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER STORE CUBIT
// ─────────────────────────────────────────────────────────────────────────────

class SellerStoreCubit extends Cubit<SellerStoreState> {
  SellerStoreCubit({
    bool isGuest = false,
    bool isPending = false,
  }) : super(SellerStoreInitial(
          isGuest: isGuest,
          isPending: isPending,
        )) {
    print('🏪 SellerStoreCubit: Created with isGuest=$isGuest, isPending=$isPending');
    
    // Emit appropriate state based on flags
    if (isGuest) {
      emit(const SellerStoreGuest());
    } else if (isPending) {
      emit(const SellerStorePending());
    } else {
      emit(SellerStoreLoaded(isGuest: isGuest, isPending: isPending));
    }
  }

  // Add store-specific methods here in the future
  // For example: loadStoreData(), updateStoreInfo(), etc.

  @override
  Future<void> close() {
    print('🏪 SellerStoreCubit: Closed');
    return super.close();
  }
}
