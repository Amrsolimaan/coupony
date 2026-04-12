# تنفيذ نظام حالات المتجر (Store Status Flow)

## التغييرات المنفذة

### 1. إضافة Endpoint جديد
- **Endpoint**: `GET /api/v1/stores`
- **الغرض**: جلب قائمة المتاجر بالتفاصيل الكاملة (status, rejection_reason, rejected_at, إلخ)
- **الموقع**: `lib/core/constants/api_constants.dart`

### 2. تحديث UserStoreModel
- إضافة حقل `rejectionReason` (String?) - سبب الرفض المفرد
- إضافة حقل `rejectedAt` (String?) - تاريخ الرفض
- **الموقع**: `lib/features/auth/data/models/user_store_model.dart`

### 3. إنشاء GetStoresUseCase
- Use case جديد لجلب قائمة المتاجر
- **الموقع**: `lib/features/seller_flow/CreateStore/domain/use_cases/get_stores_use_case.dart`

### 4. تحديث Repository & Data Source
- إضافة method `getStores()` في:
  - `CreateStoreRepository`
  - `CreateStoreRemoteDataSource`
  - `CreateStoreRepositoryImpl`

### 5. تحديث Dependency Injection
- تسجيل `GetStoresUseCase` في `create_store_injection.dart`

### 6. تحديث main_profile.dart
- دمج CASE 2 (Rejected) و CASE 3 (Pending) في دالة واحدة
- استدعاء `GET /api/v1/stores` عند الحاجة للتحقق من الحالة الدقيقة
- عرض loading indicator أثناء جلب البيانات

## السيناريوهات المدعومة

### السيناريو 1: مستخدم عادي (customer only)
- **الحالة**: `roles: ['customer']`
- **الإجراء**: عرض زر "كن تاجر" → التوجيه لصفحة إنشاء متجر

### السيناريو 2: طلب قيد المراجعة (seller_pending)
- **الحالة**: `roles: ['seller_pending', 'customer']`
- **الإجراء**: 
  1. استدعاء `GET /api/v1/stores`
  2. فحص `status` من الرد
  3. إذا `status == 'pending'` → التوجيه لصفحة merchant_pending_page

### السيناريو 3: طلب مرفوض (rejected)
- **الحالة**: `status == 'rejected'` من `GET /api/v1/stores`
- **الإجراء**:
  1. التوجيه لصفح