import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/storage_keys.dart';
import '../../constants/api_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AUTH INTERCEPTOR WITH AUTO TOKEN REFRESH
// ─────────────────────────────────────────────────────────────────────────────

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final Dio dio;

  // Prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;
  final List<_RequestRetry> _requestsQueue = [];

  AuthInterceptor({
    required this.secureStorage,
    required this.dio,
  });

  // ── Attach access token to outgoing requests ─────────────────────────────
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.read(key: StorageKeys.authToken);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  // ── Handle 401 errors with automatic token refresh ───────────────────────
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't try to refresh the refresh endpoint itself (infinite loop)
    if (err.requestOptions.path.contains(ApiConstants.refreshToken)) {
      await _clearAuthAndLogout();
      return handler.next(err);
    }

    // Don't try to refresh for change-password — 401 here means wrong
    // current password, NOT an expired token. Pass it through as-is.
    if (err.requestOptions.path.contains(ApiConstants.changePassword)) {
      return handler.next(err);
    }

    // If already refreshing, queue this request
    if (_isRefreshing) {
      return _queueRequest(err.requestOptions, handler);
    }

    // Try to refresh the token
    _isRefreshing = true;

    try {
      final refreshToken = await secureStorage.read(
        key: StorageKeys.refreshToken,
      );

      // No refresh token available — logout
      if (refreshToken == null || refreshToken.isEmpty) {
        await _clearAuthAndLogout();
        return handler.reject(err);
      }

      // Call refresh endpoint
      final response = await _refreshAccessToken(refreshToken);

      // Extract new tokens from response
      // Handle both formats: direct or nested in 'data'
      final responseData = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final dataNode = responseData['data'] as Map<String, dynamic>?;
      final tokensSource = dataNode ?? responseData;

      final newAccessToken = tokensSource['access_token'] as String?;
      final newRefreshToken = tokensSource['refresh_token'] as String?;

      if (newAccessToken == null) {
        throw Exception('No access_token in refresh response');
      }

      // Save new tokens
      await secureStorage.write(
        key: StorageKeys.authToken,
        value: newAccessToken,
      );

      if (newRefreshToken != null) {
        await secureStorage.write(
          key: StorageKeys.refreshToken,
          value: newRefreshToken,
        );
      }

      // Retry the original failed request with new token
      final retryResponse = await _retryRequest(
        err.requestOptions,
        newAccessToken,
      );

      // Process queued requests
      await _processQueue(newAccessToken);

      return handler.resolve(retryResponse);
    } catch (e) {
      // Refresh failed — clear auth and logout
      await _clearAuthAndLogout();
      
      // Reject all queued requests
      _rejectQueue(err);
      
      return handler.reject(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ── Call refresh token endpoint ──────────────────────────────────────────
  Future<Response> _refreshAccessToken(String refreshToken) async {
    // Create a new Dio instance without interceptors to avoid loops
    final refreshDio = Dio(dio.options);

    return await refreshDio.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );
  }

  // ── Retry failed request with new token ──────────────────────────────────
  Future<Response> _retryRequest(
    RequestOptions options,
    String newToken,
  ) async {
    final retryOptions = Options(
      method: options.method,
      headers: {
        ...options.headers,
        'Authorization': 'Bearer $newToken',
      },
    );

    return await dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: retryOptions,
    );
  }

  // ── Queue request while refresh is in progress ───────────────────────────
  Future<void> _queueRequest(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    _requestsQueue.add(_RequestRetry(options, handler));
  }

  // ── Process all queued requests after successful refresh ─────────────────
  Future<void> _processQueue(String newToken) async {
    for (final retry in _requestsQueue) {
      try {
        final response = await _retryRequest(retry.options, newToken);
        retry.handler.resolve(response);
      } catch (e) {
        retry.handler.reject(
          DioException(
            requestOptions: retry.options,
            error: e,
          ),
        );
      }
    }
    _requestsQueue.clear();
  }

  // ── Reject all queued requests ───────────────────────────────────────────
  void _rejectQueue(DioException originalError) {
    for (final retry in _requestsQueue) {
      retry.handler.reject(
        DioException(
          requestOptions: retry.options,
          error: originalError.error,
          response: originalError.response,
        ),
      );
    }
    _requestsQueue.clear();
  }

  // ── Clear all auth data ──────────────────────────────────────────────────
  Future<void> _clearAuthAndLogout() async {
    await secureStorage.delete(key: StorageKeys.authToken);
    await secureStorage.delete(key: StorageKeys.refreshToken);
    await secureStorage.delete(key: StorageKeys.userId);
    await secureStorage.delete(key: StorageKeys.userRole);
    await secureStorage.delete(key: StorageKeys.fcmToken);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER CLASS FOR QUEUED REQUESTS
// ─────────────────────────────────────────────────────────────────────────────

class _RequestRetry {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _RequestRetry(this.options, this.handler);
}
