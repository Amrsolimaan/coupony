import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../use_cases/update_profile_params.dart';

abstract class ProfileRepository {
  /// GET /auth/me — fetch the authenticated user's full profile.
  Future<Either<Failure, UserEntity>> getProfile();

  /// PATCH /auth/me — update profile fields and/or upload a new avatar.
  Future<Either<Failure, UserEntity>> updateProfile(UpdateProfileParams params);

  /// DELETE /auth/me — permanently delete the authenticated account.
  Future<Either<Failure, Unit>> deleteAccount(String password);
}
