import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/saved_address.dart';
import '../../domain/repositories/address_repository.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository repository;
  final Logger logger;

  // Keeps the full list alive so search can snap back without a network call
  List<SavedAddress> _cachedAddresses = [];
  SavedAddress? _cachedDefault;

  AddressCubit({
    required this.repository,
    required this.logger,
  }) : super(const AddressInitial());

  // ════════════════════════════════════════════════════════
  // LOAD ADDRESSES
  // ════════════════════════════════════════════════════════

  Future<void> loadAddresses() async {
    emit(const AddressLoading());

    final result = await repository.getAllAddresses();

    result.fold(
      (failure) {
        logger.e('Failed to load addresses: ${failure.message}');
        emit(AddressError(failure.message));
      },
      (addresses) async {
        final defaultResult = await repository.getDefaultAddress();
        final defaultAddress = defaultResult.fold(
          (_) => null,
          (address) => address,
        );

        // Cache the full list for instant snap-back when search is cleared
        _cachedAddresses = addresses;
        _cachedDefault   = defaultAddress;

        emit(AddressLoaded(
          addresses: addresses,
          defaultAddress: defaultAddress,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // SAVE ADDRESS (API-first, server assigns ID)
  // ════════════════════════════════════════════════════════

  Future<void> saveAddress({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    bool setAsDefault = false,
    String firstName = '',
    String lastName = '',
    String company = '',
    String addressLine1 = '',
    String addressLine2 = '',
    String city = '',
    String stateProvince = '',
    String postalCode = '',
    String countryCode = 'EG',
    String phoneNumber = '',
    String deliveryInstructions = '',
  }) async {
    try {
      emit(const AddressSaving());

      // Build entity — ID is empty; server will assign it
      final newAddress = SavedAddress(
        id: '',
        label: label,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: setAsDefault,
        createdAt: DateTime.now(),
        firstName: firstName,
        lastName: lastName,
        company: company,
        addressLine1: addressLine1.isNotEmpty ? addressLine1 : address,
        addressLine2: addressLine2,
        city: city,
        stateProvince: stateProvince,
        postalCode: postalCode,
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        deliveryInstructions: deliveryInstructions,
        isDefaultShipping: setAsDefault,
        isDefaultBilling: setAsDefault,
      );

      final result = await repository.saveAddress(newAddress);

      await result.fold(
        (failure) {
          logger.e('Failed to save address: ${failure.message}');
          emit(AddressError(failure.message));
        },
        (savedAddress) async {
          logger.i('✅ Address saved successfully (ID: ${savedAddress.id})');
          // Reload all addresses to get a consistent list
          await loadAddresses();
        },
      );
    } catch (e) {
      logger.e('Error saving address: $e');
      emit(AddressError('Failed to save address'));
    }
  }

  // ════════════════════════════════════════════════════════
  // UPDATE ADDRESS (API-first)
  // ════════════════════════════════════════════════════════

  Future<void> updateAddress(SavedAddress address) async {
    emit(const AddressSaving());

    final result = await repository.updateAddress(address);

    await result.fold(
      (failure) {
        logger.e('Failed to update address: ${failure.message}');
        emit(AddressError(failure.message));
      },
      (updatedAddress) async {
        logger.i('✅ Address updated successfully (ID: ${updatedAddress.id})');
        await loadAddresses();
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // DELETE ADDRESS (API-first)
  // ════════════════════════════════════════════════════════

  Future<void> deleteAddress(String id) async {
    emit(const AddressDeleting());

    final result = await repository.deleteAddress(id);

    await result.fold(
      (failure) {
        logger.e('Failed to delete address: ${failure.message}');
        emit(AddressError(failure.message));
      },
      (_) async {
        logger.i('✅ Address deleted successfully (ID: $id)');
        await loadAddresses();
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // SET DEFAULT ADDRESS
  // Updates both local cache and server
  // ════════════════════════════════════════════════════════

  Future<void> setDefaultAddress(String id) async {
    // Show loading state
    emit(const AddressSaving());

    final result = await repository.setDefaultAddress(id);

    await result.fold(
      (failure) {
        logger.e('Failed to set default address: ${failure.message}');
        emit(AddressError(failure.message));
      },
      (_) async {
        logger.i('✅ Default address set successfully');
        // Reload to get updated list with proper sorting
        await loadAddresses();
        // Show success message (key for localization)
        emit(AddressOperationSuccess(
          message: 'address_set_default_success',
          addresses: _cachedAddresses,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // SEARCH ADDRESSES (API-side, debounced from UI)
  // Empty query → snap back to cached list (no network call)
  // ════════════════════════════════════════════════════════

  Future<void> searchAddresses(String query) async {
    if (query.trim().isEmpty) {
      // Snap back to the full list without hitting the network
      emit(AddressLoaded(addresses: _cachedAddresses, defaultAddress: _cachedDefault));
      return;
    }

    emit(const AddressSearching());

    final result = await repository.searchAddresses(query.trim());

    result.fold(
      (failure) {
        logger.e('Search addresses failed: ${failure.message}');
        emit(AddressError(failure.message));
      },
      (results) {
        logger.i('✅ Search returned ${results.length} result(s) for "$query"');
        emit(AddressSearchLoaded(results: results, query: query));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // CLEAR ALL ADDRESSES
  // ════════════════════════════════════════════════════════

  Future<void> clearAllAddresses() async {
    final result = await repository.clearAllAddresses();

    await result.fold(
      (failure) {
        logger.e('Failed to clear addresses: ${failure.message}');
        emit(AddressError(failure.message));
      },
      (_) async {
        logger.i('✅ All addresses cleared');
        emit(const AddressLoaded(addresses: []));
      },
    );
  }
}
