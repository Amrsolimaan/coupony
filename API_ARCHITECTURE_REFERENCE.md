# 📘 تقرير معماري شامل - API Architecture Reference

> **الهدف**: مرجع كامل لبنية الـ API في المشروع لاستخدامه عند إنشاء ميزات جديدة

---

## 📋 جدول المحتويات

1. [البنية العامة](#البنية-العامة)
2. [Network Layer - طبقة الشبكة](#network-layer)
3. [Error Handling - معالجة الأخطاء](#error-handling)
4. [Dependency Injection](#dependency-injection)
5. [Data Layer Pattern](#data-layer-pattern)
6. [API Endpoints](#api-endpoints)
7. [أمثلة عملية](#أمثلة-عملية)

---

## 🏗️ البنية العامة

### مسارات الملفات الأساسية

```
lib/
├── core/
│   ├── network/
│   │   ├── dio_client.dart              ← HTTP Client الرئيسي
│   │   ├── network_info.dart            ← فحص الاتصال بالإنترنت
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart    ← إضافة Token + Auto Refresh
│   │       ├── error_interceptor.dart   ← تحويل الأخطاء
│   │       ├── locale_interceptor.dart  ← إضافة اللغة
│   │       └── logging_interceptor.dart ← تسجيل الطلبات
│   ├── errors/
│   │   ├── exceptions.dart              ← Exception Classes
│   │   └── failures.dart                ← Failure Classes (Either)
│   ├── repositories/
│   │   └── base_repository.dart         ← Base Class للـ Repositories
│   └── constants/
│       ├── api_constants.dart           ← جميع الـ Endpoints
│       └── storage_keys.dart            ← مفاتيح التخزين
├── config/
│   └── dependency_injection/
│       └── injection_container.dart     ← Service Locator (GetIt)
└── features/
    └── [feature_name]/
        ├── data/
        │   ├── datasources/
        │   │   ├── [feature]_remote_data_source.dart
        │   │   └── [feature]_local_data_source.dart
        │   ├── models/
        │   │   └── [model]_model.dart
        │   └── repositories/
        │       └── [feature]_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        └── presentation/
```

---

## 🌐 Network Layer

### 1. DioClient - العميل الرئيسي

**المسار**: `lib/core/network/dio_client.dart`

**الاستخدام**:
```dart
final DioClient client;

// في RemoteDataSource
AuthRemoteDataSourceImpl({required this.client});

// استدعاء الطلبات
final response = await client.post(
  ApiConstants.login,
  data: {'email': email, 'password': password},
);
```

**الميزات**:
- ✅ Base URL مُعرّف مسبقاً: `https://api.coupony.shop/api/v1`
- ✅ Timeout: 30 ثانية للاتصال والاستقبال
- ✅ Headers افتراضية: `Content-Type: application/json`
- ✅ Interceptors جاهزة (Auth, Error, Locale, Logging)

**الـ Methods المتاحة**:
```dart
client.get(path, queryParameters, options)
client.post(path, data, queryParameters, options)
client.put(path, data, queryParameters, options)
client.patch(path, data, queryParameters, options)
client.delete(path, data, queryParameters, options)
```

---

### 2. Interceptors - المعترضات

#### 🔐 AuthInterceptor
**المسار**: `lib/core/network/interceptors/auth_interceptor.dart`

**الوظائف**:
- إضافة `Authorization: Bearer {token}` تلقائياً لكل طلب
- Auto Token Refresh عند استقبال 401
- Queue للطلبات أثناء التحديث
- تنظيف البيانات عند فشل التحديث

**لا تحتاج لفعل شيء** - يعمل تلقائياً!

---

#### ❌ ErrorInterceptor
**المسار**: `lib/core/network/interceptors/error_interceptor.dart`

**التحويلات**:

| حالة الخطأ | Exception المُرمى |
|-----------|------------------|
| 401 | `UnauthorizedException` |
| 404 | `NotFoundException` |
| 422 | `ValidationException` (مع جميع رسائل الخطأ) |
| 500+ | `ServerException` |
| Timeout | `ServerException('Connection timed out')` |
| No Internet | `ServerException('error_no_internet_check_network')` |

**معالجة 422 Validation Errors**:
- يستخرج جميع رسائل الخطأ من `errors` object
- يدمجها في رسالة واحدة مفصولة بـ `\n`
- يزيل النص الإنجليزي الإضافي من Laravel

---

#### 🌍 LocaleInterceptor
**المسار**: `lib/core/network/interceptors/locale_interceptor.dart`

**الوظيفة**: إضافة `Accept-Language: ar` أو `en` حسب لغة التطبيق

---

## ⚠️ Error Handling - معالجة الأخطاء

### 1. Exceptions (في Data Layer)

**المسار**: `lib/core/errors/exceptions.dart`

```dart
// الـ Exceptions المتاحة
ServerException(message)        // أخطاء السيرفر (500+, timeouts)
CacheException(message)         // أخطاء التخزين المحلي
UnauthorizedException(message)  // 401 - غير مصرح
NotFoundException(message)       // 404 - غير موجود
NetworkException(message)       // مشاكل الشبكة
ValidationException(message)    // 422 - بيانات غير صحيحة
InvalidTokenException(message)  // Token منتهي الصلاحية
```

**الاستخدام في RemoteDataSource**:
```dart
try {
  final response = await client.post(endpoint, data: data);
  return ModelClass.fromJson(response.data);
} on DioException catch (e) {
  // ErrorInterceptor حول الخطأ إلى Exception
  if (e.error is ValidationException) throw e.error as ValidationException;
  if (e.error is ServerException) throw e.error as ServerException;
  // ... إلخ
} catch (e) {
  throw ServerException(e.toString());
}
```

---

### 2. Failures (في Domain Layer)

**المسار**: `lib/core/errors/failures.dart`

```dart
// الـ Failures المتاحة (للاستخدام مع Either)
ServerFailure(message)
NetworkFailure(message)
CacheFailure(message)
ValidationFailure(message)
UnauthorizedFailure(message)
UnexpectedFailure(message)
InvalidTokenFailure(message)
OtpRequiredFailure(email, password)  // حالة خاصة للـ Google Sign-In
```

**الاستخدام في Repository**:
```dart
@override
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final user = await remoteDataSource.login(email, password);
    return Right(user);
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message));
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e) {
    return Left(UnexpectedFailure(e.toString()));
  }
}
```

---

## 🔧 Dependency Injection

**المسار**: `lib/config/dependency_injection/injection_container.dart`

### استخدام Service Locator

```dart
import 'package:coupony/config/dependency_injection/injection_container.dart';

// الحصول على instance
final dioClient = sl<DioClient>();
final logger = sl<Logger>();
final networkInfo = sl<NetworkInfo>();
```

### تسجيل ميزة جديدة

**خطوات التسجيل**:

1. **إنشاء ملف منفصل** في `lib/config/dependency_injection/features/`:


```dart
// lib/config/dependency_injection/features/my_feature_injection.dart
import 'package:get_it/get_it.dart';

void registerMyFeatureDependencies(GetIt sl) {
  // ═══ DATA SOURCES ═══
  sl.registerLazySingleton<MyFeatureRemoteDataSource>(
    () => MyFeatureRemoteDataSourceImpl(
      client: sl<DioClient>(),
      logger: sl<Logger>(),
    ),
  );

  sl.registerLazySingleton<MyFeatureLocalDataSource>(
    () => MyFeatureLocalDataSourceImpl(
      cacheService: sl<LocalCacheService>(),
    ),
  );

  // ═══ REPOSITORY ═══
  sl.registerLazySingleton<MyFeatureRepository>(
    () => MyFeatureRepositoryImpl(
      remoteDataSource: sl<MyFeatureRemoteDataSource>(),
      localDataSource: sl<MyFeatureLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // ═══ USE CASES ═══
  sl.registerLazySingleton(() => GetMyDataUseCase(sl<MyFeatureRepository>()));

  // ═══ CUBIT/BLOC ═══
  sl.registerFactory<MyFeatureCubit>(
    () => MyFeatureCubit(getMyData: sl<GetMyDataUseCase>()),
  );
}
```

2. **استدعاء التسجيل** في `injection_container.dart`:

```dart
import 'features/my_feature_injection.dart';

Future<void> init() async {
  // ... الكود الموجود
  
  // ═══ MY FEATURE ═══
  registerMyFeatureDependencies(sl);
}
```

---

## 📦 Data Layer Pattern

### 1. Remote Data Source

**المسار**: `lib/features/[feature]/data/datasources/[feature]_remote_data_source.dart`

**القالب**:

```dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/my_model.dart';

// ═══════════════════════════════════════════════════════════
// ABSTRACT CLASS
// ═══════════════════════════════════════════════════════════

abstract class MyFeatureRemoteDataSource {
  /// GET /my-endpoint
  Future<List<MyModel>> fetchData();
  
  /// POST /my-endpoint
  Future<MyModel> createData(Map<String, dynamic> data);
  
  /// PATCH /my-endpoint/{id}
  Future<MyModel> updateData(String id, Map<String, dynamic> data);
  
  /// DELETE /my-endpoint/{id}
  Future<void> deleteData(String id);
}

// ═══════════════════════════════════════════════════════════
// IMPLEMENTATION
// ═══════════════════════════════════════════════════════════

class MyFeatureRemoteDataSourceImpl implements MyFeatureRemoteDataSource {
  final DioClient client;
  final Logger logger;

  MyFeatureRemoteDataSourceImpl({
    required this.client,
    required this.logger,
  });

  @override
  Future<List<MyModel>> fetchData() async {
    try {
      logger.i('📥 GET REQUEST — ${ApiConstants.myEndpoint}');
      
      final response = await client.get(ApiConstants.myEndpoint);
      final data = response.data as Map<String, dynamic>? ?? {};
      
      // Handle { "data": [...] } wrapper
      final list = data['data'] as List<dynamic>? ?? [];
      
      return list
          .map((json) => MyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ GET ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ UNEXPECTED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MyModel> createData(Map<String, dynamic> data) async {
    try {
      logger.i('📤 POST REQUEST — ${ApiConstants.myEndpoint}');
      logger.i('📋 Body: $data');
      
      final response = await client.post(ApiConstants.myEndpoint, data: data);
      final responseData = response.data as Map<String, dynamic>? ?? {};
      
      // Handle { "data": {...} } wrapper
      final modelJson = responseData['data'] as Map<String, dynamic>? ?? responseData;
      
      return MyModel.fromJson(modelJson);
    } on DioException catch (e) {
      logger.e('❌ POST ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════
  // PRIVATE HELPER - Error Re-throwing
  // ══════════════════════════════════════════════════════════

  Never _rethrow(DioException e) {
    // Re-throw exceptions set by ErrorInterceptor
    if (e.error is ValidationException)   throw e.error as ValidationException;
    if (e.error is UnauthorizedException) throw e.error as UnauthorizedException;
    if (e.error is NotFoundException)     throw e.error as NotFoundException;
    if (e.error is ServerException)       throw e.error as ServerException;

    // Fallback
    final data = e.response?.data;
    final message = (data is Map<String, dynamic>)
        ? data['message'] as String? ?? 'Network error'
        : 'Network error';
    throw ServerException(message);
  }
}
```

---

### 2. Repository Implementation

**المسار**: `lib/features/[feature]/data/repositories/[feature]_repository_impl.dart`

**القالب**:

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/my_entity.dart';
import '../../domain/repositories/my_repository.dart';
import '../datasources/my_remote_data_source.dart';
import '../datasources/my_local_data_source.dart';

class MyRepositoryImpl implements MyRepository {
  final MyRemoteDataSource remoteDataSource;
  final MyLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MyEntity>>> getData() async {
    try {
      if (await networkInfo.isConnected) {
        // ONLINE: Fetch from API
        try {
          final data = await remoteDataSource.fetchData();
          
          // Cache the data
          await localDataSource.cacheData(data);
          
          return Right(data);
        } on ServerException catch (e) {
          // API failed — try local fallback
          return _getFromLocalFallback(e.message);
        }
      } else {
        // OFFLINE: Serve from cache
        final cachedData = await localDataSource.getCachedData();
        return Right(cachedData);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MyEntity>> createData(MyEntity entity) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('error_no_internet'));
      }

      final model = MyModel.fromEntity(entity);
      final result = await remoteDataSource.createData(model.toJson());
      
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<MyEntity>>> _getFromLocalFallback(String apiError) async {
    try {
      final cachedData = await localDataSource.getCachedData();
      return Right(cachedData);
    } on CacheException {
      return Left(ServerFailure(apiError));
    }
  }
}
```

---

### 3. استخدام BaseRepository (اختياري)

إذا كنت تريد استخدام الـ Caching Strategy الجاهزة:

```dart
class MyRepositoryImpl extends BaseRepository implements MyRepository {
  final MyRemoteDataSource remoteDataSource;
  final MyLocalDataSource localDataSource;

  MyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required NetworkInfo networkInfo,
    required LocalCacheService cacheService,
  }) : super(networkInfo: networkInfo, cacheService: cacheService);

  @override
  Future<Either<Failure, List<MyEntity>>> getData() async {
    return await fetchWithCacheStrategy<List<MyEntity>>(
      remoteCall: () => remoteDataSource.fetchData(),
      localCall: () => localDataSource.getCachedData(),
      cacheCall: (data) => localDataSource.cacheData(data),
    );
  }
}
```

---

## 🔗 API Endpoints

**المسار**: `lib/core/constants/api_constants.dart`

### Base URL
```dart
static const String baseUrl = 'https://api.coupony.shop/api/v1';
```

### Endpoints المتاحة

#### 🔐 Authentication
```dart
ApiConstants.login           // POST /auth/login
ApiConstants.register        // POST /auth/register
ApiConstants.googleAuth      // POST /auth/google
ApiConstants.sendOtp         // POST /auth/otp/send
ApiConstants.verifyOtp       // POST /auth/otp/verify
ApiConstants.logout          // POST /auth/logout
ApiConstants.refreshToken    // POST /auth/refresh
ApiConstants.updateFcmToken  // POST /auth/fcm-token
```

#### 🔑 Password Reset
```dart
ApiConstants.forgotPassword   // POST /auth/password/forgot
ApiConstants.verifyResetOtp   // POST /auth/password/verify-otp
ApiConstants.resendResetCode  // POST /auth/password/resend-otp
ApiConstants.resetPassword    // POST /auth/password/reset
```

#### 🏪 Stores
```dart
ApiConstants.createStore     // POST /stores
ApiConstants.getCategories   // GET /store-categories
ApiConstants.getSocials      // GET /socials
```

#### 👤 Profile
```dart
ApiConstants.profile         // GET /auth/me
```

#### 📍 Addresses
```dart
ApiConstants.addresses                    // GET/POST /me/addresses
ApiConstants.addressById(id)              // PATCH/DELETE /me/addresses/{id}
```

### إضافة Endpoint جديد

```dart
// في api_constants.dart
static const String myNewEndpoint = '/my-endpoint';
static String myEndpointById(String id) => '/my-endpoint/$id';
```

---

## 💡 أمثلة عملية

### مثال 1: GET Request بسيط

```dart
// Remote Data Source
@override
Future<List<ProductModel>> getProducts() async {
  try {
    final response = await client.get('/products');
    final data = response.data as Map<String, dynamic>? ?? {};
    final list = data['data'] as List<dynamic>? ?? [];
    
    return list.map((json) => ProductModel.fromJson(json)).toList();
  } on DioException catch (e) {
    _rethrow(e);
  }
}
```

---

### مثال 2: POST Request مع Body

```dart
// Remote Data Source
@override
Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
  try {
    final response = await client.post(
      '/orders',
      data: orderData,
    );
    
    final data = response.data as Map<String, dynamic>? ?? {};
    final orderJson = data['data'] as Map<String, dynamic>? ?? data;
    
    return OrderModel.fromJson(orderJson);
  } on DioException catch (e) {
    _rethrow(e);
  }
}
```

---

### مثال 3: PATCH Request (Laravel Method Spoofing)

```dart
// Remote Data Source
@override
Future<ProductModel> updateProduct(String id, Map<String, dynamic> updates) async {
  try {
    // Laravel method spoofing for multipart/form-data
    final formData = FormData();
    formData.fields.add(const MapEntry('_method', 'PATCH'));
    
    updates.forEach((key, value) {
      if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });
    
    final response = await client.post(
      '/products/$id',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    
    final data = response.data as Map<String, dynamic>? ?? {};
    return ProductModel.fromJson(data['data'] ?? data);
  } on DioException catch (e) {
    _rethrow(e);
  }
}
```

---

### مثال 4: معالجة Validation Errors

```dart
// في Cubit/Bloc
void createProduct(ProductData data) async {
  emit(state.copyWith(status: ProductStatus.loading));
  
  final result = await repository.createProduct(data);
  
  result.fold(
    (failure) {
      if (failure is ValidationFailure) {
        // عرض جميع رسائل الخطأ (مفصولة بـ \n)
        emit(state.copyWith(
          status: ProductStatus.error,
          errorMessage: failure.message, // "Field X is required\nField Y must be valid"
        ));
      } else {
        emit(state.copyWith(
          status: ProductStatus.error,
          errorMessage: failure.message,
        ));
      }
    },
    (product) {
      emit(state.copyWith(
        status: ProductStatus.success,
        product: product,
      ));
    },
  );
}
```

---

## 📝 Checklist لإنشاء ميزة جديدة

عند إنشاء ميزة جديدة تحتاج API:

- [ ] **1. إضافة Endpoint** في `api_constants.dart`
- [ ] **2. إنشاء Model** في `data/models/` مع `fromJson` و `toJson`
- [ ] **3. إنشاء Entity** في `domain/entities/`
- [ ] **4. إنشاء RemoteDataSource**:
  - [ ] Abstract class مع جميع الـ methods
  - [ ] Implementation مع استخدام `DioClient`
  - [ ] معالجة الأخطاء باستخدام `_rethrow()`
  - [ ] Logging مع `Logger`
- [ ] **5. إنشاء LocalDataSource** (إذا كان هناك caching)
- [ ] **6. إنشاء Repository**:
  - [ ] Abstract في `domain/repositories/`
  - [ ] Implementation في `data/repositories/`
  - [ ] تحويل Exceptions إلى Failures
  - [ ] استخدام `Either<Failure, T>`
- [ ] **7. تسجيل Dependencies** في `injection_container.dart`
- [ ] **8. إنشاء Use Cases** (اختياري)
- [ ] **9. إنشاء Cubit/Bloc** للـ State Management

---

## 🎯 نصائح مهمة

### ✅ Do's

1. **استخدم `DioClient` دائماً** - لا تنشئ `Dio` instance جديد
2. **استخدم `Logger`** لتسجيل الطلبات والأخطاء
3. **تعامل مع `{ "data": ... }` wrapper** - السيرفر يرجع البيانات داخل `data`
4. **استخدم `_rethrow()` helper** لإعادة رمي الأخطاء من ErrorInterceptor
5. **استخدم `Either<Failure, T>`** في Repository layer
6. **سجل Dependencies** في ملف منفصل في `features/`

### ❌ Don'ts

1. **لا تنشئ Dio instance جديد** - استخدم `DioClient` المسجل
2. **لا تتجاهل الأخطاء** - تعامل مع جميع الـ Exceptions
3. **لا تستخدم `print()`** - استخدم `Logger`
4. **لا تنسى معالجة حالة Offline** في Repository
5. **لا تكتب Token يدوياً** - `AuthInterceptor` يفعل ذلك تلقائياً

---

## 📚 مراجع إضافية

### ملفات للقراءة

- `lib/features/auth/data/datasources/auth_remote_data_source.dart` - مثال كامل
- `lib/features/Profile/data/repositories/address_repository_impl.dart` - Repository pattern
- `lib/core/network/interceptors/error_interceptor.dart` - معالجة الأخطاء
- `lib/core/repositories/base_repository.dart` - Caching strategies

### Storage Keys

راجع `lib/core/constants/storage_keys.dart` لجميع مفاتيح التخزين المتاحة:
- `StorageKeys.authToken` - Access Token
- `StorageKeys.refreshToken` - Refresh Token
- `StorageKeys.userId` - User ID
- `StorageKeys.userRole` - User Role (customer/merchant)

---

## 🔄 تحديثات مستقبلية

عند إضافة endpoints جديدة، تأكد من:
1. تحديث `api_constants.dart`
2. تحديث هذا الملف بالأمثلة الجديدة
3. إضافة tests للـ RemoteDataSource
4. توثيق أي حالات خاصة

---

**آخر تحديث**: 2026-04-09  
**الإصدار**: 1.0.0  
**المشروع**: Coupony App


---

## 📦 مثال عملي: بنية ميزة SellerProducts

### المسار الكامل
```
lib/features/seller_flow/SellerProducts/
```

### 🗂️ البنية التفصيلية

```
SellerProducts/
├── data/
│   ├── datasources/
│   │   ├── seller_products_remote_data_source.dart    ← API calls
│   │   └── seller_products_local_data_source.dart     ← Local caching
│   ├── models/
│   │   ├── product_model.dart                         ← Product JSON mapping
│   │   ├── product_variant_model.dart                 ← Variant JSON mapping
│   │   ├── product_image_model.dart                   ← Image JSON mapping
│   │   └── product_attribute_model.dart               ← Attribute JSON mapping
│   └── repositories/
│       └── seller_products_repository_impl.dart       ← Repository implementation
│
├── domain/
│   ├── entities/
│   │   ├── product.dart                               ← Product entity
│   │   ├── product_variant.dart                       ← Variant entity
│   │   ├── product_image.dart                         ← Image entity
│   │   └── product_attribute.dart                     ← Attribute entity
│   ├── repositories/
│   │   └── seller_products_repository.dart            ← Repository interface
│   └── use_cases/
│       ├── get_store_products.dart                    ← Fetch products list
│       ├── create_product.dart                        ← Create new product
│       ├── update_product.dart                        ← Update existing product
│       ├── delete_product.dart                        ← Delete product
│       └── get_product_details.dart                   ← Get single product
│
├── presentation/
│   ├── cubit/
│   │   ├── seller_products_cubit.dart                 ← State management
│   │   └── seller_products_state.dart                 ← States definition
│   ├── pages/
│   │   ├── products_list_page.dart                    ← Products listing screen
│   │   ├── create_product_page.dart                   ← Create product form
│   │   ├── edit_product_page.dart                     ← Edit product form
│   │   └── product_details_page.dart                  ← Product details view
│   ├── widgets/
│   │   ├── product_card.dart                          ← Product list item
│   │   ├── product_form.dart                          ← Reusable form widget
│   │   ├── variant_form.dart                          ← Variant input widget
│   │   ├── image_picker_widget.dart                   ← Image upload widget
│   │   └── product_filters.dart                       ← Filter/search widget
│   └── utils/
│       ├── product_validators.dart                    ← Form validation
│       └── product_helpers.dart                       ← Helper functions
│
└── Coupony API seller products.postman.json           ← API documentation
```

---

### 📝 شرح تفصيلي للمجلدات

#### 1️⃣ **data/datasources/**

**الغرض**: التعامل المباشر مع الـ API والتخزين المحلي

**الملفات المتوقعة**:

##### `seller_products_remote_data_source.dart`
```dart
abstract class SellerProductsRemoteDataSource {
  /// GET /stores/{storeId}/products
  Future<List<ProductModel>> getStoreProducts({
    required String storeId,
    String? status,
    String? search,
    bool? isFeatured,
    int? perPage,
  });

  /// GET /stores/{storeId}/products/{productId}
  Future<ProductModel> getProductDetails({
    required String storeId,
    required String productId,
  });

  /// POST /stores/{storeId}/products (multipart/form-data)
  Future<ProductModel> createProduct({
    required String storeId,
    required Map<String, dynamic> productData,
    required List<File> images,
  });

  /// POST /stores/{storeId}/products/{productId} with _method: PATCH
  Future<ProductModel> updateProduct({
    required String storeId,
    required String productId,
    required Map<String, dynamic> productData,
    List<File>? newImages,
  });

  /// DELETE /stores/{storeId}/products/{productId}
  Future<void> deleteProduct({
    required String storeId,
    required String productId,
  });
}
```

**ملاحظات مهمة**:
- استخدام `multipart/form-data` لرفع الصور
- Laravel method spoofing للـ PATCH: `_method: PATCH`
- Query parameters للفلترة والبحث

##### `seller_products_local_data_source.dart`
```dart
abstract class SellerProductsLocalDataSource {
  /// Cache products list
  Future<void> cacheProducts(List<ProductModel> products);
  
  /// Get cached products
  Future<List<ProductModel>> getCachedProducts();
  
  /// Cache single product
  Future<void> cacheProduct(ProductModel product);
  
  /// Clear products cache
  Future<void> clearCache();
}
```

---

#### 2️⃣ **data/models/**

**الغرض**: تحويل JSON من/إلى Dart objects

**الملفات المتوقعة**:

##### `product_model.dart`
```dart
class ProductModel extends ProductEntity {
  final String id;
  final String storeId;
  final String title;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String productType; // 'standard', 'variable'
  final double basePrice;
  final double? compareAtPrice;
  final String currency;
  final String? sku;
  final String status; // 'draft', 'active', 'archived'
  final bool isFeatured;
  final List<String> categoryIds;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;
  final DateTime createdAt;
  final DateTime updatedAt;

  // fromJson - من API response
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      title: json['title'] as String,
      // ... باقي الحقول
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => ProductImageModel.fromJson(img))
          .toList() ?? [],
      variants: (json['variants'] as List<dynamic>?)
          ?.map((v) => ProductVariantModel.fromJson(v))
          .toList() ?? [],
    );
  }

  // toJson - للإرسال إلى API
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'slug': slug,
      'short_description': shortDescription,
      'description': description,
      'product_type': productType,
      'base_price': basePrice.toString(),
      'compare_at_price': compareAtPrice?.toString(),
      'currency': currency,
      'sku': sku,
      'status': status,
      'is_featured': isFeatured ? '1' : '0',
      'category_ids': categoryIds,
      // variants و images يتم إرسالها بشكل منفصل
    };
  }

  // toFormData - للإرسال مع الصور
  FormData toFormData({List<File>? imageFiles}) {
    final formData = FormData();
    
    // Basic fields
    formData.fields.add(MapEntry('title', title));
    formData.fields.add(MapEntry('slug', slug));
    // ... باقي الحقول
    
    // Category IDs
    for (int i = 0; i < categoryIds.length; i++) {
      formData.fields.add(MapEntry('category_ids[$i]', categoryIds[i]));
    }
    
    // Images
    if (imageFiles != null) {
      for (int i = 0; i < imageFiles.length; i++) {
        formData.files.add(MapEntry(
          'images[$i][file]',
          MultipartFile.fromFileSync(imageFiles[i].path),
        ));
        formData.fields.add(MapEntry('images[$i][sort_order]', i.toString()));
        formData.fields.add(MapEntry('images[$i][is_primary]', i == 0 ? '1' : '0'));
      }
    }
    
    // Variants
    for (int i = 0; i < variants.length; i++) {
      final variant = variants[i];
      formData.fields.add(MapEntry('variants[$i][title]', variant.title));
      formData.fields.add(MapEntry('variants[$i][sku]', variant.sku));
      formData.fields.add(MapEntry('variants[$i][price]', variant.price.toString()));
      // ... باقي حقول الـ variant
      
      // Variant attributes
      for (int j = 0; j < variant.attributes.length; j++) {
        final attr = variant.attributes[j];
        formData.fields.add(MapEntry(
          'variants[$i][attributes][$j][attribute_name]',
          attr.name,
        ));
        formData.fields.add(MapEntry(
          'variants[$i][attributes][$j][attribute_value]',
          attr.value,
        ));
      }
    }
    
    return formData;
  }
}
```

##### `product_variant_model.dart`
```dart
class ProductVariantModel extends ProductVariantEntity {
  final String? id;
  final String title;              // "Red / XL"
  final String optionSummary;      // "Color: Red, Size: XL"
  final String sku;
  final String? barcode;
  final double price;
  final double? compareAtPrice;
  final String currency;
  final int sortOrder;
  final bool isDefault;
  final bool isActive;
  final List<ProductAttributeModel> attributes;

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      // ... باقي الحقول
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((a) => ProductAttributeModel.fromJson(a))
          .toList() ?? [],
    );
  }
}
```

##### `product_image_model.dart`
```dart
class ProductImageModel extends ProductImageEntity {
  final String? id;
  final String url;
  final String? thumbnailUrl;
  final int sortOrder;
  final bool isPrimary;

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as String?,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}
```

##### `product_attribute_model.dart`
```dart
class ProductAttributeModel extends ProductAttributeEntity {
  final String name;        // "color", "size"
  final String value;       // "red", "XL"
  final int sortOrder;

  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeModel(
      name: json['attribute_name'] as String,
      value: json['attribute_value'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
```

---

#### 3️⃣ **data/repositories/**

**الغرض**: تنفيذ Repository pattern مع معالجة الأخطاء

##### `seller_products_repository_impl.dart`
```dart
class SellerProductsRepositoryImpl implements SellerProductsRepository {
  final SellerProductsRemoteDataSource remoteDataSource;
  final SellerProductsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<Product>>> getStoreProducts({
    required String storeId,
    String? status,
    String? search,
    bool? isFeatured,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final products = await remoteDataSource.getStoreProducts(
          storeId: storeId,
          status: status,
          search: search,
          isFeatured: isFeatured,
        );
        
        // Cache the results
        await localDataSource.cacheProducts(products);
        
        return Right(products);
      } else {
        // Offline - serve from cache
        final cached = await localDataSource.getCachedProducts();
        return Right(cached);
      }
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct({
    required String storeId,
    required Product product,
    required List<File> images,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('error_no_internet'));
      }

      final model = ProductModel.fromEntity(product);
      final result = await remoteDataSource.createProduct(
        storeId: storeId,
        productData: model.toJson(),
        images: images,
      );
      
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
```

---

#### 4️⃣ **domain/entities/**

**الغرض**: Business logic objects (مستقلة عن التفاصيل التقنية)

##### `product.dart`
```dart
class ProductEntity extends Equatable {
  final String id;
  final String storeId;
  final String title;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String productType;
  final double basePrice;
  final double? compareAtPrice;
  final String currency;
  final String? sku;
  final String status;
  final bool isFeatured;
  final List<String> categoryIds;
  final List<ProductImageEntity> images;
  final List<ProductVariantEntity> variants;

  const ProductEntity({
    required this.id,
    required this.storeId,
    required this.title,
    // ... باقي الحقول
  });

  @override
  List<Object?> get props => [id, title, status, /* ... */];
}
```

---

#### 5️⃣ **domain/use_cases/**

**الغرض**: حالات الاستخدام المنفصلة (Single Responsibility)

##### `get_store_products.dart`
```dart
class GetStoreProducts {
  final SellerProductsRepository repository;

  GetStoreProducts(this.repository);

  Future<Either<Failure, List<Product>>> call({
    required String storeId,
    String? status,
    String? search,
    bool? isFeatured,
  }) async {
    return await repository.getStoreProducts(
      storeId: storeId,
      status: status,
      search: search,
      isFeatured: isFeatured,
    );
  }
}
```

##### `create_product.dart`
```dart
class CreateProduct {
  final SellerProductsRepository repository;

  CreateProduct(this.repository);

  Future<Either<Failure, Product>> call({
    required String storeId,
    required Product product,
    required List<File> images,
  }) async {
    // Validation logic here if needed
    if (images.isEmpty) {
      return const Left(ValidationFailure('At least one image is required'));
    }

    return await repository.createProduct(
      storeId: storeId,
      product: product,
      images: images,
    );
  }
}
```

---

#### 6️⃣ **presentation/cubit/**

**الغرض**: إدارة الحالة (State Management)

##### `seller_products_state.dart`
```dart
enum ProductsStatus { initial, loading, success, error }

class SellerProductsState extends Equatable {
  final ProductsStatus status;
  final List<Product> products;
  final Product? selectedProduct;
  final String? errorMessage;
  final String? searchQuery;
  final String? statusFilter;

  const SellerProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.selectedProduct,
    this.errorMessage,
    this.searchQuery,
    this.statusFilter,
  });

  SellerProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    Product? selectedProduct,
    String? errorMessage,
    String? searchQuery,
    String? statusFilter,
  }) {
    return SellerProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    selectedProduct,
    errorMessage,
    searchQuery,
    statusFilter,
  ];
}
```

##### `seller_products_cubit.dart`
```dart
class SellerProductsCubit extends Cubit<SellerProductsState> {
  final GetStoreProducts getStoreProducts;
  final CreateProduct createProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;

