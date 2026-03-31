import 'package:dartz/dartz.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../network/network_info.dart';
import '../storage/local_cache_service.dart';

/// Base repository implementing offline-first strategy
/// All feature repositories should extend this
abstract class BaseRepository {
  final NetworkInfo networkInfo;
  final LocalCacheService cacheService;

  BaseRepository({required this.networkInfo, required this.cacheService});

  /// Generic method for online/offline data fetching
  ///
  /// [remoteCall] - Function to fetch from API
  /// [localCall] - Function to fetch from cache
  /// [cacheCall] - Function to save fetched data to cache
  /// [shouldCache] - Whether to cache the remote response (default: true)
  /// [cacheValidation] - Optional function to validate cached data freshness
  Future<Either<Failure, T>> fetchWithCacheStrategy<T>({
    required Future<T> Function() remoteCall,
    required Future<T> Function() localCall,
    required Future<void> Function(T data) cacheCall,
    bool shouldCache = true,
    Future<bool> Function()? cacheValidation,
  }) async {
    try {
      // Check connectivity
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        // ONLINE: Fetch from API
        try {
          final remoteData = await remoteCall();

          // Cache the fresh data
          if (shouldCache) {
            await cacheCall(remoteData);
          }

          return Right(remoteData);
        } catch (e) {
          // API failed, fallback to cache
          return _fetchFromCache(localCall);
        }
      } else {
        // OFFLINE: Fetch from cache
        return _fetchFromCache(localCall);
      }
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Enhanced cache strategy using LocalCacheService
  ///
  /// This is an ALTERNATIVE to the manual fetchWithCacheStrategy
  /// Use this when you want automatic TTL, quota management, and background updates
  ///
  /// [remoteCall] - Function to fetch from API
  /// [cacheKey] - Unique key for this data
  /// [boxName] - Hive box name
  /// [cacheTTL] - How long cache is valid
  /// [forceRefresh] - Skip cache and fetch fresh data
  Future<Either<Failure, T>> fetchWithAutoCache<T>({
    required Future<T> Function() remoteCall,
    required String cacheKey,
    required String boxName,
    Duration? cacheTTL,
    bool forceRefresh = false,
  }) async {
    try {
      // Check connectivity
      final isConnected = await networkInfo.isConnected;

      // STRATEGY 1: Force refresh requested (skip cache)
      if (forceRefresh && isConnected) {
        return await _fetchFromRemoteAndCache(
          remoteCall: remoteCall,
          cacheKey: cacheKey,
          boxName: boxName,
        );
      }

      // STRATEGY 2: Try cache first (offline-first)
      final cachedData = await cacheService.get<T>(
        boxName: boxName,
        key: cacheKey,
        maxAge: cacheTTL,
      );

      if (cachedData != null) {
        // Cache hit! Return immediately

        // If online, update cache in background (no await)
        if (isConnected) {
          _updateCacheInBackground(
            remoteCall: remoteCall,
            cacheKey: cacheKey,
            boxName: boxName,
          );
        }

        return Right(cachedData);
      }

      // STRATEGY 3: Cache miss - fetch from API if online
      if (isConnected) {
        return await _fetchFromRemoteAndCache(
          remoteCall: remoteCall,
          cacheKey: cacheKey,
          boxName: boxName,
        );
      }

      // STRATEGY 4: Offline + no cache = failure
      return const Left(NetworkFailure('No internet and no cached data'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Fetch from API and update cache
  Future<Either<Failure, T>> _fetchFromRemoteAndCache<T>({
    required Future<T> Function() remoteCall,
    required String cacheKey,
    required String boxName,
  }) async {
    try {
      final remoteData = await remoteCall();

      // Update cache
      await cacheService.put<T>(
        boxName: boxName,
        key: cacheKey,
        value: remoteData,
      );

      return Right(remoteData);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Update cache in background (fire and forget)
  void _updateCacheInBackground<T>({
    required Future<T> Function() remoteCall,
    required String cacheKey,
    required String boxName,
  }) {
    remoteCall()
        .then((data) {
          cacheService.put<T>(boxName: boxName, key: cacheKey, value: data);
        })
        .catchError((e) {
          // Silent fail - cache update is best effort
        });
  }

  /// Helper to fetch from local cache with error handling
  Future<Either<Failure, T>> _fetchFromCache<T>(
    Future<T> Function() localCall,
  ) async {
    try {
      final cachedData = await localCall();
      return Right(cachedData);
    } catch (e) {
      return Left(CacheFailure('No cached data available'));
    }
  }

  /// For write operations (POST/PUT/DELETE)
  /// Only executes when online
  Future<Either<Failure, T>> executeOnlineOperation<T>({
    required Future<T> Function() operation,
    Future<void> Function()? onSuccess,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return const Left(NetworkFailure('error_no_internet'));
      }

      final result = await operation();

      if (onSuccess != null) {
        await onSuccess();
      }

      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Clear cache for specific feature
  Future<void> clearFeatureCache(String boxName) async {
    await cacheService.clearBox(boxName);
  }

  /// Centralized error handling
  Failure _handleError(dynamic error) {
    // Failure types (already mapped)
    if (error is ServerFailure) return error;
    if (error is NetworkFailure) return error;
    if (error is CacheFailure) return error;
    if (error is UnauthorizedFailure) return error;
    if (error is ValidationFailure) return error;

    // Exception types thrown by the error interceptor
    if (error is ValidationException) return ValidationFailure(error.message);
    if (error is InvalidTokenException) return InvalidTokenFailure(error.message);
    if (error is UnauthorizedException) return UnauthorizedFailure(error.message);
    if (error is ServerException) return ServerFailure(error.message);
    if (error is NetworkException) return NetworkFailure(error.message);
    if (error is CacheException) return CacheFailure(error.message);

    return UnexpectedFailure(error.toString());
  }
}
