import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../models/saved_address_model.dart';

/// Local Data Source for Saved Addresses
/// Handles Hive storage operations for user addresses
abstract class AddressLocalDataSource {
  /// Get all saved addresses
  Future<Either<Failure, List<SavedAddressModel>>> getAllAddresses();

  /// Get default address
  Future<Either<Failure, SavedAddressModel?>> getDefaultAddress();

  /// Save a new address
  Future<Either<Failure, void>> saveAddress(SavedAddressModel address);

  /// Update an existing address
  Future<Either<Failure, void>> updateAddress(SavedAddressModel address);

  /// Delete an address
  Future<Either<Failure, void>> deleteAddress(String id);

  /// Set an address as default
  Future<Either<Failure, void>> setDefaultAddress(String id);

  /// Clear all addresses
  Future<Either<Failure, void>> clearAllAddresses();
}

class AddressLocalDataSourceImpl implements AddressLocalDataSource {
  static const String _boxName = 'saved_addresses';
  
  Box<SavedAddressModel>? _box;

  Future<Box<SavedAddressModel>> get _addressBox async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<SavedAddressModel>(_boxName);
    return _box!;
  }

  @override
  Future<Either<Failure, List<SavedAddressModel>>> getAllAddresses() async {
    try {
      final box = await _addressBox;
      final addresses = box.values.toList();
      
      // Sort by: default first, then by creation date (newest first)
      addresses.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
      
      return Right(addresses);
    } catch (e) {
      return Left(CacheFailure('Failed to load addresses: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SavedAddressModel?>> getDefaultAddress() async {
    try {
      final box = await _addressBox;
      final addresses = box.values.toList();
      
      final defaultAddress = addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => addresses.isNotEmpty ? addresses.first : throw Exception('No addresses found'),
      );
      
      return Right(defaultAddress);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> saveAddress(SavedAddressModel address) async {
    try {
      final box = await _addressBox;
      
      // If this is the first address, make it default
      if (box.isEmpty) {
        final defaultAddress = address.copyWith(isDefault: true);
        await box.put(defaultAddress.id, defaultAddress);
      } else {
        await box.put(address.id, address);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save address: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAddress(SavedAddressModel address) async {
    try {
      final box = await _addressBox;
      
      if (!box.containsKey(address.id)) {
        return Left(CacheFailure('Address not found'));
      }
      
      await box.put(address.id, address);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update address: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String id) async {
    try {
      final box = await _addressBox;
      
      if (!box.containsKey(id)) {
        return Left(CacheFailure('Address not found'));
      }
      
      final addressToDelete = box.get(id);
      await box.delete(id);
      
      // If deleted address was default, set another as default
      if (addressToDelete?.isDefault == true && box.isNotEmpty) {
        final firstAddress = box.values.first;
        final newDefault = firstAddress.copyWith(isDefault: true);
        await box.put(newDefault.id, newDefault);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete address: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String id) async {
    try {
      final box = await _addressBox;
      
      if (!box.containsKey(id)) {
        return Left(CacheFailure('Address not found'));
      }
      
      // Remove default from all addresses
      for (var key in box.keys) {
        final address = box.get(key);
        if (address != null && address.isDefault) {
          await box.put(key, address.copyWith(isDefault: false));
        }
      }
      
      // Set new default
      final newDefault = box.get(id);
      if (newDefault != null) {
        await box.put(id, newDefault.copyWith(isDefault: true));
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to set default address: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllAddresses() async {
    try {
      final box = await _addressBox;
      await box.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear addresses: ${e.toString()}'));
    }
  }
}
