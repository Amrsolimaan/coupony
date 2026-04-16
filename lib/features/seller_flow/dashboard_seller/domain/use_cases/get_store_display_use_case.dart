import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/store_display_entity.dart';
import '../repositories/seller_store_repository.dart';

// ════════════════════════════════════════════════════════
// GET STORE DISPLAY USE CASE
// ════════════════════════════════════════════════════════

/// Use case for fetching the seller's store display information.
/// This includes all data needed to render the store page:
/// - Basic info (name, description, logo, banner)
/// - Categories
/// - Business hours
/// - Ratings
/// - Mock data for followers, coupons, reviews (until endpoints are available)
class GetStoreDisplayUseCase {
  final SellerStoreRepository repository;

  const GetStoreDisplayUseCase(this.repository);

  /// Executes the use case.
  /// Returns [StoreDisplayEntity] on success, [Failure] on error.
  Future<Either<Failure, StoreDisplayEntity>> call() {
    return repository.getStoreDisplay();
  }
}
