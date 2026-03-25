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
        exception = const ServerException('No internet connection. Please check your network.');
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
}
