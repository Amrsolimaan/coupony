import '../repositories/permission_repository.dart';

/// Converts a lat/lng pair into a human-readable Arabic address.
/// Always succeeds — returns formatted coordinates as a last resort.
class GetAddressFromCoordinatesUseCase {
  final PermissionRepository repository;

  const GetAddressFromCoordinatesUseCase(this.repository);

  Future<String> execute(double lat, double lng) =>
      repository.getAddressFromCoordinates(lat, lng);
}
