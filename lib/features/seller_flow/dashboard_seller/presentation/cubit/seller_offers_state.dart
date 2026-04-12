// ─────────────────────────────────────────────────────────────────────────────
// SELLER OFFERS STATE
// ─────────────────────────────────────────────────────────────────────────────

abstract class SellerOffersState {
  const SellerOffersState();
}

// ── Initial State ──────────────────────────────────────────────────────────
class SellerOffersInitial extends SellerOffersState {
  final bool isGuest;
  final bool isPending;

  const SellerOffersInitial({
    required this.isGuest,
    required this.isPending,
  });
}

// ── Loading State ──────────────────────────────────────────────────────────
class SellerOffersLoading extends SellerOffersState {
  const SellerOffersLoading();
}

// ── Loaded State ───────────────────────────────────────────────────────────
class SellerOffersLoaded extends SellerOffersState {
  final bool isGuest;
  final bool isPending;

  const SellerOffersLoaded({
    required this.isGuest,
    required this.isPending,
  });
}

// ── Guest State ────────────────────────────────────────────────────────────
class SellerOffersGuest extends SellerOffersState {
  const SellerOffersGuest();
}

// ── Pending State ──────────────────────────────────────────────────────────
class SellerOffersPending extends SellerOffersState {
  const SellerOffersPending();
}

// ── Error State ────────────────────────────────────────────────────────────
class SellerOffersError extends SellerOffersState {
  final String message;

  const SellerOffersError({required this.message});
}
