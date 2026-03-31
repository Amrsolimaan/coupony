# Accept-Language Header Implementation

## Problem
The backend sends localized error messages based on the `Accept-Language` HTTP header, but the app wasn't sending this header. This caused validation errors to always appear in English, even when the app was set to Arabic.

## Solution
Implemented a clean, centralized solution using the interceptor pattern.

## Implementation Details

### 1. Created LocaleInterceptor
**File**: `lib/core/network/interceptors/locale_interceptor.dart`

A dedicated Dio interceptor that:
- Reads the current locale from `LocaleCubit`
- Adds the `Accept-Language` header to every outgoing request
- Follows the same pattern as existing interceptors (AuthInterceptor, ErrorInterceptor)

```dart
class LocaleInterceptor extends Interceptor {
  final LocaleCubit localeCubit;

  LocaleInterceptor(this.localeCubit);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final languageCode = localeCubit.state.languageCode;
    options.headers['Accept-Language'] = languageCode;
    handler.next(options);
  }
}
```

### 2. Updated DioClient
**File**: `lib/core/network/dio_client.dart`

- Added `LocaleCubit` as a constructor parameter
- Registered `LocaleInterceptor` in the interceptor chain (first position)

### 3. Updated Dependency Injection
**File**: `lib/config/dependency_injection/injection_container.dart`

- Moved `LocaleCubit` registration before `DioClient` (dependency order)
- Updated `DioClient` instantiation to pass `LocaleCubit`

## Benefits

✅ **Zero Code Duplication**: Locale header is added automatically to ALL requests
✅ **Clean Architecture**: Solution stays in the network layer
✅ **Single Responsibility**: One interceptor handles one concern
✅ **No Repository Changes**: Existing code continues to work without modification
✅ **Automatic**: Works for all features (auth, stores, coupons, etc.)
✅ **Easy to Test**: Interceptor can be tested independently
✅ **Easy to Maintain**: If backend changes locale handling, only one file needs updating

## How It Works

1. User changes app language → `LocaleCubit` updates its state
2. App makes any API request → `LocaleInterceptor` runs first
3. Interceptor reads current locale from `LocaleCubit.state.languageCode`
4. Interceptor adds `Accept-Language: ar` or `Accept-Language: en` header
5. Backend receives the header and returns localized error messages
6. Existing validation error handling displays the backend message as-is

## Testing

To verify it's working:

1. Set app language to Arabic
2. Try to login with invalid credentials (e.g., short password)
3. Backend should return Arabic error message
4. App should display: "يرجى إدخال بريد إلكتروني صالح" (or similar)

Check the network logs to confirm the header is being sent:
```
Accept-Language: ar
```

## Files Modified

- ✨ **Created**: `lib/core/network/interceptors/locale_interceptor.dart`
- 🔧 **Modified**: `lib/core/network/dio_client.dart`
- 🔧 **Modified**: `lib/config/dependency_injection/injection_container.dart`

## Architecture Compliance

This solution follows Clean Architecture principles:
- **Network Layer**: Interceptor lives in the network layer where it belongs
- **Dependency Injection**: Proper dependency management through GetIt
- **Single Responsibility**: Each class has one clear purpose
- **Open/Closed**: Can add more interceptors without modifying existing code
