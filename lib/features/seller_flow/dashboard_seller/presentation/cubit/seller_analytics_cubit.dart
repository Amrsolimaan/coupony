import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_analytics_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER ANALYTICS CUBIT
// ─────────────────────────────────────────────────────────────────────────────

class SellerAnalyticsCubit extends Cubit<SellerAnalyticsState> {
  SellerAnalyticsCubit({
    bool isGuest = false,
    bool isPending = false,
  }) : super(SellerAnalyticsInitial(
          isGuest: isGuest,
          isPending: isPending,
        )) {
    print('📊 SellerAnalyticsCubit: Created with isGuest=$isGuest, isPending=$isPending');
    
    // Emit appropriate state based on flags
    if (isGuest) {
      emit(const SellerAnalyticsGuest());
    } else if (isPending) {
      emit(const SellerAnalyticsPending());
    } else {
      emit(SellerAnalyticsLoaded(isGuest: isGuest, isPending: isPending));
    }
  }

  // Add analytics-specific methods here in the future
  // For example: loadAnalyticsData(), refreshData(), etc.

  @override
  Future<void> close() {
    print('📊 SellerAnalyticsCubit: Closed');
    return super.close();
  }
}
