import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  });

  /// Send OTP to phone number
  Future<Either<Failure, Unit>> sendOtp(String phone);

  /// Verify OTP — returns authenticated UserEntity on success
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String otp,
  });

  /// Refresh access token using stored refresh token
  Future<Either<Failure, UserEntity>> refreshToken();

  /// Returns true if a valid auth token is stored locally
  Future<Either<Failure, bool>> checkAuthStatus();

  Future<Either<Failure, Unit>> logout();
}
