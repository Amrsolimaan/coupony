import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPORT REPOSITORY (DOMAIN)
// 
// Abstract interface for submitting problem reports.
// Defines the contract that the data layer must implement.
// ─────────────────────────────────────────────────────────────────────────────

abstract class ReportRepository {
  /// Submit customer report
  /// 
  /// Returns Either:
  /// - Left(Failure): If submission fails
  /// - Right(String): Success message from server
  Future<Either<Failure, String>> submitCustomerReport({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  });

  /// Submit seller report
  /// 
  /// Returns Either:
  /// - Left(Failure): If submission fails
  /// - Right(String): Success message from server
  Future<Either<Failure, String>> submitSellerReport({
    required String name,
    required String email,
    required String phone,
    required String company,
    required String message,
  });
}
