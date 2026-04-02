import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/constants/storage_keys.dart';
import 'auth_role_state.dart';

/// Auth Role Cubit
/// Global state management for user role selection across all auth screens
/// Persists role to secure storage for consistency across app sessions
class AuthRoleCubit extends Cubit<AuthRoleState> {
  final SecureStorageService _secureStorage;

  AuthRoleCubit(this._secureStorage) : super(AuthRoleState.initial());

  /// Load persisted role from secure storage
  /// Called on app initialization (splash screen)
  Future<void> loadPersistedRole() async {
    try {
      emit(state.copyWith(isLoading: true));
      
      final savedRole = await _secureStorage.read(StorageKeys.userRole);
      
      // If no saved role, default to customer
      final role = (savedRole == 'merchant') ? 'merchant' : 'customer';
      
      emit(state.copyWith(
        role: role,
        isLoading: false,
      ));
    } catch (e) {
      // On error, default to customer
      emit(state.copyWith(
        role: 'customer',
        isLoading: false,
      ));
    }
  }

  /// Set role and persist to storage
  /// Called when user toggles between customer/merchant
  Future<void> setRole(String role) async {
    try {
      // Validate role
      final validRole = (role == 'merchant') ? 'merchant' : 'customer';
      
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
