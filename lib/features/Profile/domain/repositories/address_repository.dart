import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/saved_address.dart';

/// Address Repository Interface (Domain Layer)
/// Defines operations for address management
abstract class AddressRepository {
  /// Get all saved addresses
  Future<Either<Failure, List<SavedAddress>>> getAllAddresses();

  /// Get the default address
  Future<Either<Failure, SavedAddress?>> getDefaultAddress();

  /// Save a new address
  Future<Either<Failure, void>> saveAddress(SavedAddress address);

  /// Update an existing address
  Future<Either<Failure, void>> updateAddress(SavedAddress address);

  /// Delete an address
  Future<Either<Failure, void>> deleteAddress(String id);

  /// Set an address as default
  Future<Either<Failure, void>> setDefaultAddress(String id);

  /// Clear all addresses
  Future<Either<Failure, void>> clearAllAddresses();
}
