import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/seller_analytics_model.dart';
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
    if (isGuest) {
      emit(const SellerAnalyticsGuest());
    } else if (isPending) {
      emit(const SellerAnalyticsPending());
    } else {
      loadAnalytics();
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Loads analytics for [filter]. Shows loading → then emits data.
  Future<void> loadAnalytics([
    AnalyticsFilter filter = AnalyticsFilter.all,
  ]) async {
    // ✅ Guard: Skip API call if in guest/pending mode
    if (state is SellerAnalyticsGuest || state is SellerAnalyticsPending) {
      return;
    }
    
    emit(const SellerAnalyticsLoading());

    // Simulated network delay — replace with real repository call later.
    await Future.delayed(const Duration(seconds: 1));

    if (isClosed) return;
    emit(SellerAnalyticsDataLoaded(
      analytics: SellerAnalyticsModel.mock(),
      selectedFilter: filter,
    ));
  }

  /// Switches filter and reloads data.
  void changeFilter(AnalyticsFilter filter) => loadAnalytics(filter);

}
