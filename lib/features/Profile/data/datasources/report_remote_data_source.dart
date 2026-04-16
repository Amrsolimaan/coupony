import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPORT REMOTE DATA SOURCE
// 
// Handles API calls for submitting problem reports / contact-us messages.
// Supports both customer and seller endpoints with role-specific data.
// ─────────────────────────────────────────────────────────────────────────────

abstract class ReportRemoteDataSource {
  /// POST /contact-us/customer — Submit customer report
  /// 
  /// Required fields:
  /// - name: Customer full name
  /// - email: Customer email
  /// - phone: Customer phone number
  /// - subject: Report subject/title
  /// - message: Detailed problem description
  Future<String> submitCustomerReport({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  });

  /// POST /contact-us/seller — Submit seller report
  /// 
  /// Required fields:
  /// - name: Seller full name
  /// - email: Seller email
  /// - phone: Seller phone number
  /// - company: Store/company name
  /// - message: Detailed problem description
  Future<String> submitSellerReport({
    required String name,
    required String email,
    required String phone,
    required String company,
    required String message,
  });
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final DioClient client;
  final Logger logger;

  ReportRemoteDataSourceImpl({
    required this.client,
    required this.logger,
  });

  // ── Submit Customer Report ─────────────────────────────────────────────────
  @override
  Future<String> submitCustomerReport({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) async {
    try {
      logger.i('📤 SUBMIT CUSTOMER REPORT — ${ApiConstants.contactUsCustomer}');
      logger.d('Request body: {name: $name, email: $email, phone: $phone, subject: $subject}');

      final response = await client.post(
        ApiConstants.contactUsCustomer,
        data: {
          'name': name,
          'email': email,
          'phone_number': phone,
          'subject': subject,
          'message': message,
        },
      );

      // Extract success message from server response
      final serverMessage = response.data['message'] as String? ?? 
                           'Report submitted successfully';
      
      logger.i('✅ CUSTOMER REPORT SUBMITTED — $serverMessage');
      return serverMessage;
    } on DioException catch (e) {
      logger.e('❌ SUBMIT CUSTOMER REPORT ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ SUBMIT CUSTOMER REPORT UNEXPECTED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  // ── Submit Seller Report ───────────────────────────────────────────────────
  @override
  Future<String> submitSellerReport({
    required String name,
    required String email,
    required String phone,
    required String company,
    required String message,
  }) async {
    try {
      logger.i('📤 SUBMIT SELLER REPORT — ${ApiConstants.contactUsSeller}');
      logger.d('Request body: {name: $name, email: $email, phone: $phone, company: $company}');

      final response = await client.post(
        ApiConstants.contactUsSeller,
        data: {
          'name': name,
          'email': email,
          'phone_number': phone,
          'company': company,
          'message': message,
        },
      );

      // Extract success message from server response
      final serverMessage = response.data['message'] as String? ?? 
                           'Report submitted successfully';
      
      logger.i('✅ SELLER REPORT SUBMITTED — $serverMessage');
      return serverMessage;
    } on DioException catch (e) {
      logger.e('❌ SUBMIT SELLER REPORT ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ SUBMIT SELLER REPORT UNEXPECTED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  // ── Private Helper: Rethrow Exceptions ─────────────────────────────────────
  Never _rethrow(DioException e) {
    if (e.error is ValidationException)   throw e.error as ValidationException;
    if (e.error is UnauthorizedException) throw e.error as UnauthorizedException;
    if (e.error is NotFoundException)     throw e.error as NotFoundException;
    if (e.error is ServerException)       throw e.error as ServerException;

    final data    = e.response?.data;
    final message = (data is Map<String, dynamic>)
        ? data['message'] as String? ?? e.message ?? 'Network error'
        : e.message ?? 'Network error';

    throw ServerException(message);
  }
}
