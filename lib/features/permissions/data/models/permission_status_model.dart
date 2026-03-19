import 'package:hive/hive.dart';

import '../../domain/entities/permission_entity.dart';

part 'permission_status_model.g.dart';

@HiveType(typeId: 2)
class PermissionStatusModel extends PermissionEntity {
  // ════════════════════════════════════════════════════════
  // SENTINEL — used to detect "not passed" in copyWith
  // ════════════════════════════════════════════════════════
  static const Object _sentinel = Object();

  // ════════════════════════════════════════════════════════
  // HIVE FIELDS
  // ════════════════════════════════════════════════════════
  @override
  @HiveField(0)
  final String locationStatus;

  @override
  @HiveField(1)
  final String notificationStatus;

  @override
  @HiveField(2)
  final double? latitude;

  @override
  @HiveField(3)
  final double? longitude;

  @override
  @HiveField(4)
  final String? fcmToken;

  @override
  @HiveField(5)
  final DateTime timestamp;

  @override
  @HiveField(6)
  final bool hasCompletedFlow;

  // ════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ════════════════════════════════════════════════════════
  const PermissionStatusModel({
    required this.locationStatus,
    required this.notificationStatus,
    this.latitude,
    this.longitude,
    this.fcmToken,
    required this.timestamp,
    this.hasCompletedFlow = false,
  }) : super(
          locationStatus: locationStatus,
          notificationStatus: notificationStatus,
          latitude: latitude,
          longitude: longitude,
          fcmToken: fcmToken,
          timestamp: timestamp,
          hasCompletedFlow: hasCompletedFlow,
        );

  // ════════════════════════════════════════════════════════
  // FACTORY CONSTRUCTORS
  // ════════════════════════════════════════════════════════

  factory PermissionStatusModel.initial() {
    return PermissionStatusModel(
      locationStatus: 'not_requested',
      notificationStatus: 'not_requested',
      timestamp: DateTime.now(),
      hasCompletedFlow: false,
    );
  }

  factory PermissionStatusModel.fromJson(Map<String, dynamic> json) {
    return PermissionStatusModel(
      locationStatus: json['location_status'] as String,
      notificationStatus: json['notification_status'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      fcmToken: json['fcm_token'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      hasCompletedFlow: json['has_completed_flow'] as bool? ?? false,
    );
  }

  // ════════════════════════════════════════════════════════
  // TO JSON
  // ════════════════════════════════════════════════════════

  Map<String, dynamic> toJson() {
    return {
      'location_status': locationStatus,
      'notification_status': notificationStatus,
      'latitude': latitude,
      'longitude': longitude,
      'fcm_token': fcmToken,
      'timestamp': timestamp.toIso8601String(),
      'has_completed_flow': hasCompletedFlow,
    };
  }

  // ════════════════════════════════════════════════════════
  // COPY WITH
  // ════════════════════════════════════════════════════════

  PermissionStatusModel copyWith({
    String? locationStatus,
    String? notificationStatus,
    Object? latitude = _sentinel,   // ✅ Object? مش double?
    Object? longitude = _sentinel,  // ✅ Object? مش double?
    Object? fcmToken = _sentinel,   // ✅ Object? مش String?
    DateTime? timestamp,
    bool? hasCompletedFlow,
  }) {
    return PermissionStatusModel(
      locationStatus: locationStatus ?? this.locationStatus,
      notificationStatus: notificationStatus ?? this.notificationStatus,
      latitude: latitude == _sentinel ? this.latitude : latitude as double?,
      longitude: longitude == _sentinel ? this.longitude : longitude as double?,
      fcmToken: fcmToken == _sentinel ? this.fcmToken : fcmToken as String?,
      timestamp: timestamp ?? this.timestamp,
      hasCompletedFlow: hasCompletedFlow ?? this.hasCompletedFlow,
    );
  }

  // ════════════════════════════════════════════════════════
  // TO STRING
  // ════════════════════════════════════════════════════════

  @override
  String toString() {
    return 'PermissionStatusModel('
        'location: $locationStatus, '
        'notification: $notificationStatus, '
        'hasLocation: $hasLocation, '
        'hasFCM: ${fcmToken != null}'
        ')';
  }
}