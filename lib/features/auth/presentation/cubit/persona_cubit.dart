import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/user_persona.dart';
import '../../domain/use_cases/resolve_persona_use_case.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// PERSONA CUBIT — single authority for Theme + Route
///
/// Replaces AuthRoleCubit. Every widget, route guard, and API interceptor
/// reads ONLY from this cubit. Theme and route are structurally impossible
/// to diverge because they observe the same [UserPersona] emission.
///
/// Lifecycle:
///   1. Registered as lazySingleton — one instance for the entire app session.
///   2. Splash calls [preloadFromCache] BEFORE the animation starts.
///   3. Splash calls [resolveFromApi] AFTER the animation + API response.
///   4. Toggle button calls [switchPersona] for in-session role switching.
/// ─────────────────────────────────────────────────────────────────────────────

class PersonaCubit extends Cubit<UserPersona> {
  final ResolvePersonaUseCase _resolve;
  final AuthLocalDataSource _authLocalDs;
  final SecureStorageService _secureStorage;
  final SharedPreferences _prefs;

  PersonaCubit({
    required ResolvePersonaUseCase resolvePersonaUseCase,
    required AuthLocalDataSource authLocalDs,
    required SecureStorageService secureStorage,
    required SharedPreferences prefs,
  })  : _resolve = resolvePersonaUseCase,
        _authLocalDs = authLocalDs,
        _secureStorage = secureStorage,
        _prefs = prefs,
        super(const LoadingPersona());

  // ── Phase 1: Cache read BEFORE animation ────────────────────────────────────
  // Fast — reads two storage keys (~2 ms). Gives the splash the correct color
  // (seller-blue / customer-orange) before the first animation frame.

  Future<void> preloadFromCache() async {
    try {
      // ✅ Read user's preferred role first (survives logout)
      final preferredRole = _prefs.getString(StorageKeys.preferredRole);
      
      // Use preferred role if available, otherwise fall back to session role
      final role = preferredRole ?? await _authLocalDs.getPrimaryRole();
      final roles  = await _authLocalDs.getCachedUserRoles();
      final isGuest = await _authLocalDs.getGuestStatus();
      final hasToken = await _secureStorage.read(StorageKeys.authToken);

      // ✅ Safety check: If no token and isGuest = true, treat as unauthenticated
      // BUT respect the user's preferred role (seller/customer) for correct splash color
      if (isGuest && (hasToken == null || hasToken.isEmpty)) {
        if (preferredRole == 'seller') {
          emit(const SellerPersona(isGuest: true, isPending: false));
        } else {
          emit(const GuestPersona());
        }
        return;
      }

      // seller_pending → pending page (customer-orange color)
      if (roles.contains('seller_pending') && !roles.contains('seller')) {
        emit(const SellerPersona(isPending: true, isGuest: false));
        return;
      }

      // ✅ Guest mode - check role to determine which guest view
      if (isGuest) {
        if (role == 'seller') {
          emit(const SellerPersona(isGuest: true, isPending: false));
          return;
        } else {
          emit(const GuestPersona());
          return;
        }
      }

      if (role == 'seller') {
        final stores = await _authLocalDs.getCachedStores();
        emit(SellerPersona(
          isPending: stores.isNotEmpty && stores.every((s) => s.isPending),
          isGuest: false,
        ));
        return;
      }

      final onboarding = await _authLocalDs.getOnboardingCompleted();
      emit(CustomerPersona(onboardingCompleted: onboarding));
    } catch (_) {
      // Storage failure — safe default
      emit(const CustomerPersona(onboardingCompleted: false));
    }
  }

  // ── Phase 2: API validation AFTER animation ─────────────────────────────────
  // Called once the profile API response arrives. Resolves the definitive
  // persona, persists the corrected role, and emits — driving navigation.

