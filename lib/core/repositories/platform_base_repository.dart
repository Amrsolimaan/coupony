import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import '../errors/failures.dart';

/// Base repository for platform-dependent features (permissions, sensors, camera, etc.)
/// 
/// This is DIFFERENT from BaseRepository which handles network/cache strategies.
/// Platform repositories interact with device APIs (location, notifications, camera)
/// that don't require network connectivity or offline-first caching.
/// 
/// Key Differences:
/// - BaseRepository: API calls → Cache → Offline fallback
/// - PlatformBaseRepository: Platform APIs → Local Storage → No network needed
/// 
/// Use this for:
/// - Permission management (location, notifications, camera, etc.)
/// - Sensor access (accelerometer, gyroscope, etc.)
/// - Device features (biometrics, NFC, Bluetooth, etc.)
abstract class PlatformBaseRepository {
  final Logger logger;

  PlatformBaseRepository({required this.logger});

  /// Execute a platform operation (location, notification, sensor, etc.) with error handling
  /// 
  /// This wraps platform API calls in try-catch and provides consistent error handling.
  /// 
  /// [operation] - The platform API call to execute
  /// [operationName] - Human-readable name for logging (e.g., "check location permission")
  /// 
  /// Returns `Either<Failure, T>`:
  /// - `Right(T)` on success
  /// - `Left(Failure)` on error (with proper failure type)
  /// 
  /// Example:
  /// ```dart
  /// return executePlatformOperation(
  ///   operation: () => locationService.checkPermissionStatus(),
  ///   operationName: 'check location permission',
  /// );
  /// ```
  Future<Either<Failure, T>> executePlatformOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      logger.e('Error in $operationName: $e');
      return Left(_handlePlatformError(e, operationName));
    }
  }

  /// Execute a storage operation with error handling
  /// 
  /// This wraps local storage operations (Hive, SharedPreferences, etc.)
  /// that already return `Either<Failure, T>`.
  /// 
  /// [operation] - The storage operation to execute (already returns Either)
  /// [operationName] - Human-readable name for logging (e.g., "save permission status")
  /// 
  /// Returns `Either<Failure, T>`:
  /// - Forwards the Either from the operation
  /// - Catches any unexpected errors and wraps them in CacheFailure
  /// 
  /// Example:
  /// ```dart
  /// return executeStorageOperation(
  ///   operation: () => localDataSource.getPermissionStatus(),
  ///   operationName: 'get permission status',
  /// );
  /// ```
  Future<Either<Failure, T>> executeStorageOperation<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String operationName,
  }) async {
    try {
      return await operation();
    } catch (e) {
      logger.e('Error in $operationName: $e');
      return Left(CacheFailure('Failed to $operationName: ${e.toString()}'));
    }
  }

  /// Centralized error handling for platform operations
  /// 
  /// Maps platform-specific errors to appropriate Failure types:
  /// - CacheFailure → CacheFailure (preserve type)
  /// - ValidationFailure → ValidationFailure (preserve type)
  /// - Errors containing "permission" → ValidationFailure
  /// - Errors containing "service" → ValidationFailure
  /// - Everything else → UnexpectedFailure
  /// 
  /// This ensures consistent error types across all platform repositories.
  Failure _handlePlatformError(dynamic error, String context) {
    // Preserve existing failure types
    if (error is CacheFailure) return error;
    if (error is ValidationFailure) return error;

    // Convert error to string for pattern matching
    final errorString = error.toString().toLowerCase();

    // Platform-specific error patterns
    if (errorString.contains('permission')) {
      return ValidationFailure('Permission denied: $context');
    }
    if (errorString.contains('service')) {
      return ValidationFailure('Service unavailable: $context');
    }
    if (errorString.contains('denied')) {
      return ValidationFailure('Access denied: $context');
    }

    // Default to unexpected failure
    return UnexpectedFailure('Failed to $context: ${error.toString()}');
  }
}
