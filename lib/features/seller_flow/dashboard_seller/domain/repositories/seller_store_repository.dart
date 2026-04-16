import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/store_display_entity.dart';
import '../use_cases/update_store_profile_use_case.dart';

// ════════════════════════════════════════════════════════
// SELLER STORE REPOSITORY INTERFACE
// ════════════════════════════════════════════════════════

abstract class SellerStoreRepository {
  /// GET /api/v1/stores
  Future<Either<Failure, StoreDisplayEntity>> getStoreDisplay();

  /// POST /api/v1/stores/{id}/profile  (_method: PATCH)
  Future<Either<Failure, StoreDisplayEntity>> updateStoreProfile(
    UpdateStoreProfileParams params,
  );
}
