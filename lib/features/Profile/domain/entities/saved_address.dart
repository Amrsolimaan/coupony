import 'package:equatable/equatable.dart';

/// Saved Address Entity (Domain Layer)
/// Represents a user's saved address with location details
class SavedAddress extends Equatable {
  /// Unique identifier for the address
  final String id;

  /// User-defined label (e.g., "Home", "Work", "المنزل", "العمل")
  final String label;

  /// Full address string (from geocoding)
  final String address;

  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// Whether this is the default address
  final bool isDefault;

  /// When the address was created
  final DateTime createdAt;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    required this.createdAt,
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
      ];

  @override
  String toString() {
    return 'SavedAddress(id: $id, label: $label, isDefault: $isDefault)';
  }
}
