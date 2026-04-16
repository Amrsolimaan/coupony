# كود التنفيذ الكامل لربط API

## 1️⃣ Remote Data Source

### الملف: `lib/features/seller_flow/dashboard_seller/data/datasources/seller_store_remote_data_source.dart`

```dart
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/shop_display_model.dart';

// ════════════════════════════════════════════════════════
// ABSTRACT CLASS
// ════════════════════════════════════════════════════════

abstract class SellerStoreRemoteDataSource {
  /// GET /api/v1/stores
  /// Returns list of stores owned by authenticated user
  Future<List<StoreDisplayModel>> getStores();
}

// ════════════════════════════════════════════════════════
// IMPLEMENTATION
// ════════════════════════════════════════════════════════

class SellerStoreRemoteDataSourceImpl implements SellerStoreRemoteDataSource {
  final DioClient client;

  SellerStoreRemoteDataSourceImpl({required this.client});

  @override
  Future<List<StoreDisplayModel>> getStores() async {
    try {
      final response = await client.get('/stores');
      
      // Check if response is successful
      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch stores',
        );
      }

      // Extract stores array from nested data structure
      final storesData = response.data['data']['data'] as List;
      
      // Map JSON to models
      return storesData
          .map((json) => StoreDisplayModel.fromJson(json as Map<String, dynamic>))
          .toList();
          
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch stores: ${e.toString()}');
    }
  }
}
```

---

## 2️⃣ Repository Interface

### الملف: `lib/features/seller_flow/dashboard_seller/domain/repositories/seller_store_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/store_display_entity.dart';

// ════════════════════════════════════════════════════════
// REPOSITORY INTERFACE
// ════════════════════════════════════════════════════════

abstract class SellerStoreRepository {
  /// Fetches all stores owned by the authenticated user
  /// Returns the first store if available
  Future<Either<Failure, StoreDisplayEntity>> getStoreDisplay();
}
```

---

## 3️⃣ Repository Implementation

### الملف: `lib/features/seller_flow/dashboard_seller/data/repositories/seller_store_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/store_display_entity.dart';
import '../../domain/repositories/seller_store_repository.dart';
import '../datasources/seller_store_remote_data_source.dart';

// ════════════════════════════════════════════════════════
// REPOSITORY IMPLEMENTATION
// ════════════════════════════════════════════════════════

