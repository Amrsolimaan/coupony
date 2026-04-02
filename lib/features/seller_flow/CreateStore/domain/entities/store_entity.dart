import 'package:equatable/equatable.dart';
import 'social_link_entity.dart';
import 'verification_docs_entity.dart';

/// Represents a seller store in the domain layer.
///
/// [latitude] and [longitude] are Strings as required by the API.
class StoreEntity extends Equatable {
  final String name;
  final String description;
  final String email;
  final String phone;
  final String addressLine1;
  final String city;
  final String latitude;
  final String longitude;
  final List<int> categories;
  final List<SocialLinkEntity> socials;
  final VerificationDocsEntity? verificationDocs;

  const StoreEntity({
    required this.name,
    required this.description,
    required this.email,
    required this.phone,
    required this.addressLine1,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.categories,
    this.socials = const [],
    this.verificationDocs,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        email,
        phone,
        addressLine1,
        city,
        latitude,
        longitude,
        categories,
        socials,
        verificationDocs,
      ];
}
