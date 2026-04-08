import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/saved_address.dart';
import '../../domain/repositories/address_repository.dart';
import '../data_sources/address_local_data_source.dart';
import '../models/saved_address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressLocalDataSource localDataSource;

  AddressRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<SavedAddress>>> getAllAddresses() async {
    return await localDataSource.getAllAddresses();
  }

  @override
  Future<Either<Failure, SavedAddress?>> getDefaultAddress() async {
    return await localDataSource.getDefaultAddress();
  }

  @override
  Future<Either<Failure, void>> saveAddress(SavedAddress address) async {
    final model = SavedAddressModel.fromEntity(address);
    return await localDataSource.saveAddress(model);
  }

  @override
  Future<Either<Failure, void>> updateAddress(SavedAddress address) async {
    final model = SavedAddressModel.fromEntity(address);
    return await localDataSource.updateAddress(model);
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String id) async {
    return await localDataSource.deleteAddress(id);
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String id) async {
    return await localDataSource.setDefaultAddress(id);
  }

  @override
  Future<Either<Failure, void>> clearAllAddresses() async {
    return await localDataSource.clearAllAddresses();
  }
}
