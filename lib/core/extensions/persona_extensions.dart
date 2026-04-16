import '../../features/auth/domain/entities/user_persona.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// PERSONA EXTENSIONS
/// 
/// Helper extensions for UserPersona to reduce code duplication across the app.
/// ─────────────────────────────────────────────────────────────────────────────

extension PersonaExtensions on UserPersona {
  /// Returns true if the user is in guest mode (not authenticated).
  /// 
  /// Guest users should not trigger API calls that require authentication.
  /// Use this guard before calling any authenticated endpoints.
  /// 
  /// Example:
  /// ```dart
  /// if (context.read<PersonaCubit>().state.isGuest) return;
  /// context.read<ProfileCubit>().loadProfile();
  /// ```
  bool get isGuest {
    return this is GuestPersona || 
           (this is SellerPersona && (this as SellerPersona).isGuest);
  }
  
  /// Returns true if the user is a seller with pending approval.
  /// 
  /// Pending sellers have limited access and should see the pending view.
  bool get isPending {
    return this is SellerPersona && (this as SellerPersona).isPending;
  }
}
