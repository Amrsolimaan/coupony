import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

/// Maps to HTTP 422 — invalid or expired password-reset token.
class InvalidTokenFailure extends Failure {
  const InvalidTokenFailure(super.message);
}

/// Returned by [AuthRepository.googleSignIn] when the account exists but the
/// email has not been verified yet.  The cubit should navigate to the OTP
/// screen and pass [email] / [password] so verification can proceed.
class OtpRequiredFailure extends Failure {
  final String email;
  final String password;

  const OtpRequiredFailure({required this.email, required this.password})
      : super('Account requires OTP verification');

  @override
  List<Object> get props => [message, email, password];
}
