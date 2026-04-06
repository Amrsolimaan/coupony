import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/location_service.dart';
import '../repositories/permission_repository.dart';

/// Requests location permission from the OS.
///
/// Responsibility: permission dialog only.
/// Position fetching is a separate operation — see PermissionFlowCubit.
/// This keeps navigation to the map screen non-blocking (UX P1).
class RequestLocationPermissionUseCase {
  final PermissionRepository repository;

  RequestLocationPermissionUseCase(this.repository);

  /// Returns the resulting [LocationPermissionStatus].
  /// Returns [LocationPermissionStatus.serviceDisabled] if GPS is off.
  Future<Either<Failure, LocationPermissionStatus>> execute() async {
    // 1. Guard: GPS service must be enabled before we can request permission
    final serviceResult = await repository.checkLocationServiceEnabled();

    final serviceEnabled = serviceResult.fold((_) => false, (e) => e);
    if (!serviceEnabled) {
      return const Right(LocationPermissionStatus.serviceDisabled);
    }

    // 2. Show the OS permission dialog — returns immediately after user responds
    return repository.requestLocationPermission();
  }
}
