import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/saved_address.dart';

/// Address Repository Interface (Domain Layer)
/// Defines operations for address management (API + Local cache)
abstract class AddressRepository {
  /// Get all saved addresses (API-first, Hive fallback)
  Future<Either<Failure, List<SavedAddress>>> getAllAddresses();

  /// Get the default address
  Future<Either<Failure, SavedAddress?>> getDefaultAddress();

  /// Save a new address (POST to API → cache in Hive)
  /// Returns the server-created address with assigned ID
  Future<Either<Failure, SavedAddress>> saveAddress(SavedAddress address);

  /// Update an existing address (PATCH to API → update Hive)
  /// Returns the server-updated address
  Future<Either<Failure, SavedAddress>> updateAddress(SavedAddress address);

  /// Delete an address (DELETE on API → remove from Hive)
  Future<Either<Failure, void>> deleteAddress(String id);

  /// Set an address as default (local only)
  Future<Either<Failure, void>> setDefaultAddress(String id);

  /// Clear all addresses (local cache only)
  Future<Either<Failure, void>> clearAllAddresses();

  /// Search addresses by query string — API-only, results are ephemeral
  /// (never written to local cache, full list stays intact)
  Future<Either<Failure, List<SavedAddress>>> searchAddresses(String query);
}
