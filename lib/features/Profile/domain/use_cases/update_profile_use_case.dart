import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';
import 'update_profile_params.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) =>
      repository.updateProfile(params);
}
