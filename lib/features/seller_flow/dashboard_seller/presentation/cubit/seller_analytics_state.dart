import 'package:equatable/equatable.dart';
import '../../domain/entities/seller_analytics_entity.dart';

// ════════════════════════════════════════════════════════════════════════════
// ANALYTICS FILTER ENUM
// ════════════════════════════════════════════════════════════════════════════

enum AnalyticsFilter { all, today, last7Days, thisMonth, thisYear }

// ════════════════════════════════════════════════════════════════════════════
// SELLER ANALYTICS STATES
// ════════════════════════════════════════════════════════════════════════════

abstract class SellerAnalyticsState extends Equatable {
  const SellerAnalyticsState();

  @override
  List<Object?> get props => [];
}

/// Initial — cubit just created, no operation started yet.
class SellerAnalyticsInitial extends SellerAnalyticsState {
  final bool isGuest;
  final bool isPending;

  const SellerAnalyticsInitial({
    this.isGuest = false,
    this.isPending = false,
  });

  @override
  List<Object?> get props => [isGuest, isPending];
}

/// Fetching analytics data.
class SellerAnalyticsLoading extends SellerAnalyticsState {
  const SellerAnalyticsLoading();
}

/// Analytics data loaded successfully.
class SellerAnalyticsDataLoaded extends SellerAnalyticsState {
  final SellerAnalyticsEntity analytics;
  final AnalyticsFilter selectedFilter;

  const SellerAnalyticsDataLoaded({
    required this.analytics,
    this.selectedFilter = AnalyticsFilter.all,
  });

  @override
  List<Object?> get props => [analytics, selectedFilter];
}

/// Seller has not set up an account yet (guest view).
class SellerAnalyticsGuest extends SellerAnalyticsState {
  const SellerAnalyticsGuest();
}

/// Store submitted but still under review.
class SellerAnalyticsPending extends SellerAnalyticsState {
  const SellerAnalyticsPending();
}

/// An operation failed.
class SellerAnalyticsError extends SellerAnalyticsState {
  final String message;

  const SellerAnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
