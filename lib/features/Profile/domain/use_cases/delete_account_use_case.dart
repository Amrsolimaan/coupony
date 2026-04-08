import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class DeleteAccountUseCase {
  final ProfileRepository repository;
  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String password) =>
      repository.deleteAccount(password);
}
