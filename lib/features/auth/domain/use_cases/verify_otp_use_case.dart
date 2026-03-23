import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String phone,
    required String otp,
  }) =>
      repository.verifyOtp(phone: phone, otp: otp);
}
