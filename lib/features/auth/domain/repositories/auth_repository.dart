import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/password_reset_response_model.dart';
import '../entities/user_entity.dart';
import '../use_cases/reset_password_params.dart';

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
    required String role,
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

  /// POST /auth/otp/verify (purpose: reset_password) — validates the code
  /// server-side. The raw OTP code is used as reset_token for /password/reset.
  Future<Either<Failure, Unit>> verifyResetCode({
    required String email,
    required String code,
  });

  // ── Password Reset ─────────────────────────────────────────────────────────

  /// POST /auth/password/forgot — sends reset OTP to email.
  /// Always returns success to prevent account enumeration.
  Future<Either<Failure, PasswordResetResponseModel>> sendResetCode(String email);

  /// POST /auth/password/resend-otp — resends the reset OTP.
  /// Always returns success to prevent account enumeration.
  Future<Either<Failure, PasswordResetResponseModel>> resendResetCode(String email);

  /// POST /auth/password/reset — resets the password using the OTP token.
  Future<Either<Failure, Unit>> resetPassword(ResetPasswordParams params);
}