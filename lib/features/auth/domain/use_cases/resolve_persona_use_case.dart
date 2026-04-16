import '../entities/user_persona.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_store_model.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// RESOLVE PERSONA USE CASE
///
/// Pure function — no I/O, no Flutter, no storage.
/// Takes the fresh API profile + cached fallback data and returns a typed
/// [UserPersona]. This is the single computation point that replaces:
///   - splash_screen.dart _checkOnboardingStatus() (150 lines)
///   - SellerRoutingResolver (role checks)
///   - The scattered isActiveSeller / isStoreOwner flag logic
///
/// Bug fixes encoded here (permanently):
///   1. isStoreOwner is RE-DERIVED from effectiveRoles when the profile API
///      returns no roles — the flag is no longer silently dropped by copyWith.
///   2. seller_pending is checked BEFORE the approved-seller branch.
///   3. rolesList.first fallback is never reached — personas are exhaustive.
/// ─────────────────────────────────────────────────────────────────────────────

class ResolvePersonaUseCase {
  const ResolvePersonaUseCase();

  UserPersona call({
    required UserModel freshProfile,
    required List<String> cachedRoles,
    required List<UserStoreModel> cachedStores,
    String? preferredRole, // ✅ User's explicit choice (customer/seller)
  }) {
    // ── 1. Merge roles ────────────────────────────────────────────────────────
    // Profile endpoint (GET /auth/me) never returns a roles array.
    // When the fresh response has roles, trust them. Otherwise fall back to the
    // roles cached at login time (written by AuthLocalDataSource.cacheUser).
    final List<String> roles = freshProfile.roles.isNotEmpty
        ? freshProfile.roles
        : cachedRoles;

    // ── 2. Re-derive isStoreOwner from effective roles ────────────────────────
    // When the profile API omits is_store_owner (common) AND roles is empty,
    // the raw model has isStoreOwner = false (derived from empty rolesList).
    // After the role merge above we now have the correct roles array, so we
    // can re-derive the flag accurately instead of carrying the stale false.
    final bool effectiveIsStoreOwner = freshProfile.roles.isNotEmpty
        ? freshProfile.isStoreOwner
        : (roles.contains('seller') && !roles.contains('seller_pending'));

    // ── 3. ✅ RESPECT USER PREFERENCE FIRST ───────────────────────────────────
    // If user explicitly chose 'seller' from toggle, check if they have seller role
    if (preferredRole == 'seller' && roles.contains('seller_pending')) {
      // User chose seller AND has seller_pending → show seller view with pending state
      return SellerPersona(isPending: true, isGuest: false);
    }

    // If user explicitly chose 'customer' and has customer role, honor it
    // even if they also have seller role (dual-role users)
    if (preferredRole == 'customer' && roles.contains('customer')) {
      return CustomerPersona(
        onboardingCompleted: freshProfile.isOnboardingCompleted,
      );
    }

    // ── 4. seller_pending (no preference specified) ───────────────────────────
    // When roles contains seller_pending and no preference, default to pending seller
    if (roles.contains('seller_pending') && !effectiveIsStoreOwner) {
      return SellerPersona(isPending: true, isGuest: false);
    }

    // ── 5. Approved seller ────────────────────────────────────────────────────
    if (effectiveIsStoreOwner && roles.contains('seller')) {
      final List<UserStoreModel> stores = freshProfile.stores.isNotEmpty
          ? freshProfile.stores
          : cachedStores;

      return SellerPersona(
        // isPending = true when every store is still under review.
        // The seller sees the pending view inside /seller-home, not a redirect.
        isPending: stores.isNotEmpty && stores.every((s) => s.isPending),
        isGuest: false,
      );
    }

    // ── 6. Customer (pure or dual-role with only seller_pending) ──────────────
    return CustomerPersona(
      onboardingCompleted: freshProfile.isOnboardingCompleted,
    );
  }
}
