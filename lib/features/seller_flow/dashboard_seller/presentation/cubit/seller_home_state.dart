import 'package:equatable/equatable.dart';

// ════════════════════════════════════════════════════════
// SELLER HOME STATE
// ════════════════════════════════════════════════════════

abstract class SellerHomeState extends Equatable {
  const SellerHomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no operation has started yet.
class SellerHomeInitial extends SellerHomeState {
  final bool isGuest;
  final bool isPending;

  const SellerHomeInitial({
    this.isGuest = false,
    this.isPending = false,
  });

  @override
  List<Object?> get props => [isGuest, isPending];
}

/// Loading home data.
class SellerHomeLoading extends SellerHomeState {
  const SellerHomeLoading();
}

/// Home data successfully loaded.
class SellerHomeLoaded extends SellerHomeState {
  final bool isGuest;
  final bool isPending;

  const SellerHomeLoaded({
    this.isGuest = false,
    this.isPending = false,
  });

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
