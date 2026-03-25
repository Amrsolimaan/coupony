import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/password_reset_response_model.dart';
import '../repositories/auth_repository.dart';

class SendResetCodeUseCase {
  final AuthRepository repository;
  SendResetCodeUseCase(this.repository);

  Future<Either<Failure, PasswordResetResponseModel>> call(String email) =>
      repository.sendResetCode(email);
}
