import 'package:dio/dio.dart';
import '../../errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const ServerException('Connection timed out');
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = err.response?.data['message'] ?? 'Unknown error';

        if (statusCode == 401) {
          throw const UnauthorizedException('Unauthorized access');
        } else if (statusCode == 404) {
          throw const NotFoundException('Resource not found');
        } else if (statusCode != null && statusCode >= 500) {
          throw const ServerException('Internal server error');
        }
        throw ServerException(message);
      case DioExceptionType.cancel:
        throw const ServerException('Request cancelled');
      default:
        throw const ServerException('Unexpected error occurred');
    }
  }
}
