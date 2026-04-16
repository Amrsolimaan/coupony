import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failures.dart';
import '../entities/store_display_entity.dart';
import '../repositories/seller_store_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PARAMS
// ─────────────────────────────────────────────────────────────────────────────

class StoreHoursParams {
  final int dayOfWeek;   // 0 = Sunday … 6 = Saturday
  final String openTime;  // "HH:mm"
  final String closeTime; // "HH:mm"
  final bool isClosed;

  const StoreHoursParams({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });
}

class UpdateStoreProfileParams {
  final String storeId;
  final String name;
  final String? description;
  final String? email;
  final String? phone;
  final List<StoreHoursParams> hours;
  final List<int>? categoryIds;

  const UpdateStoreProfileParams({
    required this.storeId,
    required this.name,
    this.description,
    this.email,
    this.phone,
    required this.hours,
    this.categoryIds,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// USE CASE
// ─────────────────────────────────────────────────────────────────────────────

class UpdateStoreProfileUseCase {
  final SellerStoreRepository repository;
  const UpdateStoreProfileUseCase(this.repository);

  Future<Either<Failure, StoreDisplayEntity>> call(
    UpdateStoreProfileParams params,
  ) =>
      repository.updateStoreProfile(params);
}
