import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/location_service.dart';
import '../repositories/permission_repository.dart';

/// Request Location Permission Use Case
/// Handles the complete flow of requesting location permission
/// and fetching the user's position if granted
class RequestLocationPermissionUseCase {
  final PermissionRepository repository;

  RequestLocationPermissionUseCase(this.repository);

  /// Execute the use case
  /// Returns the permission status and position (if granted)
  Future<Either<Failure, LocationPermissionResult>> execute() async {
    // Step 1: Check if location service (GPS) is enabled
    final serviceResult = await repository.checkLocationServiceEnabled();

    final serviceEnabled = serviceResult.fold(
      (failure) => false,
      (enabled) => enabled,
    );

    if (!serviceEnabled) {
      return Right(
        LocationPermissionResult(
          status: LocationPermissionStatus.serviceDisabled,
          position: null,
        ),
      );
    }

    // Step 2: Request location permission
    final permissionResult = await repository.requestLocationPermission();

    return permissionResult.fold(
      (failure) => Left(failure),
      (status) async {
        // Step 3: If granted, try to fetch current position
        if (status == LocationPermissionStatus.granted ||
            status == LocationPermissionStatus.grantedLimited) {
          final positionResult = await repository.getCurrentPosition();

          return positionResult.fold(
            (failure) {
              // Permission granted but position fetch failed
              return Right(
                LocationPermissionResult(
                  status: status,
                  position: null,
                  positionFetchFailed: true,
                ),
              );
            },
            (position) {
              // Success! Permission granted and position fetched
              return Right(
                LocationPermissionResult(
                  status: status,
                  position: position,
                ),
              );
            },
          );
        } else {
          // Permission denied or other status
          return Right(
            LocationPermissionResult(
              status: status,
              position: null,
            ),
          );
        }
      },
    );
  }
}

/// Result of requesting location permission
class LocationPermissionResult {
  final LocationPermissionStatus status;
  final Position? position;
  final bool positionFetchFailed;

  LocationPermissionResult({
    required this.status,
    this.position,
    this.positionFetchFailed = false,
  });

  /// Check if permission was granted
  bool get isGranted =>
      status == LocationPermissionStatus.granted ||
      status == LocationPermissionStatus.grantedLimited;

  /// Check if position was successfully fetched
  bool get hasPosition => position != null;
}
