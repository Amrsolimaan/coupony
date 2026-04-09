import 'package:equatable/equatable.dart';

/// Saved Address Entity (Domain Layer)
/// Represents a user's saved address with all API-compatible fields.
class SavedAddress extends Equatable {
  /// Server-assigned unique identifier (stored as String for Hive consistency)
  final String id;

  /// User-defined label (e.g., "Home", "Work", "المنزل", "العمل")
  final String label;

  /// Full address string (backward-compat; maps to address_line1 on API)
  final String address;

  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// Whether this is the default address (maps to is_default_shipping & is_default_billing)
  final bool isDefault;

  /// When the address was created
  final DateTime createdAt;

  // ════════════════════════════════════════════════════════
  // API-SPECIFIC FIELDS
  // ════════════════════════════════════════════════════════

  final String firstName;
  final String lastName;
  final String company;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String stateProvince;
  final String postalCode;
  final String countryCode;
  final String phoneNumber;
  final String deliveryInstructions;
  final bool isDefaultShipping;
  final bool isDefaultBilling;

  const SavedAddress({
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
  });

  @override
  List<Object?> get props => [
        id,
        label,
        address,
        latitude,
        longitude,
        isDefault,
        createdAt,
        firstName,
        lastName,
        company,
        addressLine1,
        addressLine2,
        city,
        stateProvince,
        postalCode,
        countryCode,
        phoneNumber,
        deliveryInstructions,
        isDefaultShipping,
        isDefaultBilling,
      ];

  @override
  String toString() {
    return 'SavedAddress(id: $id, label: $label, isDefault: $isDefault)';
  }

  /// Create a copy with modified fields
  SavedAddress copyWith({
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
    return SavedAddress(
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
