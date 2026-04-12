import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_home_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER HOME CUBIT
// ─────────────────────────────────────────────────────────────────────────────

class SellerHomeCubit extends Cubit<SellerHomeState> {
  SellerHomeCubit({
    bool isGuest = false,
    bool isPending = false,
  }) : super(SellerHomeInitial(
          isGuest: isGuest,
          isPending: isPending,
        )) {
    print('🏠 SellerHomeCubit: Created with isGuest=$isGuest, isPending=$isPending');
    
    // Emit appropriate state based on flags
    if (isGuest) {
      emit(const SellerHomeGuest());
    } else if (isPending) {
      emit(const SellerHomePending());
    } else {
      emit(SellerHomeLoaded(isGuest: isGuest, isPending: isPending));
    }
  }

  // Add home-specific methods here in the future
  // For example: loadHomeData(), refreshData(), etc.

  @override
  Future<void> close() {
    print('🏠 SellerHomeCubit: Closed');
    return super.close();
  }
}
