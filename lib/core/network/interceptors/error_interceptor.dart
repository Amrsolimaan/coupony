import 'package:dio/dio.dart';
import '../../errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Exception exception;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = const ServerException('Connection timed out');
        break;
      
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        final message = (data is Map ? data['message'] : null) ?? 'Unknown error';

        if (statusCode == 401) {
          exception = const UnauthorizedException('Unauthorized access');
        } else if (statusCode == 404) {
          exception = const NotFoundException('Resource not found');
        } else if (statusCode == 422) {
          // Handle validation errors - extract all error messages
          final validationMessage = _extractValidationErrors(data);
          exception = ValidationException(validationMessage);
        } else if (statusCode != null && statusCode >= 500) {
          exception = const ServerException('Internal server error');
        } else {
          exception = ServerException(message);
        }
        break;
      
      case DioExceptionType.cancel:
        exception = const ServerException('Request cancelled');
        break;
      
      case DioExceptionType.connectionError:
        exception = const ServerException('error_no_internet_check_network');
        break;
      
      case DioExceptionType.unknown:
        // SSL certificate issues, network problems, or DNS failures
        if (err.message?.contains('HandshakeException') ?? false) {
          exception = const ServerException('SSL certificate error. Please check server configuration.');
        } else if (err.message?.contains('SocketException') ?? false) {
          exception = const ServerException('Cannot connect to server. Please check your internet connection.');
        } else {
          final unknownMsg = err.message;
          if (unknownMsg == null || unknownMsg.isEmpty) {
            exception = const ServerException('Cannot connect to server. Please check your internet connection.');
          } else {
            exception = ServerException('Network error: $unknownMsg');
          }
        }
        break;
      
      default:
        exception = const ServerException('Unexpected error occurred');
    }
    
    // Reject with the exception instead of throwing it
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  /// Extracts all validation error messages from the response data
  /// and combines them into a single localized message.
  /// 
  /// This removes the English "(and X more error)" text that Laravel adds
  /// and shows all errors in the user's language.
  String _extractValidationErrors(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return data.toString();
    }

    // Try to get the errors object
    final errors = data['errors'];
    if (errors is Map<String, dynamic> && errors.isNotEmpty) {
      // Collect all error messages from all fields
      final List<String> allErrors = [];
      
      for (final fieldErrors in errors.values) {
        if (fieldErrors is List) {
          for (final error in fieldErrors) {
            if (error is String && error.isNotEmpty) {
              allErrors.add(error);
            }
          }
        }
      }
      
      // If we have multiple errors, join them with newlines
      if (allErrors.isNotEmpty) {
        return allErrors.join('\n');
      }
    }
    
    // Fallback to the message field if no errors object
    return data['message'] as String? ?? 'Validation error';
  }
}
