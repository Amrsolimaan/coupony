import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/report_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SUBMIT SELLER REPORT USE CASE
// 
// Business logic for submitting seller problem reports.
// Encapsulates the repository call with typed parameters.
// ─────────────────────────────────────────────────────────────────────────────

class SubmitSellerReportUseCase {
  final ReportRepository repository;

  SubmitSellerReportUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String name,
    required String email,
    required String phone,
    required String company,
    required String message,
  }) {
    return repository.submitSellerReport(
      name: name,
      email: email,
      phone: phone,
      company: company,
      message: message,
    );
  }
}
