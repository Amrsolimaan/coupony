import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/password_reset_response_model.dart';
import '../repositories/auth_repository.dart';

class ResendResetCodeUseCase {
  final AuthRepository repository;
  ResendResetCodeUseCase(this.repository);

  Future<Either<Failure, PasswordResetResponseModel>> call(String email) =>
      repository.resendResetCode(email);
}
