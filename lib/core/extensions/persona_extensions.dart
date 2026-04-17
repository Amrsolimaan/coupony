import 'package:flutter/material.dart';
import '../../features/auth/domain/entities/user_persona.dart';
import '../theme/app_colors.dart';

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
  
  /// Returns the primary color based on the user's role.
  /// 
  /// - SELLER → primaryOfSeller (blue #215194)
  /// - CUSTOMER → primary (orange)
  /// - GUEST → primary (orange)
  /// - LOADING → primary (orange)
  /// 
  /// Example:
  /// ```dart
  /// final color = context.read<PersonaCubit>().state.primaryColor;
  /// ```
  Color get primaryColor {
    return switch (this) {
      SellerPersona() => AppColors.primaryOfSeller,
      CustomerPersona() => AppColors.primary,
      GuestPersona() => AppColors.primary,
      LoadingPersona() => AppColors.primary,
    };
  }
}
