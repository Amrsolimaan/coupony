import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
import 'reset_password_params.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call(ResetPasswordParams params) =>
      repository.resetPassword(params);
}
