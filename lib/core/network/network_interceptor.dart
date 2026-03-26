import 'package:dio/dio.dart';

import 'network_monitor.dart';
import 'network_thresholds.dart';

/// Dio interceptor that automatically measures every request's elapsed time
/// and forwards the result to [NetworkMonitor].
///
/// Add it to DioClient **after** auth/error interceptors so it sees all
/// completed requests — including those that ultimately succeed after a retry.
///
/// ```dart
/// _dio.interceptors.add(NetworkMonitorInterceptor());
/// ```
class NetworkMonitorInterceptor extends Interceptor {
  static const _kStartTimeKey = '_nm_start_ms';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Stamp the start time into the request's extra map so it survives
    // through the response/error callbacks.
    options.extra[_kStartTimeKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _record(
      options: response.requestOptions,
      responseHeaders: response.headers,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isTimeout = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    if (isTimeout) {
      NetworkMonitor.instance.recordTimeout(
        requestType: _resolveType(err.requestOptions),
      );
    } else {
      // Non-timeout errors (404, 500, etc.) still carry timing information
      // that is useful for moving-average calculations.
      _record(options: err.requestOptions);
    }
    handler.next(err);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _record({
    required RequestOptions options,
    Headers? responseHeaders,
  }) {
    final startMs = options.extra[_kStartTimeKey] as int?;
    if (startMs == null) return;

    final elapsed = DateTime.now().millisecondsSinceEpoch - startMs;
    final type = _resolveType(options);

    // Try to read Content-Length so upload/download thresholds can be
    // adjusted proportionally for large payloads.
    int? sizeBytes;
    final contentLength = responseHeaders?.value('content-length');
    if (contentLength != null) sizeBytes = int.tryParse(contentLength);

    NetworkMonitor.instance.recordRequest(
      responseTimeMs: elapsed,
      requestType: type,
      requestSizeBytes: sizeBytes,
    );
  }

  /// Infers [RequestType] from the request path and HTTP method.
  RequestType _resolveType(RequestOptions options) {
    final path = options.path.toLowerCase();
    final method = options.method.toUpperCase();

    if (path.contains('/auth/')) return RequestType.auth;

    // Multipart body → upload
    if ((method == 'POST' || method == 'PUT') && options.data is FormData) {
      return RequestType.upload;
    }

    // Download paths
    if (method == 'GET' &&
        (path.contains('/download') ||
            path.contains('/media') ||
            path.contains('/file'))) {
      return RequestType.download;
    }

    return RequestType.api;
  }
}
