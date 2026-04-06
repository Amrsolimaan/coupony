import 'dart:io';

import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/social_link_entity.dart';
import '../repositories/create_store_repository.dart';

/// Parameters for creating a new store.
class CreateStoreParams {
  final String name;
  final String description;
  final String phone;
  /// Single category integer ID — serialised as `categories[]` array in the API.
  final int categoryId;
  /// Free-text city name — sent as `city`.
  final String city;
  /// Address detail (street / district) — sent as `address_line1`.
  final String addressLine1;
  final String latitude;
  final String longitude;
  final List<SocialLinkEntity> socials;

  // Optional files
  final File? logo;
  final File? commercialRegister;
  final File? taxCard;
  final File? idCardFront;
  final File? idCardBack;

  const CreateStoreParams({
    required this.name,
    required this.description,
    required this.phone,
    required this.categoryId,
    required this.city,
    required this.addressLine1,
    required this.latitude,
    required this.longitude,
    this.socials = const [],
    this.logo,
    this.commercialRegister,
    this.taxCard,
    this.idCardFront,
    this.idCardBack,
  });
}

class CreateStoreUseCase {
  final CreateStoreRepository repository;

  const CreateStoreUseCase(this.repository);

  Future<Either<Failure, bool>> call(CreateStoreParams params) {
    return repository.createStore(params);
  }
}