  SellerProductsCubit({
    required this.getStoreProducts,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
  }) : super(const SellerProductsState());

  Future<void> loadProducts(String storeId) async {
    emit(state.copyWith(status: ProductsStatus.loading));

    final result = await getStoreProducts(
      storeId: storeId,
      status: state.statusFilter,
      search: state.searchQuery,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: failure.message,
      )),
      (products) => emit(state.copyWith(
        status: ProductsStatus.success,
        products: products,
      )),
    );
  }

  Future<void> createNewProduct({
    required String storeId,
    required Product product,
    required List<File> images,
  }) async {
    emit(state.copyWith(status: ProductsStatus.loading));

    final result = await createProduct(
      storeId: storeId,
      product: product,
      images: images,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: failure.message,
      )),
      (newProduct) {
        final updatedProducts = [...state.products, newProduct];
        emit(state.copyWith(
          status: ProductsStatus.success,
          products: updatedProducts,
        ));
      },
    );
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setStatusFilter(String? status) {
    emit(state.copyWith(statusFilter: status));
  }
}
```

---

#### 7️⃣ **presentation/pages/**

**الغرض**: شاشات التطبيق

##### `products_list_page.dart`
```dart
class ProductsListPage extends StatelessWidget {
  final String storeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SellerProductsCubit>()..loadProducts(storeId),
      child: Scaffold(
        appBar: AppBar(title: Text('My Products')),
        body: BlocBuilder<SellerProductsCubit, SellerProductsState>(
          builder: (context, state) {
            if (state.status == ProductsStatus.loading) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (state.status == ProductsStatus.error) {
              return Center(child: Text(state.errorMessage ?? 'Error'));
            }
            
            return ListView.builder(
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: state.products[index]);
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateProductPage(storeId: storeId),
            ),
          ),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
```

---

#### 8️⃣ **presentation/widgets/**

**الغرض**: مكونات UI قابلة لإعادة الاستخدام

##### `product_card.dart`
```dart
class ProductCard extends StatelessWidget {
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: product.images.isNotEmpty
            ? Image.network(product.images.first.thumbnailUrl ?? product.images.first.url)
            : Icon(Icons.image),
        title: Text(product.title),
        subtitle: Text('${product.currency} ${product.basePrice}'),
        trailing: _buildStatusChip(product.status),
        onTap: () => _navigateToDetails(context, product),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'draft':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.2),
    );
  }
}
```

---

### 🔗 API Endpoints للـ SellerProducts

يجب إضافتها في `lib/core/constants/api_constants.dart`:

```dart
// ── Seller Products ────────────────────────────────────
static String storeProducts(String storeId) => '/stores/$storeId/products';
static String storeProductById(String storeId, String productId) => 
    '/stores/$storeId/products/$productId';
