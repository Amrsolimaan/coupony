import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/saved_address.dart';
import '../../domain/repositories/address_repository.dart';
import '../data_sources/address_local_data_source.dart';
import '../datasources/address_remote_data_source.dart';
import '../models/saved_address_model.dart';

/// Hybrid Address Repository
/// Strategy: API-first for all mutations, Hive as synchronized cache.
/// On network failure during reads, falls back to local Hive data.
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;
  final AddressLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AddressRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // ════════════════════════════════════════════════════════
  // GET ALL ADDRESSES
  // API fetch → clear Hive → re-populate → return API data
  // On network failure → fallback to Hive cache
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, List<SavedAddress>>> getAllAddresses() async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteAddresses = await remoteDataSource.fetchAddresses();

          // Sync: clear old cache and re-populate with fresh API data
          await _syncLocalCache(remoteAddresses);

          // Sort addresses: default first, then by creation date (newest first)
          final sortedAddresses = List<SavedAddress>.from(remoteAddresses);
          sortedAddresses.sort((a, b) {
            if (a.isDefault && !b.isDefault) return -1;
            if (!a.isDefault && b.isDefault) return 1;
            return b.createdAt.compareTo(a.createdAt);
          });

          return Right(sortedAddresses);
        } on ServerException catch (e) {
          // API failed — try local fallback
          return _getFromLocalFallback(e.message);
        } on UnauthorizedException catch (e) {
          return Left(UnauthorizedFailure(e.message));
        } catch (e) {
          return _getFromLocalFallback(e.toString());
        }
      } else {
        // Offline — serve from local cache (already sorted)
        return await localDataSource.getAllAddresses();
      }
    } catch (e) {
      return Left(UnexpectedFailure('Failed to load addresses: ${e.toString()}'));
    }
  }

  /// Fallback: attempt to serve from Hive when API fails
  Future<Either<Failure, List<SavedAddress>>> _getFromLocalFallback(String apiError) async {
    final localResult = await localDataSource.getAllAddresses();
    return localResult.fold(
      (_) => Left(ServerFailure(apiError)),
      (addresses) => Right(addresses),
    );
  }

  /// Clear Hive box and re-populate with fresh data from API.
  /// Uses a try-catch for graceful migration if old Hive schema is incompatible.
  Future<void> _syncLocalCache(List<SavedAddressModel> addresses) async {
    try {
      await localDataSource.clearAllAddresses();
      for (final address in addresses) {
        await localDataSource.saveAddress(address);
      }
    } catch (_) {
      // Graceful clear: if Hive data is incompatible, silently clear and retry
      try {
        await localDataSource.clearAllAddresses();
        for (final address in addresses) {
          await localDataSource.saveAddress(address);
        }
      } catch (_) {
        // Cache sync failure is non-fatal — API data is already returned
      }
    }
  }

  // ════════════════════════════════════════════════════════
  // GET DEFAULT ADDRESS
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, SavedAddress?>> getDefaultAddress() async {
    return await localDataSource.getDefaultAddress();
  }

  // ════════════════════════════════════════════════════════
  // SAVE ADDRESS
  // POST to API → on success, cache in Hive with server ID
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, SavedAddress>> saveAddress(SavedAddress address) async {
    try {
      final model = SavedAddressModel.fromEntity(address);
      final createData = model.toCreateJson();

      // API-first: send to server
      final serverAddress = await remoteDataSource.createAddress(createData);

      // On success: cache in Hive with the server-assigned ID
      await localDataSource.saveAddress(serverAddress);

      return Right(serverAddress);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to save address: ${e.toString()}'));
    }
  }

  // ════════════════════════════════════════════════════════
  // UPDATE ADDRESS
  // PATCH to API → on success, update in Hive
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, SavedAddress>> updateAddress(SavedAddress address) async {
    try {
      final model = SavedAddressModel.fromEntity(address);
      final updateData = model.toUpdateJson();

      // API-first: send PATCH via POST + _method spoofing
      final serverAddress = await remoteDataSource.updateAddress(address.id, updateData);

      // On success: update Hive cache
      await localDataSource.updateAddress(serverAddress);

      return Right(serverAddress);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update address: ${e.toString()}'));
    }
  }

  // ════════════════════════════════════════════════════════
  // DELETE ADDRESS
  // DELETE on API → on success, remove from Hive
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, void>> deleteAddress(String id) async {
    try {
      // API-first: delete on server
      await remoteDataSource.deleteAddress(id);

      // On success: remove from Hive
      await localDataSource.deleteAddress(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException {
      // Already deleted on server — remove from local too
      await localDataSource.deleteAddress(id);
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to delete address: ${e.toString()}'));
    }
  }

  // ════════════════════════════════════════════════════════
  // SET DEFAULT ADDRESS
  // Uses PATCH to update is_default_shipping and is_default_billing
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, void>> setDefaultAddress(String id) async {
    try {
      if (!await networkInfo.isConnected) {
        // Offline: update local only
        return await localDataSource.setDefaultAddress(id);
      }

      // First, get all addresses to find the one we want to set as default
      final localResult = await localDataSource.getAllAddresses();
      
      SavedAddress? targetAddress;
      await localResult.fold(
        (_) => null,
        (addresses) {
          targetAddress = addresses.firstWhere(
            (addr) => addr.id == id,
            orElse: () => throw NotFoundException('Address not found'),
          );
        },
      );

      if (targetAddress == null) {
        return Left(ServerFailure('Address not found'));
      }

      // Update the address with is_default flags set to true
      final updatedAddress = targetAddress!.copyWith(
        isDefault: true,
        isDefaultShipping: true,
        isDefaultBilling: true,
      );

      // Send PATCH request to server
      final model = SavedAddressModel.fromEntity(updatedAddress);
      final updateData = model.toUpdateJson();
      
      final serverAddress = await remoteDataSource.updateAddress(id, updateData);

      // On success: sync local cache with server response
      // The server should return the updated address with is_default flags
      // We need to update local cache to match server state
      
      // First, remove default from all addresses
      await localResult.fold(
        (_) => null,
        (addresses) async {
          for (final address in addresses) {
            if (address.isDefault && address.id != id) {
              await localDataSource.updateAddress(
                SavedAddressModel.fromEntity(address.copyWith(
                  isDefault: false,
                  isDefaultShipping: false,
                  isDefaultBilling: false,
                )),
              );
            }
          }
        },
      );
      
      // Then update the selected address with server response
      await localDataSource.updateAddress(
        SavedAddressModel.fromEntity(serverAddress).copyWith(
          isDefault: true,
          isDefaultShipping: true,
          isDefaultBilling: true,
        ),
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to set default address: ${e.toString()}'));
    }
  }

  // ════════════════════════════════════════════════════════
  // CLEAR ALL ADDRESSES (Local cache only)
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, void>> clearAllAddresses() async {
    return await localDataSource.clearAllAddresses();
  }

  // ════════════════════════════════════════════════════════
  // SEARCH ADDRESSES (API-only — results are ephemeral)
  // No Hive interaction: full list cache stays untouched
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, List<SavedAddress>>> searchAddresses(String query) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }
      final results = await remoteDataSource.searchAddresses(query);
      return Right(results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to search addresses: ${e.toString()}'));
    }
  }
}
