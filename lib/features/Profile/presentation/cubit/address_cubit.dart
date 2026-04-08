import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/saved_address.dart';
import '../../domain/repositories/address_repository.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository repository;
  final Logger logger;

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

        emit(AddressLoaded(
          addresses: addresses,
          defaultAddress: defaultAddress,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // SAVE ADDRESS
  // ════════════════════════════════════════════════════════

  Future<void> saveAddress({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    bool setAsDefault = false,
  }) async {
    try {
      final newAddress = SavedAddress(
        id: const Uuid().v4(),
        label: label,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: setAsDefault,
        createdAt: DateTime.now(),
      );

      final result = await repository.saveAddress(newAddress);

      await result.fold(
        (failure) {
          logger.e('Failed to save address: ${failure.message}');
          emit(AddressError(failure.message));
        },
        (_) async {
          logger.i('✅ Address saved successfully');
          
          // If set as default, update all addresses
          if (setAsDefault) {
            await repository.setDefaultAddress(newAddress.id);
          }
          
          // Reload addresses
          await loadAddresses();
        },
      );
    } catch (e) {
      logger.e('Error saving address: $e');
      emit(AddressError('Failed to save address'));
    }
  }

  // ════════════════════════════════════════════════════════
  // UPDATE ADDRESS
  // ════════════════════════════════════════════════════════

  Future<void> updateAddress(SavedAddress address) async {
    final result = await repository.updateAddress(address);

    await result.fold(
      (failure) {
        logger.e('Failed to update address: ${failure.message}');
        emit(AddressError(failure.message));
      },
      (_) async {
        logger.i('✅ Address updated successfully');
        await loadAddresses();
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // DELETE ADDRESS
  // ════════════════════════════════════════════════════════

  Future<void> deleteAddress(String id) async {
    final result = await repository.deleteAddress(id);

    await result.fold(
      (failure) {
        logger.e('Failed to delete address: ${failure.message}');
        emit(AddressError(failure.message));
      },
      (_) async {
        logger.i('✅ Address deleted successfully');
        await loadAddresses();
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // SET DEFAULT ADDRESS
  // ════════════════════════════════════════════════════════

  Future<void> setDefaultAddress(String id) async {
    final result = await repository.setDefaultAddress(id);

    await result.fold(
      (failure) {
        logger.e('Failed to set default address: ${failure.message}');
        emit(AddressError(failure.message));
      },
      (_) async {
        logger.i('✅ Default address set successfully');
        await loadAddresses();
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
