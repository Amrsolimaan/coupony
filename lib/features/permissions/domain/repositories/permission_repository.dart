import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/permission_status_model.dart';

/// Permission Repository Interface (Domain Layer)
/// Defines operations for permission management
abstract class PermissionRepository {
  // ════════════════════════════════════════════════════════
  // LOCATION PERMISSION
  // ════════════════════════════════════════════════════════

  /// Check location permission status (without requesting)
  Future<Either<Failure, LocationPermissionStatus>> checkLocationPermission();

  /// Check if location service (GPS) is enabled
  Future<Either<Failure, bool>> checkLocationServiceEnabled();

  /// Request location permission (MUST show rationale first)
  Future<Either<Failure, LocationPermissionStatus>> requestLocationPermission();

  /// Get current position (latitude, longitude)
  Future<Either<Failure, Position>> getCurrentPosition();

  /// ✅ NEW: Open device location settings (for GPS disabled)
  Future<Either<Failure, bool>> openLocationSettings();

  /// Open app settings (for permanently denied)
  Future<Either<Failure, bool>> openAppSettings();

  // ════════════════════════════════════════════════════════
  // NOTIFICATION PERMISSION
  // ════════════════════════════════════════════════════════

  /// Check notification permission status (without requesting)
  Future<Either<Failure, NotificationPermissionStatus>>
  checkNotificationPermission();

  /// Request notification permission (MUST show rationale first)
  Future<Either<Failure, NotificationPermissionStatus>>
  requestNotificationPermission();

  /// Get FCM token (for push notifications)
  Future<Either<Failure, String?>> getFCMToken();

  /// Open app settings (for permanently denied)
  Future<Either<Failure, bool>> openNotificationSettings();

  // ════════════════════════════════════════════════════════
  // LOCAL STORAGE
  // ════════════════════════════════════════════════════════

  /// Get saved permission status from local storage
  Future<Either<Failure, PermissionStatusModel?>> getPermissionStatus();

  /// Save permission status to local storage
  Future<Either<Failure, void>> savePermissionStatus({
    LocationPermissionStatus? locationStatus,
    NotificationPermissionStatus? notificationStatus,
    double? latitude,
    double? longitude,
    String? address,
    String? fcmToken,
    bool? hasCompletedFlow,
  });

  /// Clear all permission data
  Future<Either<Failure, void>> clearPermissionStatus();

  // ════════════════════════════════════════════════════════
  // GEOCODING
  // ════════════════════════════════════════════════════════

  /// Reverse-geocode [lat],[lng] to a human-readable Arabic address.
  /// Never throws — returns a formatted coordinate string as fallback.
  Future<String> getAddressFromCoordinates(double lat, double lng);
}
