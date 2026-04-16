import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_store_model.dart';
import '../../domain/entities/user_entity.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SELLER ROUTING RESOLVER  — single source of truth for seller landing logic.
///
/// ✅ REFACTORED: Now prioritizes fresh API data over stale cache.
///
/// Both the Splash Screen (cold start) and post-login/OTP listeners call this
/// class, guaranteeing an identical experience regardless of entry point.
///
/// The 4 scenarios evaluated in [_applyScenarios]:
///
///   Scenario 1 (Empty)      stores.isEmpty             → /create-store (ONLY if no seller role)
///   Scenario 2 (All Pending) all stores are 'pending'  → /seller-home (pending mode)
///   Scenario 3 (Solo Active) exactly one active store  → save id → /seller-home
///   Scenario 4 (Multi Active) 2+ active stores         → /store-selection
/// ─────────────────────────────────────────────────────────────────────────────

class SellerRoutingResolver {
  SellerRoutingResolver._(); // prevent instantiation

  // ── Public entry points ───────────────────────────────────────────────────

  /// ✅ NEW: Unified routing method that prioritizes fresh API data.
  ///
  /// Called by:
  /// - Splash Screen (with fresh UserModel from API)
  /// - Post-login / post-OTP / post-Google-Sign-In listeners
  ///
  /// Logic:
  /// - If [liveUser] is provided → Use ONLY liveUser.roles and liveUser.stores
  /// - If [liveUser] is null → Fall back to cached data
  ///
  /// CRITICAL: If liveUser has seller/seller_pending role, NEVER send to createStore,
  /// even if stores list is empty (backend sync may be in progress).
  static Future<void> resolveRoute({
    required BuildContext context,
    required AuthLocalDataSource authLocalDs,
    UserModel? liveUser,
    bool? isOnboardingCompleted,
    bool? isStoreCreated,
  }) async {
    // ── Step 1: Determine onboarding status ──────────────────────────────────
    final bool onboardingComplete;
    if (liveUser != null) {
      onboardingComplete = liveUser.isOnboardingCompleted;
    } else if (isOnboardingCompleted != null) {
      onboardingComplete = isOnboardingCompleted;
    } else {
      onboardingComplete = await authLocalDs.getOnboardingCompleted();
    }

    if (!onboardingComplete) {
      if (context.mounted) context.go(AppRouter.sellerOnboarding);
      return;
    }

    // ── Step 2: Determine user roles ─────────────────────────────────────────
    final List<String> roles;
    if (liveUser != null) {
      roles = liveUser.roles;
      print('✅ [SellerRoutingResolver] Using LIVE roles: $roles');
    } else {
      roles = await authLocalDs.getCachedUserRoles();
      print('⚠️ [SellerRoutingResolver] Using CACHED roles: $roles');
    }

    // ── Step 3: Approved seller routing ─────────────────────────────────────
    // INVARIANT: by the time this resolver is called, the caller (splash screen
    // or post-login listener) has already confirmed the user is an ACTIVE seller
    // (isStoreOwner=true, 'seller' role, no 'seller_pending').
    //
    // seller_pending users are NEVER routed here; they go to /store-under-review.
    // This branch is a defensive double-check only.
    if (roles.contains('seller_pending') && !roles.contains('seller')) {
      // Should not happen — caller must have blocked this path.
      // Fail safe: send to store-under-review, not the seller dashboard.
      print('🔒 [SellerRoutingResolver] seller_pending reached resolver — redirecting safely');
      if (context.mounted) context.go(AppRouter.storeUnderReview);
      return;
    }

    if (roles.contains('seller')) {
      print('✅ [SellerRoutingResolver] Approved seller → /seller-home');
      if (context.mounted) {
        context.go(
          AppRouter.sellerHome,
          extra: {'isGuest': false, 'isPending': false},
        );
      }
      return;
    }

    // ── Step 4: Determine stores list ────────────────────────────────────────
    final List<UserStoreModel> stores;
    if (liveUser != null) {
      stores = liveUser.stores;
      print('✅ [SellerRoutingResolver] Using LIVE stores: ${stores.length}');
    } else {
      stores = await authLocalDs.getCachedStores();
      print('⚠️ [SellerRoutingResolver] Using CACHED stores: ${stores.length}');
    }

    // ── Step 5: Determine store created flag ─────────────────────────────────
    final bool storeCreated;
    if (liveUser != null) {
      storeCreated = liveUser.isStoreCreated;
    } else if (isStoreCreated != null) {
      storeCreated = isStoreCreated;
    } else {
      storeCreated = await authLocalDs.getStoreCreated();
    }

    if (!context.mounted) return;

    // ── Step 6: Apply routing scenarios ──────────────────────────────────────
    await _applyScenarios(
      context:        context,
      isStoreCreated: storeCreated,
      stores:         stores,
      authLocalDs:    authLocalDs,
      userRoles:      roles,
      hasLiveData:    liveUser != null,
    );
  }

