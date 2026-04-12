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
/// Both the Splash Screen (cold start) and post-login/OTP listeners call this
/// class, guaranteeing an identical experience regardless of entry point.
///
/// The 4 scenarios evaluated in [_applyScenarios]:
///
///   Scenario 1 (Empty)      stores.isEmpty             → /create-store
///                           ↳ but if legacy flag set   → /store-under-review
///   Scenario 2 (All Pending) all stores are 'pending'  → /store-under-review
///   Scenario 3 (Solo Active) exactly one active store  → save id → /home
///   Scenario 4 (Multi Active) 2+ active stores         → /store-selection
/// ─────────────────────────────────────────────────────────────────────────────

class SellerRoutingResolver {
  SellerRoutingResolver._(); // prevent instantiation

  // ── Public entry points ───────────────────────────────────────────────────

  /// Called by post-login / post-OTP / post-Google-Sign-In listeners.
  ///
  /// Reads `user.stores` directly when [user] is a full [UserModel] (fresh
  /// from the API response). Falls back to [authLocalDs.getCachedStores] for
  /// plain [UserEntity] objects that do not carry the stores list.
  static Future<void> resolveForUser({
    required BuildContext context,
    required UserEntity user,
    required AuthLocalDataSource authLocalDs,
  }) async {
    if (!user.isOnboardingCompleted) {
      if (context.mounted) context.go(AppRouter.sellerOnboarding);
      return;
    }

    // ── Check roles before proceeding ────────────────────────────────────────
    // If user is UserModel, check the roles array to determine seller status
    if (user is UserModel) {
      // Check if seller_pending → redirect to seller home with pending state
      if (user.roles.contains('seller_pending')) {
        if (context.mounted) {
          context.go(
            AppRouter.sellerHome,
            extra: {'isGuest': false, 'isPending': true},
          );
        }
        return;
      }
      
      // Check if seller (approved) → redirect to seller home (normal mode)
      if (user.roles.contains('seller') && !user.roles.contains('seller_pending')) {
        if (context.mounted) {
          context.go(
            AppRouter.sellerHome,
            extra: {'isGuest': false, 'isPending': false},
          );
        }
        return;
      }
    }

    // Prefer fresh stores from the API model; fall back to cache.
    final List<UserStoreModel> stores;
    if (user is UserModel && user.stores.isNotEmpty) {
      stores = user.stores;
    } else {
      stores = await authLocalDs.getCachedStores();
    }

    if (!context.mounted) return;
    await _applyScenarios(
      context:       context,
      isStoreCreated: user.isStoreCreated,
      stores:         stores,
      authLocalDs:    authLocalDs,
      userRoles:     user is UserModel ? user.roles : [],
    );
  }

  /// Called by the Splash Screen (cold start, no fresh [UserModel] available).
  ///
  /// Fetches the stores list from [AuthLocalDataSource] internally so the
  /// caller only needs to pass the flags it has already loaded.
  static Future<void> resolveFromCache({
    required BuildContext context,
    required bool isOnboardingCompleted,
    required bool isStoreCreated,
    required AuthLocalDataSource authLocalDs,
    List<String> userRoles = const [],
  }) async {
    if (!isOnboardingCompleted) {
      if (context.mounted) context.go(AppRouter.sellerOnboarding);
      return;
    }

    // ── Check roles from cache if available ──────────────────────────────────
    if (userRoles.contains('seller_pending')) {
      if (context.mounted) {
        context.go(
          AppRouter.sellerHome,
          extra: {'isGuest': false, 'isPending': true},
        );
      }
      return;
    }
    
    if (userRoles.contains('seller') && !userRoles.contains('seller_pending')) {
      if (context.mounted) {
        context.go(
          AppRouter.sellerHome,
          extra: {'isGuest': false, 'isPending': false},
        );
      }
      return;
    }

    final stores = await authLocalDs.getCachedStores();
    if (!context.mounted) return;

    await _applyScenarios(
      context:        context,
      isStoreCreated: isStoreCreated,
      stores:         stores,
      authLocalDs:    authLocalDs,
      userRoles:      userRoles,
    );
  }

  // ── Core — the single implementation of all 4 scenarios ──────────────────

  static Future<void> _applyScenarios({
    required BuildContext context,
    required bool isStoreCreated,
    required List<UserStoreModel> stores,
    required AuthLocalDataSource authLocalDs,
    List<String> userRoles = const [],
  }) async {
    // ── Priority Check: Roles-based routing ──────────────────────────────────
    // This takes precedence over store-based routing
    if (userRoles.contains('seller_pending')) {
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': true},
      );
      return;
    }
    
    if (userRoles.contains('seller') && !userRoles.contains('seller_pending')) {
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': false},
      );
      return;
    }

    // ── Fallback: Store-based routing (legacy logic) ─────────────────────────
    // Scenario 1 — no stores in the list
    if (stores.isEmpty) {
      // If no stores and not created yet, go to create store
      // Otherwise, they might be waiting for approval
      if (!isStoreCreated) {
        context.go(AppRouter.createStore);
      } else {
        // Store created but not in list yet → probably pending
        context.go(
          AppRouter.sellerHome,
          extra: {'isGuest': false, 'isPending': true},
        );
      }
      return;
    }

    // Scenario 2 — every store is still pending review
    if (stores.every((s) => s.isPending)) {
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': true},
      );
      return;
    }

    final activeStores = stores.where((s) => s.isActive).toList();

    if (activeStores.length == 1) {
      // Scenario 3 — exactly one active store: auto-select and go to seller home
      await authLocalDs.saveSelectedStoreId(activeStores.first.id);
      if (context.mounted) {
        context.go(
          AppRouter.sellerHome,
          extra: {'isGuest': false, 'isPending': false},
        );
      }
    } else if (activeStores.length > 1) {
      // Scenario 4 — multiple active stores: let the seller pick
      // After selection in StoreSelectionPage, they will be redirected to seller home
      context.go(AppRouter.storeSelection, extra: activeStores);
    } else {
      // No active stores but has stores → all must be pending/rejected
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': true},
      );
    }
  }
}
