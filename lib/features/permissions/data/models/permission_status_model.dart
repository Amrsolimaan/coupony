import 'package:hive/hive.dart';

part 'permission_status_model.g.dart';

/// Permission Status Model
/// Stores permission status for location and notifications
/// Saved locally in Hive to avoid re-asking
@HiveType(typeId: 2) // typeId must be unique across all Hive models
class PermissionStatusModel {
  /// Location permission status
  /// Values: 'granted', 'denied', 'permanently_denied', 'not_requested'
  @HiveField(0)
  final String locationStatus;

  /// Notification permission status
  /// Values: 'granted', 'denied', 'permanently_denied', 'not_requested'
  @HiveField(1)
  final String notificationStatus;

  /// User's latitude (if location granted)
  @HiveField(2)
  final double? latitude;

  /// User's longitude (if location granted)
  @HiveField(3)
  final double? longitude;

  /// FCM Token (if notification granted)
  @HiveField(4)
  final String? fcmToken;

  /// Timestamp when permissions were last updated
  @HiveField(5)
  final DateTime timestamp;

  /// Whether user has seen the permission flow at least once
  @HiveField(6)
  final bool hasCompletedFlow;

  const PermissionStatusModel({
    required this.locationStatus,
    required this.notificationStatus,
    this.latitude,
    this.longitude,
    this.fcmToken,
    required this.timestamp,
    this.hasCompletedFlow = false,
  });

  // ════════════════════════════════════════════════════════
  // FACTORY CONSTRUCTORS
  // ════════════════════════════════════════════════════════

  /// Create initial state (nothing requested yet)
  factory PermissionStatusModel.initial() {
    return PermissionStatusModel(
      locationStatus: 'not_requested',
      notificationStatus: 'not_requested',
      timestamp: DateTime.now(),
      hasCompletedFlow: false,
    );
  }

  /// Create from JSON (for API sync if needed)
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

  /// Convert to JSON (for API sync if needed)
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

  /// Create a copy with updated fields
  PermissionStatusModel copyWith({
    String? locationStatus,
    String? notificationStatus,
    double? latitude,
    double? longitude,
    String? fcmToken,
    DateTime? timestamp,
    bool? hasCompletedFlow,
  }) {
    return PermissionStatusModel(
      locationStatus: locationStatus ?? this.locationStatus,
      notificationStatus: notificationStatus ?? this.notificationStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fcmToken: fcmToken ?? this.fcmToken,
      timestamp: timestamp ?? this.timestamp,
      hasCompletedFlow: hasCompletedFlow ?? this.hasCompletedFlow,
    );
  }

  // ════════════════════════════════════════════════════════
  // HELPER GETTERS
  // ════════════════════════════════════════════════════════

  /// Check if location permission is granted
  bool get isLocationGranted =>
      locationStatus == 'granted' || locationStatus == 'limited';

  /// Check if notification permission is granted
  bool get isNotificationGranted => notificationStatus == 'granted';

  /// Check if location is permanently denied
  bool get isLocationPermanentlyDenied =>
      locationStatus == 'permanently_denied';

  /// Check if notification is permanently denied
  bool get isNotificationPermanentlyDenied =>
      notificationStatus == 'permanently_denied';

  /// Check if user has a saved location
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if both permissions are granted
  bool get areAllPermissionsGranted => isLocationGranted && isNotificationGranted;

  @override
  String toString() {
    return 'PermissionStatusModel('
        'location: $locationStatus, '
        'notification: $notificationStatus, '
        'hasLocation: $hasLocation, '
        'hasFCM: ${fcmToken != null}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PermissionStatusModel &&
        other.locationStatus == locationStatus &&
        other.notificationStatus == notificationStatus &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.fcmToken == fcmToken &&
        other.timestamp == timestamp &&
        other.hasCompletedFlow == hasCompletedFlow;
  }

  @override
  int get hashCode {
    return locationStatus.hashCode ^
        notificationStatus.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        fcmToken.hashCode ^
        timestamp.hashCode ^
        hasCompletedFlow.hashCode;
  }
}
