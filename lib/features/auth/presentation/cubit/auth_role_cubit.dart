import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../auth/data/datasources/auth_local_data_source.dart';
import 'auth_role_state.dart';

/// Auth Role Cubit
/// Global state management for user role selection across all auth screens
/// Persists role to secure storage for consistency across app sessions
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
///    - Stored in: SecureStorage (userRole)
///    - Example: 'seller' or 'customer'
///    - Set by: User via role_toggle.dart OR backend's primary role
///    - Purpose: Determine what UI/flow user IS CURRENTLY using
/// 
/// Flow:
/// - User logs in → Backend sends roles: ['seller', 'customer']
/// - getPrimaryRole() checks: Does user have saved preference?
///   - YES → Validate preference against backend roles → Use it
///   - NO  → Use backend's primary role (seller > customer)
/// - User toggles role → setRole() saves preference → getPrimaryRole() respects it
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AuthRoleCubit extends Cubit<AuthRoleState> {
  final SecureStorageService _secureStorage;

  AuthRoleCubit(this._secureStorage) : super(AuthRoleState.initial());

  /// Load persisted role from secure storage
  /// Called on app initialization (splash screen)
  /// ✅ Now reads from roles array (primary source) with fallback to single role
  Future<void> loadPersistedRole() async {
    try {
      emit(state.copyWith(isLoading: true));
      
      // ✅ Use helper method to get primary role from roles array
      final authLocalDs = di.sl<AuthLocalDataSource>();
      final role = await authLocalDs.getPrimaryRole();
      
      print('✅ Loaded primary role: $role');
      
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

  /// Set role and persist to storage
  /// Called when user toggles between customer/seller
  Future<void> setRole(String role) async {
    try {
      // Validate role - backend expects 'seller' not 'merchant'
      final validRole = (role == 'seller') ? 'seller' : 'customer';
      
      // Update state immediately for instant UI feedback
      emit(state.copyWith(role: validRole));
      
      // Persist to storage
      await _secureStorage.write(StorageKeys.userRole, validRole);
    } catch (e) {
      // If storage fails, state is already updated for UI
      // Log error if needed
    }
  }

  /// Reset role to customer (useful for logout)
  Future<void> resetRole() async {
    await setRole('customer');
  }
}
