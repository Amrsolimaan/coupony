import 'package:equatable/equatable.dart';

/// Parameters for POST /auth/password/reset
class ResetPasswordParams extends Equatable {
  final String email;
  final String token;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordParams({
    required this.email,
    required this.token,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [email, token, password, passwordConfirmation];
}
