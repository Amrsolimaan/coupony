import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Location Service
/// Handles location permission requests and position fetching
///
/// IMPORTANT - Privacy Compliance:
/// - NEVER requests permission without user action
/// - Always shows rationale BEFORE requesting
/// - Requests WHILE_IN_USE only (not ALWAYS)
/// - Handles graceful degradation on denial
class LocationService {
  final Logger logger;

  LocationService({required this.logger});

  // ════════════════════════════════════════════════════════
  // PERMISSION CHECK
  // ════════════════════════════════════════════════════════

  /// Check current location permission status
  /// Does NOT request permission, only checks
  Future<LocationPermissionStatus> checkPermissionStatus() async {
    try {
      final permission = await Geolocator.checkPermission();

      logger.d('Location permission status: $permission');

      return _mapGeolocatorPermission(permission);
    } catch (e) {
      logger.e('Error checking location permission: $e');
      return LocationPermissionStatus.error;
    }
  }

  /// Check if location services are enabled (GPS)
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      logger.e('Error checking location service: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════
  // PERMISSION REQUEST (CONTEXTUAL)
  // ════════════════════════════════════════════════════════

  /// Request location permission (WHILE_IN_USE only)
  ///
  /// MUST be called AFTER showing rationale to user
  /// Should only be called when user clicks "Allow" button
  ///
  /// Returns permission status after request
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      logger.i('Requesting location permission (WHILE_IN_USE)...');

      // First check if service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w('Location service is disabled');
        return LocationPermissionStatus.serviceDisabled;
      }

      // Request permission (this shows system dialog)
      final permission = await Geolocator.requestPermission();

      logger.i('Location permission result: $permission');

      return _mapGeolocatorPermission(permission);
    } catch (e) {
      logger.e('Error requesting location permission: $e');
      return LocationPermissionStatus.error;
    }
  }

  // ════════════════════════════════════════════════════════
  // POSITION FETCHING
  // ════════════════════════════════════════════════════════

  /// Get current position (latitude, longitude)
  /// Requires permission to be granted first
  Future<Position?> getCurrentPosition() async {
    try {
      // Verify permission is granted
      final status = await checkPermissionStatus();
      if (status != LocationPermissionStatus.granted &&
          status != LocationPermissionStatus.grantedLimited) {
        logger.w('Cannot get position: Permission not granted');
        return null;
      }

      logger.d('Fetching current position...');

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      logger.i('Position fetched: ${position.latitude}, ${position.longitude}');

      return position;
    } catch (e) {
      logger.e('Error getting current position: $e');
      return null;
    }
  }

  /// Get last known position (faster, less accurate)
  Future<Position?> getLastKnownPosition() async {
    try {
      final position = await Geolocator.getLastKnownPosition();

      if (position != null) {
        logger.d(
          'Last known position: ${position.latitude}, ${position.longitude}',
        );
      } else {
        logger.d('No last known position available');
      }

      return position;
    } catch (e) {
      logger.e('Error getting last known position: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════════════════
  // SETTINGS NAVIGATION
  // ════════════════════════════════════════════════════════

  /// Open device location settings (for GPS disabled)
  ///
  /// ✅ NEW METHOD
  /// Opens the device's Location/GPS settings page
  /// Use this when GPS is turned off
  Future<bool> openLocationSettings() async {
    try {
      logger.i('Opening device location settings (GPS settings)...');
      return await Geolocator.openLocationSettings();
    } catch (e) {
      logger.e('Error opening location settings: $e');
      return false;
    }
  }

  /// Open app settings (for permanently denied permission)
  ///
  /// Opens the app's settings page where user can grant location permission
  /// Use this when permission is permanently denied
  Future<bool> openAppSettings() async {
    try {
      logger.i('Opening app settings for location permission...');
      return await ph.openAppSettings();
    } catch (e) {
      logger.e('Error opening app settings: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════

  /// Map Geolocator permission to our custom enum
  LocationPermissionStatus _mapGeolocatorPermission(
    LocationPermission permission,
  ) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.permanentlyDenied;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.error;
    }
  }
}

// ════════════════════════════════════════════════════════
// ENUMS
// ════════════════════════════════════════════════════════

/// Location permission status
enum LocationPermissionStatus {
  /// Permission not requested yet
  notRequested,

  /// Permission granted (while in use or always)
  granted,

  /// Permission granted but limited (iOS 14+ approximate location)
  grantedLimited,

  /// Permission denied (can ask again)
  denied,

  /// Permission permanently denied (user selected "Don't ask again")
  permanentlyDenied,

  /// Location service is disabled (GPS off)
  serviceDisabled,

  /// Error occurred
  error,
}
