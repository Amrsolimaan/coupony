import 'package:equatable/equatable.dart';

// ════════════════════════════════════════════════════════
// SELLER ANALYTICS STATE
// ════════════════════════════════════════════════════════

abstract class SellerAnalyticsState extends Equatable {
  const SellerAnalyticsState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no operation has started yet.
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

/// Loading analytics data.
class SellerAnalyticsLoading extends SellerAnalyticsState {
  const SellerAnalyticsLoading();
}

/// Analytics data successfully loaded.
class SellerAnalyticsLoaded extends SellerAnalyticsState {
  final bool isGuest;
  final bool isPending;

  const SellerAnalyticsLoaded({
    this.isGuest = false,
    this.isPending = false,
  });

  @override
  List<Object?> get props => [isGuest, isPending];
}

/// Guest seller view.
class SellerAnalyticsGuest extends SellerAnalyticsState {
  const SellerAnalyticsGuest();
}

/// Pending approval view.
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
