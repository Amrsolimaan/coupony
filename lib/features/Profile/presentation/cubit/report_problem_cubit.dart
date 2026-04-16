import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../domain/use_cases/submit_customer_report_use_case.dart';
import '../../domain/use_cases/submit_seller_report_use_case.dart';
import 'report_problem_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPORT PROBLEM CUBIT
// 
// Manages the state of problem report submission.
// Handles both customer and seller report submissions based on user role.
// ─────────────────────────────────────────────────────────────────────────────

class ReportProblemCubit extends Cubit<ReportProblemState> {
  final SubmitCustomerReportUseCase submitCustomerReportUseCase;
  final SubmitSellerReportUseCase submitSellerReportUseCase;
  final Logger logger;

  ReportProblemCubit({
    required this.submitCustomerReportUseCase,
    required this.submitSellerReportUseCase,
    required this.logger,
  }) : super(const ReportProblemInitial());

  // ── Submit Customer Report ─────────────────────────────────────────────────
  /// Submits a customer problem report
  /// 
  /// Parameters:
  /// - name: Customer full name
  /// - email: Customer email
  /// - phone: Customer phone number
  /// - subject: Report subject/title
  /// - message: Detailed problem description
  Future<void> submitCustomerReport({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) async {
    logger.i('📤 ReportProblemCubit.submitCustomerReport');
    logger.d('Customer: $name, Email: $email, Subject: $subject');

    emit(const ReportProblemLoading());

    final result = await submitCustomerReportUseCase(
      name: name,
      email: email,
      phone: phone,
      subject: subject,
      message: message,
    );

    result.fold(
      (failure) {
        logger.e('❌ Customer report failed: ${failure.message}');
        emit(ReportProblemError(failure.message));
      },
      (serverMessage) {
        logger.i('✅ Customer report submitted: $serverMessage');
        emit(ReportProblemSuccess(serverMessage));
      },
    );
  }

  // ── Submit Seller Report ───────────────────────────────────────────────────
  /// Submits a seller problem report
  /// 
  /// Parameters:
  /// - name: Seller full name
  /// - email: Seller email
  /// - phone: Seller phone number
  /// - company: Store/company name
  /// - message: Detailed problem description
  Future<void> submitSellerReport({
    required String name,
    required String email,
    required String phone,
    required String company,
    required String message,
  }) async {
    logger.i('📤 ReportProblemCubit.submitSellerReport');
    logger.d('Seller: $name, Email: $email, Company: $company');

    emit(const ReportProblemLoading());

    final result = await submitSellerReportUseCase(
      name: name,
      email: email,
      phone: phone,
      company: company,
      message: message,
    );

    result.fold(
      (failure) {
        logger.e('❌ Seller report failed: ${failure.message}');
        emit(ReportProblemError(failure.message));
      },
      (serverMessage) {
        logger.i('✅ Seller report submitted: $serverMessage');
        emit(ReportProblemSuccess(serverMessage));
      },
    );
  }

  // ── Reset State ────────────────────────────────────────────────────────────
  /// Resets the state back to initial
  /// Useful for clearing success/error messages
  void reset() {
    logger.d('🔄 ReportProblemCubit.reset');
    emit(const ReportProblemInitial());
  }
}
