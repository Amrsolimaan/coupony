import 'package:coupon/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, UserEntity>> login(String email, String password);

  /// Register a new user or merchant
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  });

  /// Check if user is logged in
  Future<Either<Failure, bool>> checkAuthStatus();

  /// Logout
  Future<Either<Failure, Unit>> logout();
}
