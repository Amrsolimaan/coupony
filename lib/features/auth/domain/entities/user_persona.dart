/// ─────────────────────────────────────────────────────────────────────────────
/// USER PERSONA — single sealed identity type
///
/// This is the ONLY source of truth for who the user is in the current session.
/// Both the Theme (color) and the Route (destination) are driven exclusively
/// by whichever subtype PersonaCubit holds.
///
/// Adding a new role (Admin, Moderator) = add one new `final class` here +
/// one condition in ResolvePersonaUseCase. Zero other files need to change.
/// ─────────────────────────────────────────────────────────────────────────────

sealed class UserPersona {
  const UserPersona();
}

/// Transient state while cache/API resolution is in progress.
/// UI shows a neutral (white) background during this phase.
final class LoadingPersona extends UserPersona {
  const LoadingPersona();
}

/// Unauthenticated visitor (chose "Browse as Guest").
final class GuestPersona extends UserPersona {
  const GuestPersona();
}

/// Authenticated customer (pure or dual-role with seller_pending).
final class CustomerPersona extends UserPersona {
  final bool onboardingCompleted;
  const CustomerPersona({required this.onboardingCompleted});
}

/// Approved, active seller (isStoreOwner = true, role = 'seller').
/// [isPending] is true when all stores are still under review — the seller
/// dashboard shows the pending view but routing still lands on /seller-home.
/// [isGuest] is true when user skipped login and is browsing as guest.
final class SellerPersona extends UserPersona {
  final bool isPending;
  final bool isGuest;
  const SellerPersona({
    required this.isPending,
    this.isGuest = false,
  });
}
