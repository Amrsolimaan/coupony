import 'package:equatable/equatable.dart';
import '../../domain/entities/store_display_entity.dart';

// ════════════════════════════════════════════════════════
// SELLER STORE STATE
// ════════════════════════════════════════════════════════

abstract class SellerStoreState extends Equatable {
  const SellerStoreState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no operation has started yet.
class SellerStoreInitial extends SellerStoreState {
  final bool isGuest;
  final bool isPending;

  const SellerStoreInitial({
    this.isGuest = false,
    this.isPending = false,
  });

  @override
  List<Object?> get props => [isGuest, isPending];
}

/// Loading store data.
class SellerStoreLoading extends SellerStoreState {
  const SellerStoreLoading();
}

/// Store data successfully loaded.
class SellerStoreLoaded extends SellerStoreState {
  final bool isGuest;
  final bool isPending;

  const SellerStoreLoaded({
    this.isGuest = false,
    this.isPending = false,
  });

  @override
  List<Object?> get props => [isGuest, isPending];
}

/// Guest seller view.
class SellerStoreGuest extends SellerStoreState {
  const SellerStoreGuest();
}

/// Pending approval view.
class SellerStorePending extends SellerStoreState {
  const SellerStorePending();
}

/// Store display data loaded successfully (replaces the placeholder SellerStoreLoaded).
class SellerStoreDataLoaded extends SellerStoreState {
  final StoreDisplayEntity store;
  final int activeTabIndex;

  const SellerStoreDataLoaded(this.store, {this.activeTabIndex = 0});

  @override
  List<Object?> get props => [store, activeTabIndex];
}

/// An operation failed.
class SellerStoreError extends SellerStoreState {
  final String message;

  const SellerStoreError(this.message);

  @override
  List<Object?> get props => [message];
}