class SellerStoreRepositoryImpl implements SellerStoreRepository {
  final SellerStoreRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SellerStoreRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, StoreDisplayEntity>> getStoreDisplay() async {
    // Check network connectivity
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      // Fetch stores from API
      final stores = await remoteDataSource.getStores();
      
      // Check if user has any stores
      if (stores.isEmpty) {
        return Left(ServerFailure('No stores found for this user'));
      }

      // Return the first store (assuming one store per seller for now)
      return Right(stores.first);
      
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
```

---

## 4️⃣ Use Case

### الملف: `lib/features/seller_flow/dashboard_seller/domain/usecases/get_store_display_use_case.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/store_display_entity.dart';
import '../repositories/seller_store_repository.dart';

// ════════════════════════════════════════════════════════
// USE CASE
// ════════════════════════════════════════════════════════

class GetStoreDisplayUseCase implements UseCase<StoreDisplayEntity, NoParams> {
  final SellerStoreRepository repository;

  GetStoreDisplayUseCase(this.repository);

  @override
  Future<Either<Failure, StoreDisplayEntity>> call(NoParams params) async {
    return await repository.getStoreDisplay();
  }
}
```

---

## 5️⃣ تحديث Cubit

### الملف: `lib/features/seller_flow/dashboard_seller/presentation/cubit/seller_store_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_store_display_use_case.dart';
import 'seller_store_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER STORE CUBIT
// ─────────────────────────────────────────────────────────────────────────────

class SellerStoreCubit extends Cubit<SellerStoreState> {
  final GetStoreDisplayUseCase getStoreDisplayUseCase;

  SellerStoreCubit({
    required this.getStoreDisplayUseCase,
    bool isGuest = false,
    bool isPending = false,
  }) : super(SellerStoreInitial(
          isGuest: isGuest,
          isPending: isPending,
        )) {
    if (isGuest) {
      emit(const SellerStoreGuest());
    } else if (isPending) {
      emit(const SellerStorePending());
    } else {
      loadStoreDisplay();
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches store display data from API
  Future<void> loadStoreDisplay() async {
    emit(const SellerStoreLoading());

    final result = await getStoreDisplayUseCase(NoParams());

    if (isClosed) return;

    result.fold(
      (failure) => emit(SellerStoreError(_mapFailureToMessage(failure))),
      (store) => emit(SellerStoreDataLoaded(store)),
    );
  }

  // ── Helper Methods ─────────────────────────────────────────────────────────

  String _mapFailureToMessage(dynamic failure) {
    // TODO: Add localization
    if (failure.toString().contains('network')) {
      return 'لا يوجد اتصال بالإنترنت';
    } else if (failure.toString().contains('No stores found')) {
      return 'لم يتم العثور على متجر';
    }
    return 'حدث خطأ أثناء تحميل بيانات المتجر';
  }
}
```

---

## 6️⃣ Dependency Injection

### الملف: `lib/core/di/injection_container.dart`

```dart
// Add these imports
import '../../features/seller_flow/dashboard_seller/data/datasources/seller_store_remote_data_source.dart';
import '../../features/seller_flow/dashboard_seller/data/repositories/seller_store_repository_impl.dart';
import '../../features/seller_flow/dashboard_seller/domain/repositories/seller_store_repository.dart';
import '../../features/seller_flow/dashboard_seller/domain/usecases/get_store_display_use_case.dart';
import '../../features/seller_flow/dashboard_seller/presentation/cubit/seller_store_cubit.dart';

// Add to init() function:

// ══════════════════════════════════════════════════════════════════════════════
// SELLER STORE FEATURE
// ══════════════════════════════════════════════════════════════════════════════

// Cubit
sl.registerFactory(
  () => SellerStoreCubit(
    getStoreDisplayUseCase: sl(),
  ),
);

// Use Cases
sl.registerLazySingleton(() => GetStoreDisplayUseCase(sl()));

// Repository
sl.registerLazySingleton<SellerStoreRepository>(
  () => SellerStoreRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ),
);

// Data Sources
sl.registerLazySingleton<SellerStoreRemoteDataSource>(
  () => SellerStoreRemoteDataSourceImpl(client: sl()),
);
```

---

## 7️⃣ تحديث Router

### الملف: `lib/config/routes/app_router.dart`

```dart
// في مكان إنشاء SellerStorePage، استبدل:

// القديم:
BlocProvider(
  create: (_) => SellerStoreCubit(
    isGuest: isGuest,
    isPending: isPending,
  ),
  child: const SellerStorePage(),
)

// الجديد:
BlocProvider(
  create: (_) => sl<SellerStoreCubit>()
    ..isGuest = isGuest
    ..isPending = isPending,
  child: const SellerStorePage(),
)

// أو بشكل أفضل، قم بتمرير المعاملات في الـ constructor:
BlocProvider(
  create: (_) => sl<SellerStoreCubit>(
    param1: isGuest,
    param2: isPending,
  ),
  child: const SellerStorePage(),
)
```

---

## 🧪 اختبار التكامل

### خطوات الاختبار:

1. تأكد من تسجيل الدخول كـ seller
2. تأكد من وجود متجر مرتبط بالحساب
3. افتح صفحة المتجر
4. تحقق من ظهور البيانات الحقيقية:
   - اسم المتجر
   - الوصف
   - الفئات
   - ساعات العمل
   - التقييمات

### حالات الاختبار:

- ✅ تحميل ناجح مع بيانات كاملة
- ✅ تحميل مع بيانات ناقصة (name فارغ، description null)
- ✅ خطأ في الشبكة
- ✅ لا يوجد متاجر للمستخدم
- ✅ خطأ من السيرفر

---

## 📌 ملاحظات إضافية

### 1. معالجة حالة "لا يوجد متجر"

إذا كان المستخدم seller لكن لم ينشئ متجر بعد، يجب:
- عرض رسالة توضيحية
- زر للانتقال لصفحة إنشاء متجر

### 2. Refresh Functionality

يمكن إضافة Pull-to-Refresh:

```dart
RefreshIndicator(
  onRefresh: () async {
    context.read<SellerStoreCubit>().loadStoreDisplay();
  },
  child: SingleChildScrollView(...),
)
```

### 3. Cache Strategy

للتحسين المستقبلي، يمكن إضافة:
- Local cache باستخدام Hive
- Cache expiration (مثلاً 5 دقائق)
- Offline support

### 4. Multiple Stores Support

حالياً الكود يفترض متجر واحد لكل seller. للدعم المتعدد:
- تعديل UI لعرض قائمة المتاجر
- إضافة store selector
- تحديث الـ state لدعم multiple stores
