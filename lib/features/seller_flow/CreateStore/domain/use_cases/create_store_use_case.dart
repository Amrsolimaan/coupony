import 'dart:io';

import 'package:coupony/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/social_link_entity.dart';
import '../repositories/create_store_repository.dart';

/// Parameters for creating a new store.
class CreateStoreParams {
  final String name;
  final String description;
  final String email;
  final String phone;
  final String addressLine1;
  final String city;
  final String latitude;
  final String longitude;
  final List<int> categoryIds;
  final List<SocialLinkEntity> socials;

  // Optional files
  final File? logoUrl;
  final File? commercialRegister;
  final File? taxCard;
  final File? idCardFront;
  final File? idCardBack;

  const CreateStoreParams({
    required this.name,
    required this.description,
    required this.email,
    required this.phone,
    required this.addressLine1,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.categoryIds,
    this.socials = const [],
    this.logoUrl,
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
