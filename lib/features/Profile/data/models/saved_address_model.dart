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

  const SavedAddressModel({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    required this.createdAt,
  }) : super(
          id: id,
          label: label,
          address: address,
          latitude: latitude,
          longitude: longitude,
          isDefault: isDefault,
          createdAt: createdAt,
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
    );
  }

  factory SavedAddressModel.fromJson(Map<String, dynamic> json) {
    return SavedAddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // ════════════════════════════════════════════════════════
  // TO JSON
  // ════════════════════════════════════════════════════════

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
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
  }) {
    return SavedAddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