  Future<void> resolveFromApi(UserModel freshProfile) async {
    try {
      final cachedRoles  = await _authLocalDs.getCachedUserRoles();
      final cachedStores = await _authLocalDs.getCachedStores();
      
      // ✅ Read user's preferred role to respect their choice
      final preferredRole = _prefs.getString(StorageKeys.preferredRole);

      final persona = _resolve(
        freshProfile: freshProfile,
        cachedRoles: cachedRoles,
        cachedStores: cachedStores,
        preferredRole: preferredRole, // ✅ Pass user preference
      );

      // Build a fully merged UserModel (fixes the isStoreOwner drop bug)
      // and write it back to the cache so subsequent reads are correct.
      final mergedUser = _buildMergedUser(freshProfile, cachedRoles);
      await _authLocalDs.cacheUser(mergedUser);

      // Persist the resolved role immediately so the X-User-Role header
      // on the NEXT API call reflects the corrected persona.
      await _persistRole(persona);

      emit(persona);
    } catch (_) {
      // API resolution failed — keep the cached persona from Phase 1.
      // No emit → cubit state unchanged → existing navigation stays correct.
    }
  }

  // ── In-session role toggle ──────────────────────────────────────────────────
  // Returns true when the switch succeeded, false when the user lacks
  // the target role (caller should show a snackbar or ignore).

  Future<bool> switchPersona() async {
    switch (state) {
      case SellerPersona():
        final onboarding = await _authLocalDs.getOnboardingCompleted();
        final next = CustomerPersona(onboardingCompleted: onboarding);
        await _persistRole(next);
        emit(next);
        return true;

      case CustomerPersona():
        final roles = await _authLocalDs.getCachedUserRoles();
        // Only allow the switch if the backend has approved this seller.
        // seller_pending accounts cannot switch to the seller view.
        if (roles.contains('seller') && !roles.contains('seller_pending')) {
          final stores = await _authLocalDs.getCachedStores();
          final next = SellerPersona(
            isPending: stores.isNotEmpty && stores.every((s) => s.isPending),
            isGuest: false,
          );
          await _persistRole(next);
          emit(next);
          return true;
        }
        return false;

      default:
        // Guest and Pending cannot toggle
        return false;
    }
  }

  /// Called on logout — resets to neutral so the next user starts clean.
  Future<void> resetToGuest() async {
    emit(const GuestPersona());
  }

  /// ✅ Skip login and continue as guest
  /// Called when user taps "Skip" button on login/welcome screen.
  /// The role parameter determines which guest view to show.
  Future<void> skipAsGuest(String role) async {
    if (role == 'seller') {
      // Navigate to seller home in guest mode
      emit(const SellerPersona(isGuest: true, isPending: false));
    } else {
      // Navigate to customer home in guest mode
      emit(const GuestPersona());
    }
    // ✅ Persist guest status AND preferred role (so login screen remembers)
    await _authLocalDs.cacheGuestStatus(true);
    await _persistRole(state);
  }

  /// ✅ Temporarily update persona for UI animations (login screen toggle)
  /// This is a lightweight state update that will be corrected by the next
  /// API call (resolveFromApi). Used only for immediate visual feedback.
  void updatePersonaForAnimation(String role) {
    if (role == 'seller') {
      emit(const SellerPersona(isPending: false, isGuest: false));
    } else {
      emit(const CustomerPersona(onboardingCompleted: true));
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  /// Writes the effective role string to both SecureStorage and SharedPreferences
  /// so it is available for both API headers and user preference persistence.
  Future<void> _persistRole(UserPersona persona) async {
    final role = persona is SellerPersona ? 'seller' : 'customer';
    // Save to SecureStorage for API headers
    await _secureStorage.write(StorageKeys.userRole, role);
    // Save to SharedPreferences for user preference (survives logout)
    await _prefs.setString(StorageKeys.preferredRole, role);
  }

  /// Builds a UserModel with roles and isStoreOwner correctly merged.
  /// This permanently fixes the bug where copyWith(roles: ...) left
  /// isStoreOwner as false (its stale profile-API value).
  UserModel _buildMergedUser(UserModel profile, List<String> cachedRoles) {
    final effectiveRoles = profile.roles.isNotEmpty
        ? profile.roles
        : cachedRoles;

    final effectiveIsStoreOwner = profile.roles.isNotEmpty
        ? profile.isStoreOwner
        : (effectiveRoles.contains('seller') &&
            !effectiveRoles.contains('seller_pending'));

    return profile.copyWith(
      roles: effectiveRoles,
      isStoreOwner: effectiveIsStoreOwner,
    );
  }
}
