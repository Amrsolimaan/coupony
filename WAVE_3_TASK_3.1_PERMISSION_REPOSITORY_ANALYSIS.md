# 📊 WAVE 3 - Task 3.1: PermissionRepositoryImpl Analysis

## 🎯 Objective
Analyze `PermissionRepositoryImpl` to understand current error handling patterns and propose alignment with core infrastructure (`BaseRepository`).

**Status**: ✅ ANALYSIS COMPLETE

**Date**: March 21, 2026

---

## 📁 Target File
`lib/features/permissions/data/repositories/permission_repository_impl.dart`

---

## 🔍 CURRENT STATE ANALYSIS

### 1. Class Structure

```dart
class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionLocalDataSource localDataSource;
  final LocationService locationService;
  final NotificationService notificationService;
  final Logger logger;
}
```

**Findings:**
- ❌ Does NOT extend `BaseRepository`
- ✅ Implements domain interface `PermissionRepository`
- ✅ Dependencies injected via constructor (testable)
- ✅ Uses Logger (no print statements)

---

### 2. Error Handling Pattern Analysis

#### Current Pattern: Manual Try-Catch in Every Method

**Example 1: Location Permission Check**
```dart
@override
Future<Either<Failure, LocationPermissionStatus>> checkLocationPermission() async {
  try {
    final status = await locationService.checkPermissionStatus();
    return Right(status);
  } catch (e) {
    logger.e('Error checking location permission: $e');
    return Left(UnexpectedFailure('Failed to check location permission'));
  }
}
```

**Example 2: Get Current Position**
```dart
@override
Future<Either<Failure, Position>> getCurrentPosition() async {
  try {
    final position = await locationService.getCurrentPosition();
    
    if (position == null) {
      return Left(ValidationFailure('Location permission not granted or position unavailable'));
    }
    
    // Save position to local storage
    await _updateLocalPermissionStatus(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    
    return Right(position);
  } catch (e) {
    logger.e('Error getting current position: $e');
    return Left(UnexpectedFailure('Failed to get current position'));
  }
}
```

**Example 3: Save Permission Status**
```dart
@override
Future<Either<Failure, void>> savePermissionStatus({...}) async {
  try {
    // Get existing status
    final existingResult = await localDataSource.getPermissionStatus();
    
    final existing = existingResult.fold(
      (_) => PermissionStatusModel.initial(),
      (model) => model ?? PermissionStatusModel.initial(),
    );
    
    // Create updated model
    final updated = existing.copyWith(...);
    
    // Save
    return await localDataSource.savePermissionStatus(updated);
  } catch (e) {
    logger.e('Error saving permission status: $e');
    return Left(CacheFailure('Failed to save permission status'));
  }
}
```

---

### 3. Error Handling Statistics

| Metric | Count |
|--------|-------|
| Total Methods | 13 |
| Methods with try-catch | 10 |
| Methods delegating to data source | 3 |
| Unique error messages | 10 |
| Logger.e() calls | 10 |

---

### 4. Current Error Handling Issues

#### ❌ Issue 1: Repetitive Boilerplate
Every method has identical try-catch structure:
```dart
try {
  // Business logic
  return Right(result);
} catch (e) {
  logger.e('Error message: $e');
  return Left(UnexpectedFailure('Error message'));
}
```

**Impact**: 
- Code duplication (10 identical try-catch blocks)
- Maintenance burden (changing error handling requires 10 edits)
- Inconsistent error messages

#### ❌ Issue 2: All Errors Become UnexpectedFailure
```dart
catch (e) {
  return Left(UnexpectedFailure('...')); // Loses error type information
}
```

**Impact**:
- Cannot differentiate between network errors, cache errors, validation errors
- UI cannot show specific error messages
- Harder to debug production issues

#### ❌ Issue 3: No Centralized Error Mapping
Each method manually maps exceptions to failures:
```dart
// Method 1
catch (e) { return Left(UnexpectedFailure('Failed to check location')); }

// Method 2
catch (e) { return Left(UnexpectedFailure('Failed to request location')); }

// Method 3
catch (e) { return Left(CacheFailure('Failed to save permission')); }
```

**Impact**:
- Inconsistent failure types for similar errors
- No reusable error handling logic

#### ❌ Issue 4: Missing BaseRepository Benefits
Not extending `BaseRepository` means missing:
- ✗ Offline-first cache strategy
- ✗ Automatic TTL management
- ✗ Background cache updates
- ✗ Centralized error handling
- ✗ Network connectivity checks

---

## 🏗️ BASEREPOSITORY CAPABILITIES

### Available Methods from BaseRepository

#### 1. `fetchWithCacheStrategy<T>`
**Use Case**: Manual control over cache logic
```dart
Future<Either<Failure, T>> fetchWithCacheStrategy<T>({
  required Future<T> Function() remoteCall,
  required Future<T> Function() localCall,
  required Future<void> Function(T data) cacheCall,
  bool shouldCache = true,
  Future<bool> Function()? cacheValidation,
})
```

