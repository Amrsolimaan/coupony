import 'package:equatable/equatable.dart';

/// Auth Role State
/// Manages the global role selection across all auth screens
class AuthRoleState extends Equatable {
  /// Current selected role: 'customer' or 'seller'
  final String role;

  /// Whether the role is being loaded from storage
  final bool isLoading;

  const AuthRoleState({
    required this.role,
    this.isLoading = false,
  });

  /// Initial state with customer as default role
  /// Role is determined after loading from storage
  factory AuthRoleState.initial() {
    return const AuthRoleState(
      role: 'customer',  // Default to customer role
      isLoading: true,
    );
  }

  /// Check if current role is seller (backend expects 'seller' not 'merchant')
  bool get isSeller => role == 'seller';

  /// Check if current role is customer
  bool get isCustomer => role == 'customer';

  /// Copy with method for state updates
  AuthRoleState copyWith({
    String? role,
    bool? isLoading,
  }) {
    return AuthRoleState(
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [role, isLoading];
}
