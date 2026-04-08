import 'package:equatable/equatable.dart';
import '../../domain/entities/saved_address.dart';

/// Address State
/// Manages the state of address operations
abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AddressInitial extends AddressState {
  const AddressInitial();
}

/// Loading state
class AddressLoading extends AddressState {
  const AddressLoading();
}

/// Addresses loaded successfully
class AddressLoaded extends AddressState {
  final List<SavedAddress> addresses;
  final SavedAddress? defaultAddress;

  const AddressLoaded({
    required this.addresses,
    this.defaultAddress,
  });

  bool get isEmpty => addresses.isEmpty;
  bool get isNotEmpty => addresses.isNotEmpty;

  @override
  List<Object?> get props => [addresses, defaultAddress];
}

/// Address operation success (save, update, delete)
class AddressOperationSuccess extends AddressState {
  final String message;
  final List<SavedAddress> addresses;

  const AddressOperationSuccess({
    required this.message,
    required this.addresses,
  });

  @override
  List<Object?> get props => [message, addresses];
}

/// Error state
class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