  /// ✅ DEPRECATED: Use [resolveRoute] instead.
  /// Kept for backward compatibility with existing callers.
  @Deprecated('Use resolveRoute() instead')
  static Future<void> resolveForUser({
    required BuildContext context,
    required UserEntity user,
    required AuthLocalDataSource authLocalDs,
  }) async {
    if (user is UserModel) {
      await resolveRoute(
        context: context,
        authLocalDs: authLocalDs,
        liveUser: user,
      );
    } else {
      await resolveRoute(
        context: context,
        authLocalDs: authLocalDs,
        isOnboardingCompleted: user.isOnboardingCompleted,
        isStoreCreated: user.isStoreCreated,
      );
    }
  }

  /// ✅ DEPRECATED: Use [resolveRoute] instead.
  /// Kept for backward compatibility with existing callers.
  @Deprecated('Use resolveRoute() instead')
  static Future<void> resolveFromCache({
    required BuildContext context,
    required bool isOnboardingCompleted,
    required bool isStoreCreated,
    required AuthLocalDataSource authLocalDs,
    List<String> userRoles = const [],
  }) async {
    await resolveRoute(
      context: context,
      authLocalDs: authLocalDs,
      isOnboardingCompleted: isOnboardingCompleted,
      isStoreCreated: isStoreCreated,
    );
  }

  // ── Core — the single implementation of all 4 scenarios ──────────────────

  static Future<void> _applyScenarios({
    required BuildContext context,
    required bool isStoreCreated,
    required List<UserStoreModel> stores,
    required AuthLocalDataSource authLocalDs,
    List<String> userRoles = const [],
    bool hasLiveData = false,
  }) async {
    print('🔍 [_applyScenarios] stores: ${stores.length}, roles: $userRoles, hasLiveData: $hasLiveData');

    // ── Approved seller: role-based fast path ────────────────────────────────
    // seller_pending must never appear here — see invariant note in resolveRoute.
    if (userRoles.contains('seller_pending') && !userRoles.contains('seller')) {
      print('🔒 [_applyScenarios] seller_pending reached _applyScenarios — fail safe');
      context.go(AppRouter.storeUnderReview);
      return;
    }

    if (userRoles.contains('seller')) {
      print('✅ [_applyScenarios] Approved seller → /seller-home');
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': false},
      );
      return;
    }

    // ── Fallback: Store-based routing (legacy logic) ─────────────────────────
    // ✅ CRITICAL FIX: Scenario 1 — no stores in the list
    if (stores.isEmpty) {
      // ✅ SAFETY GUARD: If we have live data from API and user has NO seller role,
      // then they truly haven't created a store yet → send to create store
      if (hasLiveData && !userRoles.contains('seller') && !userRoles.contains('seller_pending')) {
        print('✅ [_applyScenarios] No stores + no seller role (live data) → /create-store');
        context.go(AppRouter.createStore);
        return;
      }

      // ✅ SAFETY GUARD: If we're using cached data and stores are empty,
      // check the isStoreCreated flag before sending to create store
      if (!hasLiveData && !isStoreCreated) {
        print('⚠️ [_applyScenarios] No stores + not created (cached data) → /create-store');
        context.go(AppRouter.createStore);
        return;
      }

      // ✅ DEFAULT: Store created but not in list yet → probably pending sync
      print('✅ [_applyScenarios] No stores but created → /seller-home (pending)');
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': true},
      );
      return;
    }

    // Scenario 2 — every store is still pending review
    if (stores.every((s) => s.isPending)) {
      print('✅ [_applyScenarios] All stores pending → /seller-home (pending)');
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': true},
      );
      return;
    }

    final activeStores = stores.where((s) => s.isActive).toList();

    if (activeStores.length == 1) {
      // Scenario 3 — exactly one active store: auto-select and go to seller home
      print('✅ [_applyScenarios] One active store → /seller-home (approved)');
      await authLocalDs.saveSelectedStoreId(activeStores.first.id);
      if (context.mounted) {
        context.go(
          AppRouter.sellerHome,
          extra: {'isGuest': false, 'isPending': false},
        );
      }
    } else if (activeStores.length > 1) {
      // Scenario 4 — multiple active stores: let the seller pick
      print('✅ [_applyScenarios] Multiple active stores → /store-selection');
      context.go(AppRouter.storeSelection, extra: activeStores);
    } else {
      // No active stores but has stores → all must be pending/rejected
      print('✅ [_applyScenarios] No active stores → /seller-home (pending)');
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': true},
      );
    }
  }
}
