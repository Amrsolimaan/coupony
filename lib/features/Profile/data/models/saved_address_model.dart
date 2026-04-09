import 'package:hive/hive.dart';
import '../../domain/entities/saved_address.dart';

part 'saved_address_model.g.dart';

@HiveType(typeId: 4)
class SavedAddressModel extends SavedAddress {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String label;

  @override
  @HiveField(2)
  final String address;

  @override
  @HiveField(3)
  final double latitude;

  @override
  @HiveField(4)
  final double longitude;

  @override
  @HiveField(5)
  final bool isDefault;

  @override
  @HiveField(6)
  final DateTime createdAt;

  // ════════════════════════════════════════════════════════
  // API-SPECIFIC HIVE FIELDS
  // ════════════════════════════════════════════════════════

  @override
  @HiveField(7)
  final String firstName;

  @override
  @HiveField(8)
  final String lastName;

  @override
  @HiveField(9)
  final String company;

  @override
  @HiveField(10)
  final String addressLine1;

  @override
  @HiveField(11)
  final String addressLine2;

  @override
  @HiveField(12)
  final String city;

  @override
  @HiveField(13)
  final String stateProvince;

  @override
  @HiveField(14)
  final String postalCode;

  @override
  @HiveField(15)
  final String countryCode;

  @override
  @HiveField(16)
  final String phoneNumber;

  @override
  @HiveField(17)
  final String deliveryInstructions;

  @override
  @HiveField(18)
  final bool isDefaultShipping;

  @override
  @HiveField(19)
  final bool isDefaultBilling;

  const SavedAddressModel({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    required this.createdAt,
    this.firstName = '',
    this.lastName = '',
    this.company = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.city = '',
    this.stateProvince = '',
    this.postalCode = '',
    this.countryCode = 'EG',
    this.phoneNumber = '',
    this.deliveryInstructions = '',
    this.isDefaultShipping = false,
    this.isDefaultBilling = false,
  }) : super(
          id: id,
          label: label,
          address: address,
          latitude: latitude,
          longitude: longitude,
          isDefault: isDefault,
          createdAt: createdAt,
          firstName: firstName,
          lastName: lastName,
          company: company,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          city: city,
          stateProvince: stateProvince,
          postalCode: postalCode,
          countryCode: countryCode,
          phoneNumber: phoneNumber,
          deliveryInstructions: deliveryInstructions,
          isDefaultShipping: isDefaultShipping,
          isDefaultBilling: isDefaultBilling,
        );

  // ════════════════════════════════════════════════════════
  // FACTORY CONSTRUCTORS
  // ════════════════════════════════════════════════════════

  factory SavedAddressModel.fromEntity(SavedAddress entity) {
    return SavedAddressModel(
      id: entity.id,
      label: entity.label,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      firstName: entity.firstName,
      lastName: entity.lastName,
      company: entity.company,
      addressLine1: entity.addressLine1,
      addressLine2: entity.addressLine2,
      city: entity.city,
      stateProvince: entity.stateProvince,
      postalCode: entity.postalCode,
      countryCode: entity.countryCode,
      phoneNumber: entity.phoneNumber,
      deliveryInstructions: entity.deliveryInstructions,
      isDefaultShipping: entity.isDefaultShipping,
      isDefaultBilling: entity.isDefaultBilling,
    );
  }

  /// Parse API JSON response.
  /// Server `id` may be int or String — always stored as String.
  factory SavedAddressModel.fromJson(Map<String, dynamic> json) {
    return SavedAddressModel(
      id: json['id']?.toString() ?? '',
      label: json['label'] as String? ?? '',
      address: json['address_line1'] as String? ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      isDefault: (json['is_default_shipping'] as bool? ?? false),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      company: json['company'] as String? ?? '',
      addressLine1: json['address_line1'] as String? ?? '',
      addressLine2: json['address_line2'] as String? ?? '',
      city: json['city'] as String? ?? '',
      stateProvince: json['state_province'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? 'EG',
      phoneNumber: json['phone_number'] as String? ?? '',
      deliveryInstructions: json['delivery_instructions'] as String? ?? '',
      isDefaultShipping: json['is_default_shipping'] as bool? ?? false,
      isDefaultBilling: json['is_default_billing'] as bool? ?? false,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ════════════════════════════════════════════════════════
  // TO JSON — Full representation for API responses/caching
  // ════════════════════════════════════════════════════════

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address_line1': addressLine1.isNotEmpty ? addressLine1 : address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default_shipping': isDefaultShipping,
      'is_default_billing': isDefaultBilling,
      'created_at': createdAt.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'company': company,
      'address_line2': addressLine2,
      'city': city,
      'state_province': stateProvince,
      'postal_code': postalCode,
      'country_code': countryCode,
      'phone_number': phoneNumber,
      'delivery_instructions': deliveryInstructions,
    };
  }

  /// JSON body for POST /me/addresses (excludes `id`, server assigns it)
  Map<String, dynamic> toCreateJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'company': company,
      'address_line1': addressLine1.isNotEmpty ? addressLine1 : address,
      'address_line2': addressLine2,
      'city': city,
      'state_province': stateProvince,
      'postal_code': postalCode,
      'country_code': countryCode,
      'phone_number': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_instructions': deliveryInstructions,
      'label': label,
      'is_default_shipping': isDefaultShipping,
      'is_default_billing': isDefaultBilling,
    };
  }

  /// JSON body for PATCH /me/addresses/{id} (only changed fields)
  Map<String, dynamic> toUpdateJson() {
    final data = <String, dynamic>{};
    if (firstName.isNotEmpty) data['first_name'] = firstName;
    if (lastName.isNotEmpty) data['last_name'] = lastName;
    if (company.isNotEmpty) data['company'] = company;
    if (addressLine1.isNotEmpty || address.isNotEmpty) {
      data['address_line1'] = addressLine1.isNotEmpty ? addressLine1 : address;
    }
    if (addressLine2.isNotEmpty) data['address_line2'] = addressLine2;
    if (city.isNotEmpty) data['city'] = city;
    if (stateProvince.isNotEmpty) data['state_province'] = stateProvince;
    if (postalCode.isNotEmpty) data['postal_code'] = postalCode;
    if (countryCode.isNotEmpty) data['country_code'] = countryCode;
    if (phoneNumber.isNotEmpty) data['phone_number'] = phoneNumber;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    if (deliveryInstructions.isNotEmpty) {
      data['delivery_instructions'] = deliveryInstructions;
    }
    data['label'] = label;
    data['is_default_shipping'] = isDefaultShipping;
    data['is_default_billing'] = isDefaultBilling;
    return data;
  }

  // ════════════════════════════════════════════════════════
  // COPY WITH
  // ════════════════════════════════════════════════════════

  SavedAddressModel copyWith({
    String? id,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
    String? firstName,
    String? lastName,
    String? company,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? stateProvince,
    String? postalCode,
    String? countryCode,
    String? phoneNumber,
    String? deliveryInstructions,
    bool? isDefaultShipping,
    bool? isDefaultBilling,
  }) {
    return SavedAddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      company: company ?? this.company,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      stateProvince: stateProvince ?? this.stateProvince,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      isDefaultShipping: isDefaultShipping ?? this.isDefaultShipping,
      isDefaultBilling: isDefaultBilling ?? this.isDefaultBilling,
    );
  }
}
