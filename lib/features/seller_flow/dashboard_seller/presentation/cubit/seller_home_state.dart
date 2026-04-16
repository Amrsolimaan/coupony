import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/offer_entity.dart';
import '../../domain/entities/store_stats_entity.dart';

// ════════════════════════════════════════════════════════
// SELLER HOME STATE
// ════════════════════════════════════════════════════════

enum DateFilterType { last7Days, last30Days, custom }

abstract class SellerHomeState extends Equatable {
  const SellerHomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state — before any operation has run.
class SellerHomeInitial extends SellerHomeState {
  final bool isGuest;
  final bool isPending;

  const SellerHomeInitial({this.isGuest = false, this.isPending = false});

  @override
  List<Object?> get props => [isGuest, isPending];
}

/// Fetching home data.
class SellerHomeLoading extends SellerHomeState {
  const SellerHomeLoading();
}

/// Home data successfully loaded — drives the full dashboard UI.
class SellerHomeDataLoaded extends SellerHomeState {
  final StoreStatsEntity stats;

  /// Only the currently-active offers (shown in the "العروض النشطة" section).
  final List<OfferEntity> activeOffers;

  final DateFilterType filterType;
  final DateTimeRange? customDateRange;

  const SellerHomeDataLoaded({
    required this.stats,
    required this.activeOffers,
    this.filterType = DateFilterType.last7Days,
    this.customDateRange,
  });

  SellerHomeDataLoaded copyWith({
    StoreStatsEntity? stats,
    List<OfferEntity>? activeOffers,
    DateFilterType? filterType,
    DateTimeRange? customDateRange,
  }) {
    return SellerHomeDataLoaded(
      stats: stats ?? this.stats,
      activeOffers: activeOffers ?? this.activeOffers,
      filterType: filterType ?? this.filterType,
      customDateRange: customDateRange ?? this.customDateRange,
    );
  }

  @override
  List<Object?> get props => [stats, activeOffers, filterType, customDateRange];
}

/// Legacy loaded state kept for router nav-handler compatibility.
class SellerHomeLoaded extends SellerHomeState {
  final bool isGuest;
  final bool isPending;

  const SellerHomeLoaded({this.isGuest = false, this.isPending = false});

  @override
  List<Object?> get props => [isGuest, isPending];
}

/// Guest seller view.
class SellerHomeGuest extends SellerHomeState {
  const SellerHomeGuest();
}

/// Pending approval view.
class SellerHomePending extends SellerHomeState {
  const SellerHomePending();
}

/// An operation failed.
class SellerHomeError extends SellerHomeState {
  final String message;
  const SellerHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