```

**الاستخدام**:
```dart
// List products
await client.get(ApiConstants.storeProducts(storeId));

// Get single product
await client.get(ApiConstants.storeProductById(storeId, productId));

// Create product
await client.post(ApiConstants.storeProducts(storeId), data: formData);

// Update product (with method spoofing)
await client.post(
  ApiConstants.storeProductById(storeId, productId),
  data: formData..fields.add(MapEntry('_method', 'PATCH')),
);

// Delete product
await client.delete(ApiConstants.storeProductById(storeId, productId));
```

---

### 🎯 خطوات التنفيذ المقترحة

عند البدء في تطوير ميزة SellerProducts:

1. **إضافة Endpoints** في `api_constants.dart`
2. **إنشاء Entities** في `domain/entities/`
3. **إنشاء Models** في `data/models/` مع `fromJson` و `toFormData`
4. **إنشاء RemoteDataSource** مع معالجة `multipart/form-data`
5. **إنشاء LocalDataSource** للـ caching
6. **إنشاء Repository** مع معالجة الأخطاء
7. **إنشاء Use Cases** لكل عملية
8. **تسجيل Dependencies** في `injection_container.dart`
9. **إنشاء Cubit** للـ State Management
10. **بناء UI** (Pages & Widgets)

---

### ⚠️ ملاحظات خاصة بـ SellerProducts

#### رفع الصور (Image Upload)
```dart
// في RemoteDataSource
Future<ProductModel> createProduct({
  required String storeId,
  required Map<String, dynamic> productData,
  required List<File> images,
}) async {
  final formData = FormData();
  
  // Add product fields
  productData.forEach((key, value) {
    formData.fields.add(MapEntry(key, value.toString()));
  });
  
  // Add images
  for (int i = 0; i < images.length; i++) {
    formData.files.add(MapEntry(
      'images[$i][file]',
      await MultipartFile.fromFile(
        images[i].path,
        filename: 'product_image_$i.jpg',
      ),
    ));
    formData.fields.add(MapEntry('images[$i][sort_order]', i.toString()));
    formData.fields.add(MapEntry('images[$i][is_primary]', i == 0 ? '1' : '0'));
  }
  
  final response = await client.post(
    ApiConstants.storeProducts(storeId),
    data: formData,
    options: Options(contentType: 'multipart/form-data'),
  );
  
  return ProductModel.fromJson(response.data['data']);
}
```

#### معالجة Variants المعقدة
```dart
// Nested arrays في FormData
for (int i = 0; i < variants.length; i++) {
  formData.fields.add(MapEntry('variants[$i][title]', variants[i].title));
  formData.fields.add(MapEntry('variants[$i][price]', variants[i].price.toString()));
  
  // Nested attributes
  for (int j = 0; j < variants[i].attributes.length; j++) {
    formData.fields.add(MapEntry(
      'variants[$i][attributes][$j][attribute_name]',
      variants[i].attributes[j].name,
    ));
    formData.fields.add(MapEntry(
      'variants[$i][attributes][$j][attribute_value]',
      variants[i].attributes[j].value,
    ));
  }
}
```

---

### 📊 Query Parameters للفلترة

```dart
// في RemoteDataSource
Future<List<ProductModel>> getStoreProducts({
  required String storeId,
  String? status,        // 'draft', 'active', 'archived'
  String? search,        // البحث في العنوان
  bool? isFeatured,      // true/false
  int? perPage,          // عدد النتائج (default: 15)
}) async {
  final queryParams = <String, dynamic>{};
  
  if (status != null) queryParams['status'] = status;
  if (search != null) queryParams['search'] = search;
  if (isFeatured != null) queryParams['is_featured'] = isFeatured ? '1' : '0';
  if (perPage != null) queryParams['per_page'] = perPage.toString();
  
  final response = await client.get(
    ApiConstants.storeProducts(storeId),
    queryParameters: queryParams,
  );
  
  // Handle pagination response
  final data = response.data as Map<String, dynamic>;
  final productsList = data['data'] as List<dynamic>;
  
  return productsList
      .map((json) => ProductModel.fromJson(json))
      .toList();
}
```

---

هذه البنية الكاملة لميزة SellerProducts جاهزة للتطبيق! 🚀
