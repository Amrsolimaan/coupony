import 'package:equatable/equatable.dart';

/// Permission Entity (Domain Layer)
/// Represents permission status for location and notifications
/// This is the domain model - pure business logic, no dependencies
class PermissionEntity extends Equatable {
  /// Location permission status
  /// Values: 'granted', 'denied', 'permanently_denied', 'not_requested'
  final String locationStatus;

  /// Notification permission status
  /// Values: 'granted', 'denied', 'permanently_denied', 'not_requested'
  final String notificationStatus;

  /// User's latitude (if location granted)
  final double? latitude;

  /// User's longitude (if location granted)
  final double? longitude;

  /// FCM Token (if notification granted)
  final String? fcmToken;

  /// Timestamp when permissions were last updated
  final DateTime timestamp;

  /// Whether user has seen the permission flow at least once
  final bool hasCompletedFlow;

  const PermissionEntity({
    required this.locationStatus,
    required this.notificationStatus,
    this.latitude,
    this.longitude,
    this.fcmToken,
    required this.timestamp,
    this.hasCompletedFlow = false,
  });

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
  bool get areAllPermissionsGranted =>
      isLocationGranted && isNotificationGranted;

  @override
  List<Object?> get props => [
        locationStatus,
        notificationStatus,
        latitude,
        longitude,
        fcmToken,
        timestamp,
        hasCompletedFlow,
      ];

  @override
  String toString() {
    return 'PermissionEntity('
        'location: $locationStatus, '
        'notification: $notificationStatus, '
        'hasLocation: $hasLocation, '
        'hasFCM: ${fcmToken != null}'
        ')';
  }
}
