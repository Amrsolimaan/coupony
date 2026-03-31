import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../localization/locale_cubit.dart';

/// Interceptor that adds the Accept-Language header to all requests
/// based on the current app locale from LocaleCubit.
///
/// This ensures the backend returns localized error messages and content
/// in the user's preferred language.
class LocaleInterceptor extends Interceptor {
  final LocaleCubit localeCubit;
  final Logger _logger = Logger();

  LocaleInterceptor(this.localeCubit);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get current locale from LocaleCubit
    final languageCode = localeCubit.state.languageCode;
    
    // Add Accept-Language header
    options.headers['Accept-Language'] = languageCode;
    
    _logger.i('🌍 LocaleInterceptor: Added Accept-Language: $languageCode to ${options.path}');
    
    handler.next(options);
  }
}