**Benefits**:
- ✅ Automatic offline-first strategy
- ✅ Fallback to cache on API failure
- ✅ Centralized error handling

#### 2. `fetchWithAutoCache<T>`
**Use Case**: Automatic cache with TTL
```dart
Future<Either<Failure, T>> fetchWithAutoCache<T>({
  required Future<T> Function() remoteCall,
  required String cacheKey,
  required String boxName,
  Duration? cacheTTL,
  bool forceRefresh = false,
})
```

**Benefits**:
- ✅ TTL-based cache invalidation
- ✅ Background cache updates
- ✅ Quota management

#### 3. `executeOnlineOperation<T>`
**Use Case**: Write operations (POST/PUT/DELETE)
```dart
Future<Either<Failure, T>> executeOnlineOperation<T>({
  required Future<T> Function() operation,
  Future<void> Function()? onSuccess,
})
```

**Benefits**:
- ✅ Only executes when online
- ✅ Automatic network check
- ✅ Success callback support

#### 4. `_handleError(dynamic error)`
**Use Case**: Centralized error mapping
```dart
Failure _handleError(dynamic error) {
  if (error is ServerFailure) return error;
  if (error is NetworkFailure) return error;
  if (error is CacheFailure) return error;
  return UnexpectedFailure(error.toString());
}
```

**Benefits**:
- ✅ Consistent error type mapping
- ✅ Preserves specific failure types
- ✅ Single source of truth

---

## 🚫 WHY NOT USE BASEREPOSITORY?

### Critical Analysis: Permission Repository is DIFFERENT

#### Reason 1: No Remote API Calls
`PermissionRepositoryImpl` does NOT fetch data from a REST API:
- ✅ Calls platform services (LocationService, NotificationService)
- ✅ Stores data locally (Hive via LocalDataSource)
- ❌ NO HTTP requests
- ❌ NO network connectivity needed for core operations

**BaseRepository Assumption**: 
```dart
fetchWithCacheStrategy({
  required remoteCall,  // ❌ Assumes API call
  required localCall,   // ✅ Has this
  required cacheCall,   // ✅ Has this
})
```

**Permission Repository Reality**:
```dart
// No "remote" call - just platform APIs
final status = await locationService.checkPermissionStatus(); // Platform API
await localDataSource.savePermissionStatus(model);           // Local storage
```

#### Reason 2: Platform Services ≠ Network Services
```dart
// BaseRepository is designed for:
API → Cache → Offline fallback

// PermissionRepository needs:
Platform API → Local Storage → No fallback needed
```

#### Reason 3: No Offline-First Strategy Needed
Permissions are:
- ✅ Always available (platform APIs work offline)
- ✅ Don't need TTL (permissions don't expire)
- ✅ Don't need background updates (user-triggered only)
- ✅ Don't need network connectivity checks

---

## ✅ PROPOSED SOLUTION: HYBRID APPROACH

### Option A: Create PermissionBaseRepository (RECOMMENDED)

**Rationale**: 
- Permission repositories have unique needs (platform APIs, no network)
- Other features (Coupons, Products) will need BaseRepository
- Create a specialized base class for permission-like features

**Implementation**:
```dart
/// Base repository for platform-dependent features (permissions, sensors, etc.)
/// Does NOT extend BaseRepository (no network/cache strategy needed)
abstract class PlatformBaseRepository {
  final Logger logger;
  
  PlatformBaseRepository({required this.logger});
  
  /// Execute platform operation with error handling
  Future<Either<Failure, T>> executePlatformOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      logger.e('Error in $operationName: $e');
      return Left(_handleError(e, operationName));
    }
  }
  
  /// Execute storage operation with error handling
  Future<Either<Failure, T>> executeStorageOperation<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String operationName,
  }) async {
    try {
      return await operation();
    } catch (e) {
      logger.e('Error in $operationName: $e');
      return Left(CacheFailure('Failed to $operationName'));
    }
  }
  
  /// Centralized error handling for platform operations
  Failure _handleError(dynamic error, String context) {
    if (error is CacheFailure) return error;
    if (error is ValidationFailure) return error;
    
    // Platform-specific errors
    if (error.toString().contains('permission')) {
      return ValidationFailure('Permission denied: $context');
    }
    if (error.toString().contains('service')) {
      return ValidationFailure('Service unavailable: $context');
    }
    
    return UnexpectedFailure('Failed to $context: ${error.toString()}');
  }
}
```

