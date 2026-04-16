import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../auth/data/datasources/auth_local_data_source.dart';
import 'auth_role_state.dart';

/// Auth Role Cubit
/// Global state management for user role selection across all auth screens
/// Persists role preference to SharedPreferences (survives logout)
/// 
/// ✅ IMPORTANT: Two-Layer Role System
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// 1. Backend Roles (Source of Truth for Permissions)
///    - Stored in: SharedPreferences (userRolesKey)
///    - Example: ['seller', 'customer'] or ['seller_pending', 'customer']
///    - Set by: Backend API response during login
///    - Purpose: Determine what features user CAN access
/// 
/// 2. Active Role (User's Current Choice)
///    - Stored in: SharedPreferences (preferredRole) - PERSISTS ACROSS LOGOUT
///    - Example: 'seller' or 'customer'
///    - Set by: User via role_toggle.dart
///    - Purpose: Remember user's preference even after logout
/// 
/// Flow:
/// - User toggles role → setRole() saves to preferredRole
/// - User logs out → preferredRole is NOT deleted (user preference preserved)
/// - User opens login screen → loadPersistedRole() reads preferredRole
/// - Result: Seller sees seller toggle, Customer sees customer toggle
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AuthRoleCubit extends Cubit<AuthRoleState> {
  final SharedPreferences _prefs;

  AuthRoleCubit(this._prefs) : super(AuthRoleState.initial());

  /// Load persisted role preference from SharedPreferences
  /// Called on app initialization and when opening login screen
  /// ✅ Reads user's last selected role (survives logout)
  Future<void> loadPersistedRole() async {
    try {
      emit(state.copyWith(isLoading: true));
      
      // Read user's preferred role from SharedPreferences
      final preferredRole = _prefs.getString(StorageKeys.preferredRole);
      
      // If user has a saved preference, use it
      if (preferredRole != null && (preferredRole == 'customer' || preferredRole == 'seller')) {
        print('✅ Loaded preferred role: $preferredRole');
        emit(state.copyWith(
          role: preferredRole,
          isLoading: false,
        ));
        return;
      }
      
      // No preference saved, check if user is logged in
      final authLocalDs = di.sl<AuthLocalDataSource>();
      final role = await authLocalDs.getPrimaryRole();
      
      print('✅ Loaded primary role from session: $role');
      
      emit(state.copyWith(
        role: role,
        isLoading: false,
      ));
    } catch (e) {
      // On error, default to customer
      print('⚠️ loadPersistedRole failed, defaulting to customer: $e');
      emit(state.copyWith(
        role: 'customer',
        isLoading: false,
      ));
    }
  }

  /// Set role and persist preference to SharedPreferences
  /// Called when user toggles between customer/seller
  /// ✅ This preference survives logout
  Future<void> setRole(String role) async {
    try {
      // Validate role - backend expects 'seller' not 'merchant'
      final validRole = (role == 'seller') ? 'seller' : 'customer';
      
      // Update state immediately for instant UI feedback
      emit(state.copyWith(role: validRole));
      
      // Persist preference to SharedPreferences (survives logout)
      await _prefs.setString(StorageKeys.preferredRole, validRole);
      
      print('✅ Saved preferred role: $validRole');
    } catch (e) {
      // If storage fails, state is already updated for UI
      print('⚠️ Failed to save preferred role: $e');
    }
  }

  /// Reset role to customer (useful for testing or first-time users)
  Future<void> resetRole() async {
    await setRole('customer');
  }
}
