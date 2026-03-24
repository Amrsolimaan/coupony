import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// POST /auth/login
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required String role,
  });

  /// POST /auth/register
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
  });

  /// POST /auth/otp/send
  Future<Either<Failure, Unit>> sendOtp(String email);

  /// POST /auth/otp/verify — returns authenticated UserEntity on success
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String email,
    required String code,
  });

  /// POST /auth/refresh — uses stored refresh_token
  Future<Either<Failure, UserEntity>> refreshToken();

  /// Returns true if a valid access_token is stored locally
  Future<Either<Failure, bool>> checkAuthStatus();

  Future<Either<Failure, Unit>> logout();
}
