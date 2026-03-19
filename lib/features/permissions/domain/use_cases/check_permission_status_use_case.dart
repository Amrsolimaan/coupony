import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../repositories/permission_repository.dart';

/// Check Permission Status Use Case
/// Checks the current status of location and notification permissions
/// without requesting them
class CheckPermissionStatusUseCase {
  final PermissionRepository repository;

  CheckPermissionStatusUseCase(this.repository);

  /// Execute the use case
  /// Returns a map with location and notification status
  Future<Either<Failure, PermissionStatusResult>> execute() async {
    // Check location permission
    final locationResult = await repository.checkLocationPermission();

    // Check notification permission
    final notificationResult = await repository.checkNotificationPermission();

    // Check location service (GPS) enabled
    final serviceResult = await repository.checkLocationServiceEnabled();

    return locationResult.fold(
      (failure) => Left(failure),
      (locationStatus) {
        return notificationResult.fold(
          (failure) => Left(failure),
          (notificationStatus) {
            return serviceResult.fold(
              (failure) => Left(failure),
              (serviceEnabled) {
                return Right(
                  PermissionStatusResult(
                    locationStatus: locationStatus,
                    notificationStatus: notificationStatus,
                    isLocationServiceEnabled: serviceEnabled,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Result of checking permission status
class PermissionStatusResult {
  final LocationPermissionStatus locationStatus;
  final NotificationPermissionStatus notificationStatus;
  final bool isLocationServiceEnabled;

  PermissionStatusResult({
    required this.locationStatus,
    required this.notificationStatus,
    required this.isLocationServiceEnabled,
  });
}