**Usage**:
```dart
class PermissionRepositoryImpl extends PlatformBaseRepository 
    implements PermissionRepository {
  
  final PermissionLocalDataSource localDataSource;
  final LocationService locationService;
  final NotificationService notificationService;
  
  PermissionRepositoryImpl({
    required this.localDataSource,
    required this.locationService,
    required this.notificationService,
    required Logger logger,
  }) : super(logger: logger);
  
  @override
  Future<Either<Failure, LocationPermissionStatus>> checkLocationPermission() {
    return executePlatformOperation(
      operation: () => locationService.checkPermissionStatus(),
      operationName: 'check location permission',
    );
  }
  
  @override
  Future<Either<Failure, Position>> getCurrentPosition() async {
    return executePlatformOperation(
      operation: () async {
        final position = await locationService.getCurrentPosition();
        
        if (position == null) {
          throw ValidationFailure('Location permission not granted');
        }
        
        // Save position
        await _updateLocalPermissionStatus(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        
        return position;
      },
      operationName: 'get current position',
    );
  }
  
  @override
  Future<Either<Failure, void>> savePermissionStatus({...}) {
    return executeStorageOperation(
      operation: () async {
        final existingResult = await localDataSource.getPermissionStatus();
        
        final existing = existingResult.fold(
          (_) => PermissionStatusModel.initial(),
          (model) => model ?? PermissionStatusModel.initial(),
        );
        
        final updated = existing.copyWith(...);
        
        return await localDataSource.savePermissionStatus(updated);
      },
      operationName: 'save permission status',
    );
  }
}
```

**Benefits**:
- ✅ Eliminates 10 try-catch blocks
- ✅ Centralized error handling
- ✅ Consistent error messages
- ✅ Reusable for other platform features (Camera, Sensors, etc.)
- ✅ Preserves specific failure types
- ✅ Reduces code by ~40%

---

### Option B: Keep Current Pattern + Add Helper Methods (NOT RECOMMENDED)

**Implementation**:
```dart
class PermissionRepositoryImpl implements PermissionRepository {
  // ... existing code ...
  
  /// Helper: Execute operation with error handling
  Future<Either<Failure, T>> _execute<T>({
    required Future<T> Function() operation,
    required String errorMessage,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      logger.e('$errorMessage: $e');
      return Left(UnexpectedFailure(errorMessage));
    }
  }
}
```

**Why NOT Recommended**:
- ❌ Still requires manual wrapping in every method
- ❌ Doesn't follow BaseRepository pattern
- ❌ Not reusable across features
- ❌ Minimal code reduction (~20%)

---

## 📊 COMPARISON TABLE

| Aspect | Current | Option A (PlatformBaseRepository) | Option B (Helper Methods) |
|--------|---------|-----------------------------------|---------------------------|
| Code Duplication | High (10 try-catch) | Low (2 methods) | Medium (10 wrappers) |
| Error Consistency | Low | High | Medium |
| Reusability | None | High (other features) | Low (this repo only) |
| Alignment with Core | None | High | Low |
| Code Reduction | 0% | ~40% | ~20% |
| Maintenance | Hard | Easy | Medium |
| Type Safety | Low | High | Medium |
| Testability | Medium | High | Medium |

---

## 🎯 FINAL RECOMMENDATION

### ✅ Implement Option A: PlatformBaseRepository

**Rationale**:
1. **Separation of Concerns**: Platform repositories (permissions, sensors) have different needs than network repositories (coupons, products)
2. **Reusability**: Can be used for future platform features (Camera, Biometrics, etc.)
3. **Consistency**: Follows same pattern as BaseRepository but adapted for platform APIs
4. **Code Quality**: Eliminates duplication, centralizes error handling
5. **Scalability**: Easy to add new platform features

**Implementation Steps**:
1. Create `lib/core/repositories/platform_base_repository.dart`
2. Implement `executePlatformOperation` and `executeStorageOperation` methods
3. Refactor `PermissionRepositoryImpl` to extend `PlatformBaseRepository`
4. Replace all try-catch blocks with base class methods
5. Run `dart analyze` and `getDiagnostics` to verify
6. Run tests to ensure functionality unchanged

**Estimated Time**: 30-45 minutes

**Risk Level**: 🟢 LOW (no breaking changes, same functionality)

---

## 📝 NEXT STEPS

**WAIT FOR USER APPROVAL** before proceeding with implementation.

Once approved:
1. Create `PlatformBaseRepository` class
2. Refactor `PermissionRepositoryImpl`
3. Verify with diagnostics
4. Create completion report

---

## 📚 FILES ANALYZED

1. `lib/features/permissions/data/repositories/permission_repository_impl.dart` (13 methods)
2. `lib/features/permissions/domain/repositories/permission_repository.dart` (interface)
3. `lib/core/repositories/base_repository.dart` (core infrastructure)
4. `lib/features/permissions/data/data_sources/permission_local_data_source.dart` (storage)
5. `CORE_INFRASTRUCTURE_AUDIT_REPORT.md` (architecture patterns)

---

**Analysis by**: Kiro AI Assistant  
**Status**: ✅ READY FOR APPROVAL  
**Next**: Awaiting user decision on Option A vs Option B
