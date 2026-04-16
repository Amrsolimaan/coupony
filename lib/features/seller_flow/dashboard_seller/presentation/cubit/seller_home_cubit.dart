import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/offer_entity.dart';
import '../../domain/entities/store_stats_entity.dart';
import 'seller_home_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER HOME CUBIT
// ─────────────────────────────────────────────────────────────────────────────

class SellerHomeCubit extends Cubit<SellerHomeState> {
  // ── View-mode flags are gone. PersonaCubit (root singleton) is the single
  // ── authority for guest / pending / active branching. This cubit handles
  // ── only the active-seller data path.
  SellerHomeCubit() : super(const SellerHomeLoading()) {
    _loadMockData();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadMockData() async {
    emit(const SellerHomeLoading());

    // Simulate a brief network round-trip.
    await Future.delayed(const Duration(milliseconds: 500));
    if (isClosed) return;

    final activeOffers = OfferEntity.mockList()
        .where((o) => o.offerStatus == OfferStatus.active)
        .toList();

    emit(SellerHomeDataLoaded(
      stats: StoreStatsEntity.mock(),
      activeOffers: activeOffers,
    ));
  }

  /// Manually refresh (e.g. pull-to-refresh).
  Future<void> refresh() => _loadMockData();

  // ── Filter update ──────────────────────────────────────────────────────────

  Future<void> changeDateFilter(DateFilterType type, {DateTimeRange? customRange}) async {
    final currentState = state;
    if (currentState is! SellerHomeDataLoaded) return;

    // Immediately update the filter in the UI (keeps it responsive)
    emit(currentState.copyWith(filterType: type, customDateRange: customRange));

    // Wait a little to simulate fetching new data for the selected range
    await Future.delayed(const Duration(milliseconds: 300));
    if (isClosed) return;

    // Generate some slightly varied mock stats to show the UI updated
    final isCustom = type == DateFilterType.custom;
    final stats = StoreStatsEntity(
      views: isCustom ? 1205 : (type == DateFilterType.last30Days ? 9840 : 2540),
      shares: isCustom ? 45 : (type == DateFilterType.last30Days ? 320 : 124),
      activeOffers: currentState.stats.activeOffers,
      usedCoupons: isCustom ? 12 : (type == DateFilterType.last30Days ? 840 : 154),
    );

    emit(currentState.copyWith(
      filterType: type,
      customDateRange: customRange,
      stats: stats,
    ));
  }
}
