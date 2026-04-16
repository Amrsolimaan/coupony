import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/report_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SUBMIT CUSTOMER REPORT USE CASE
// 
// Business logic for submitting customer problem reports.
// Encapsulates the repository call with typed parameters.
// ─────────────────────────────────────────────────────────────────────────────

class SubmitCustomerReportUseCase {
  final ReportRepository repository;

  SubmitCustomerReportUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) {
    return repository.submitCustomerReport(
      name: name,
      email: email,
      phone: phone,
      subject: subject,
      message: message,
    );
  }
}
