import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Validates the password-reset OTP with the server before allowing
/// navigation to ResetPasswordScreen.
///
/// Calls POST /auth/otp/verify with purpose: reset_password.
/// Returns [Unit] on success, [InvalidTokenFailure] on HTTP 422.
class VerifyResetCodeUseCase {
  final AuthRepository repository;
  VerifyResetCodeUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String email,
    required String code,
  }) =>
      repository.verifyResetCode(email: email, code: code);
}
