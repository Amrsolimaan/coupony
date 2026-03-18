import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/repositories/permission_repository.dart';
import '../data_sources/permission_local_data_source.dart';
import '../models/permission_status_model.dart';

/// Permission Repository Implementation
class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionLocalDataSource localDataSource;
  final LocationService locationService;
  final NotificationService notificationService;
  final Logger logger;

  PermissionRepositoryImpl({
    required this.localDataSource,
    required this.locationService,
    required this.notificationService,
    required this.logger,
  });

  // ════════════════════════════════════════════════════════
  // LOCATION PERMISSION
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, LocationPermissionStatus>>
  checkLocationPermission() async {
    try {
      final status = await locationService.checkPermissionStatus();
      return Right(status);
    } catch (e) {
      logger.e('Error checking location permission: $e');
      return Left(UnexpectedFailure('Failed to check location permission'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkLocationServiceEnabled() async {
    try {
      final isEnabled = await locationService.isLocationServiceEnabled();
      return Right(isEnabled);
    } catch (e) {
      logger.e('Error checking location service: $e');
      return Left(UnexpectedFailure('Failed to check location service'));
    }
  }

  @override
  Future<Either<Failure, LocationPermissionStatus>>
  requestLocationPermission() async {
    try {
      logger.i('Requesting location permission...');

      final status = await locationService.requestPermission();

      // Save to local storage
      await _updateLocalPermissionStatus(locationStatus: status);

      return Right(status);
    } catch (e) {
      logger.e('Error requesting location permission: $e');
      return Left(UnexpectedFailure('Failed to request location permission'));
    }
  }

  @override
  Future<Either<Failure, Position>> getCurrentPosition() async {
    try {
      final position = await locationService.getCurrentPosition();

      if (position == null) {
        return Left(
          ValidationFailure(
            'Location permission not granted or position unavailable',
          ),
        );
      }

      // Save position to local storage
      await _updateLocalPermissionStatus(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return Right(position);
    } catch (e) {
      logger.e('Error getting current position: $e');
      return Left(UnexpectedFailure('Failed to get current position'));
    }
  }

  /// ✅ FIXED: Open device location settings (for GPS disabled)
  @override
  Future<Either<Failure, bool>> openLocationSettings() async {
    try {
      final opened = await locationService.openLocationSettings();
      return Right(opened);
    } catch (e) {
      logger.e('Error opening location settings: $e');
      return Left(UnexpectedFailure('Failed to open location settings'));
    }
  }

  /// ✅ NEW: Open app settings (for permission permanently denied)
  @override
  Future<Either<Failure, bool>> openAppSettings() async {
    try {
      final opened = await locationService.openAppSettings();
      return Right(opened);
    } catch (e) {
      logger.e('Error opening app settings: $e');
      return Left(UnexpectedFailure('Failed to open app settings'));
    }
  }

  // ════════════════════════════════════════════════════════
  // NOTIFICATION PERMISSION
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, NotificationPermissionStatus>>
  checkNotificationPermission() async {
    try {
      final status = await notificationService.checkPermissionStatus();
      return Right(status);
    } catch (e) {
      logger.e('Error checking notification permission: $e');
      return Left(UnexpectedFailure('Failed to check notification permission'));
    }
  }

  @override
  Future<Either<Failure, NotificationPermissionStatus>>
  requestNotificationPermission() async {
    try {
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

      return Right(status);
    } catch (e) {
      logger.e('Error requesting notification permission: $e');
      return Left(
        UnexpectedFailure('Failed to request notification permission'),
      );
    }
  }

  @override
  Future<Either<Failure, String?>> getFCMToken() async {
    try {
      final token = await notificationService.getFCMToken();
      return Right(token);
    } catch (e) {
      logger.e('Error getting FCM token: $e');
      return Left(UnexpectedFailure('Failed to get FCM token'));
    }
  }

  @override
  Future<Either<Failure, bool>> openNotificationSettings() async {
    try {
      final opened = await notificationService.openAppSettings();
      return Right(opened);
    } catch (e) {
      logger.e('Error opening notification settings: $e');
      return Left(UnexpectedFailure('Failed to open notification settings'));
    }
  }

  // ════════════════════════════════════════════════════════
  // LOCAL STORAGE
  // ════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, PermissionStatusModel?>> getPermissionStatus() async {
    return await localDataSource.getPermissionStatus();
  }

  @override
  Future<Either<Failure, void>> savePermissionStatus({
    LocationPermissionStatus? locationStatus,
    NotificationPermissionStatus? notificationStatus,
    double? latitude,
    double? longitude,
    String? fcmToken,
    bool? hasCompletedFlow,
  }) async {
    try {
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
        fcmToken: fcmToken,
        timestamp: DateTime.now(),
        hasCompletedFlow: hasCompletedFlow,
      );

      // Save
      return await localDataSource.savePermissionStatus(updated);
    } catch (e) {
      logger.e('Error saving permission status: $e');
      return Left(CacheFailure('Failed to save permission status'));
    }
  }

  @override
  Future<Either<Failure, void>> clearPermissionStatus() async {
    return await localDataSource.clearPermissionStatus();
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
    String? fcmToken,
  }) async {
    await savePermissionStatus(
      locationStatus: locationStatus,
      notificationStatus: notificationStatus,
      latitude: latitude,
      longitude: longitude,
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
