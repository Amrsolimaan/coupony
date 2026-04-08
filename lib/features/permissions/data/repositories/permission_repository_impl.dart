import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/repositories/platform_base_repository.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/repositories/permission_repository.dart';
import '../data_sources/location_geocoding_data_source.dart';
import '../data_sources/permission_local_data_source.dart';
import '../models/permission_status_model.dart';

/// Permission Repository Implementation
/// 
/// Extends PlatformBaseRepository for centralized error handling
/// of platform-specific operations (location, notifications).
class PermissionRepositoryImpl extends PlatformBaseRepository
    implements PermissionRepository {
  final PermissionLocalDataSource localDataSource;
  final LocationService locationService;
  final NotificationService notificationService;
  final LocationGeocodingDataSource geocodingDataSource;

  PermissionRepositoryImpl({
    required this.localDataSource,
    required this.locationService,
    required this.notificationService,
    required this.geocodingDataSource,
    required super.logger,
  });

  // ════════════════════════════════════════════════════════
  // LOCATION PERMISSION
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, LocationPermissionStatus>>
  checkLocationPermission() {
    return executePlatformOperation(
      operation: () => locationService.checkPermissionStatus(),
      operationName: 'check location permission',
    );
  }

  @override
  Future<Either<Failure, bool>> checkLocationServiceEnabled() {
    return executePlatformOperation(
      operation: () => locationService.isLocationServiceEnabled(),
      operationName: 'check location service',
    );
  }

  @override
  Future<Either<Failure, LocationPermissionStatus>>
  requestLocationPermission() {
    return executePlatformOperation(
      operation: () async {
        logger.i('Requesting location permission...');

        final status = await locationService.requestPermission();

        // Save to local storage
        await _updateLocalPermissionStatus(locationStatus: status);

        return status;
      },
      operationName: 'request location permission',
    );
  }

  @override
  Future<Either<Failure, Position>> getCurrentPosition() {
    return executePlatformOperation(
      operation: () async {
        final position = await locationService.getCurrentPosition();

        if (position == null) {
          throw ValidationFailure(
            'Location permission not granted or position unavailable',
          );
        }

        // Save position to local storage
        await _updateLocalPermissionStatus(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        return position;
      },
      operationName: 'get current position',
    );
  }

  /// ✅ FIXED: Open device location settings (for GPS disabled)
  @override
  Future<Either<Failure, bool>> openLocationSettings() {
    return executePlatformOperation(
      operation: () => locationService.openLocationSettings(),
      operationName: 'open location settings',
    );
  }

  /// ✅ NEW: Open app settings (for permission permanently denied)
  @override
  Future<Either<Failure, bool>> openAppSettings() {
    return executePlatformOperation(
      operation: () => locationService.openAppSettings(),
      operationName: 'open app settings',
    );
  }

  // ════════════════════════════════════════════════════════
  // NOTIFICATION PERMISSION
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, NotificationPermissionStatus>>
  checkNotificationPermission() {
    return executePlatformOperation(
      operation: () => notificationService.checkPermissionStatus(),
      operationName: 'check notification permission',
    );
  }

  @override
  Future<Either<Failure, NotificationPermissionStatus>>
  requestNotificationPermission() {
    return executePlatformOperation(
      operation: () async {
        logger.i('Requesting notification permission...');

        final status = await notificationService.requestPermission();

        // If granted, get FCM token
        String? fcmToken;
        if (status == NotificationPermissionStatus.granted ||
            status == NotificationPermissionStatus.provisional) {
          fcmToken = await notificationService.getFCMToken();
        }

        // Save to local storage
        await _updateLocalPermissionStatus(
          notificationStatus: status,
          fcmToken: fcmToken,
        );

        return status;
      },
      operationName: 'request notification permission',
    );
  }

  @override
  Future<Either<Failure, String?>> getFCMToken() {
    return executePlatformOperation(
      operation: () => notificationService.getFCMToken(),
      operationName: 'get FCM token',
    );
  }

  @override
  Future<Either<Failure, bool>> openNotificationSettings() {
    return executePlatformOperation(
      operation: () => notificationService.openAppSettings(),
      operationName: 'open notification settings',
    );
  }

  // ════════════════════════════════════════════════════════
  // LOCAL STORAGE
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, PermissionStatusModel?>> getPermissionStatus() {
    return executeStorageOperation(
      operation: () => localDataSource.getPermissionStatus(),
      operationName: 'get permission status',
    );
  }

  @override
  Future<Either<Failure, void>> savePermissionStatus({
    LocationPermissionStatus? locationStatus,
    NotificationPermissionStatus? notificationStatus,
    double? latitude,
    double? longitude,
    String? address,
    String? fcmToken,
    bool? hasCompletedFlow,
  }) {
    return executeStorageOperation(
      operation: () async {
        // Get existing status
        final existingResult = await localDataSource.getPermissionStatus();

        final existing = existingResult.fold(
          (_) => PermissionStatusModel.initial(),
          (model) => model ?? PermissionStatusModel.initial(),
        );

        // Create updated model
        final updated = existing.copyWith(
          locationStatus: locationStatus != null
              ? _mapLocationStatus(locationStatus)
              : null,
          notificationStatus: notificationStatus != null
              ? _mapNotificationStatus(notificationStatus)
              : null,
          latitude: latitude,
          longitude: longitude,
          address: address,
          fcmToken: fcmToken,
          timestamp: DateTime.now(),
          hasCompletedFlow: hasCompletedFlow,
        );

        // Save
        return await localDataSource.savePermissionStatus(updated);
      },
      operationName: 'save permission status',
    );
  }

  @override
  Future<Either<Failure, void>> clearPermissionStatus() {
    return executeStorageOperation(
      operation: () => localDataSource.clearPermissionStatus(),
      operationName: 'clear permission status',
    );
  }

  // ════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════

  /// Update local permission status (internal helper)
  Future<void> _updateLocalPermissionStatus({
    LocationPermissionStatus? locationStatus,
    NotificationPermissionStatus? notificationStatus,
    double? latitude,
    double? longitude,
    String? address,
    String? fcmToken,
  }) async {
    await savePermissionStatus(
      locationStatus: locationStatus,
      notificationStatus: notificationStatus,
      latitude: latitude,
      longitude: longitude,
      address: address,
      fcmToken: fcmToken,
    );
  }

  /// Map LocationPermissionStatus to string
  String _mapLocationStatus(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.notRequested:
        return 'not_requested';
      case LocationPermissionStatus.granted:
      case LocationPermissionStatus.grantedLimited:
        return 'granted';
      case LocationPermissionStatus.denied:
        return 'denied';
      case LocationPermissionStatus.permanentlyDenied:
        return 'permanently_denied';
      case LocationPermissionStatus.serviceDisabled:
        return 'service_disabled';
      case LocationPermissionStatus.error:
        return 'error';
    }
  }

  // ════════════════════════════════════════════════════════
  // GEOCODING
  // ════════════════════════════════════════════════════════

  @override
  Future<String> getAddressFromCoordinates(double lat, double lng) =>
      geocodingDataSource.getAddressFromCoordinates(lat, lng);

  /// Map NotificationPermissionStatus to string
  String _mapNotificationStatus(NotificationPermissionStatus status) {
    switch (status) {
      case NotificationPermissionStatus.granted:
      case NotificationPermissionStatus.provisional:
        return 'granted';
      case NotificationPermissionStatus.denied:
        return 'denied';
      case NotificationPermissionStatus.notRequested:
        return 'not_requested';
      case NotificationPermissionStatus.error:
        return 'error';
    }
  }
}
