# تحليل ربط بيانات صفحة المتجر بالـ API

## 📋 نظرة عامة

هذا التحليل يوضح كيفية ربط صفحة `seller_store_page.dart` بالـ endpoint الفعلي `GET /api/v1/stores` واستبدال البيانات الوهمية (mock data) ببيانات حقيقية من السيرفر.

---

## 🔗 معلومات الـ Endpoint

**Endpoint:** `GET /api/v1/stores`

**الاستجابة:** يرجع قائمة بالمتاجر الخاصة بالمستخدم المسجل

---

## 📊 مقارنة البيانات: API Response vs Current Entity

### 1️⃣ البيانات الأساسية للمتجر (Store Basic Info)

| الحقل في Entity | الحقل في API Response | الحالة | ملاحظات |
|-----------------|----------------------|--------|---------|
| `id` | `data[0].id` | ✅ متوفر | UUID |
| `name` | `data[0].name` | ✅ متوفر | قد يكون فارغ "" |
| `description` | `data[0].description` | ✅ متوفر | قد يكون فارغ "" |
| `logoUrl` | `data[0].logo_url` | ✅ متوفر | قد يكون null |
| `bannerUrl` | `data[0].banner_url` | ✅ متوفر | قد يكون null |
| `phone` | `data[0].phone` | ✅ متوفر | قد يكون null |
| `status` | `data[0].status` | ✅ متوفر | "active", "pending", etc. |
| `isVerified` | `data[0].is_verified` | ✅ متوفر | boolean |
| `subscriptionTier` | `data[0].subscription_tier` | ✅ متوفر | "free", "premium", etc. |

### 2️⃣ بيانات التقييمات (Rating Data)

| الحقل في Entity | الحقل في API Response | الحالة | ملاحظات |
|-----------------|----------------------|--------|---------|
| `ratingAvg` | `data[0].rating_avg` | ✅ متوفر | String يحتاج تحويل لـ double |
| `ratingCount` | `data[0].rating_count` | ✅ متوفر | int |

### 3️⃣ بيانات غير متوفرة حالياً (Mock Data)

| الحقل في Entity | الحالة | الحل المؤقت |
|-----------------|--------|-------------|
| `followersCount` | ❌ غير متوفر | استخدام قيمة افتراضية 0 |
| `couponsCount` | ❌ غير متوفر | استخدام قيمة افتراضية 0 |
| `reviews` | ❌ غير متوفر | قائمة فارغة [] |
| `ratingSummary` | ❌ غير متوفر | كائن افتراضي بقيم صفرية |

### 4️⃣ الفئات (Categories)

| الحقل في Entity | الحقل في API Response | الحالة | ملاحظات |
|-----------------|----------------------|--------|---------|
| `categories[].id` | `data[0].categories[].id` | ✅ متوفر | int |
| `categories[].nameAr` | `data[0].categories[].name_ar` | ✅ متوفر | String |
| `categories[].nameEn` | `data[0].categories[].name_en` | ✅ متوفر | String |
| `categories[].iconUrl` | `data[0].categories[].icon_url` | ✅ متوفر | String URL كامل |

### 5️⃣ ساعات العمل (Business Hours)

| الحقل في Entity | الحقل في API Response | الحالة | ملاحظات |
|-----------------|----------------------|--------|---------|
| `hours[].dayOfWeek` | `data[0].hours[].day_of_week` | ✅ متوفر | int (0-6) |
| `hours[].openTime` | `data[0].hours[].open_time` | ✅ متوفر | String "HH:mm:ss" |
| `hours[].closeTime` | `data[0].hours[].close_time` | ✅ متوفر | String "HH:mm:ss" |
| `hours[].isClosed` | `data[0].hours[].is_closed` | ✅ متوفر | int (0 أو 1) يحتاج تحويل |

---

## 🔧 التعديلات المطلوبة

### المرحلة 1: تحديث Model لدعم fromJson

**الملف:** `lib/features/seller_flow/dashboard_seller/data/models/shop_display_model.dart`

✅ **الحالة:** تم تنفيذه بالفعل - الـ `fromJson` موجود ويعمل بشكل صحيح

### المرحلة 2: إنشاء Data Source Layer

**الملف الجديد:** `lib/features/seller_flow/dashboard_seller/data/datasources/seller_store_remote_data_source.dart`

### المرحلة 3: إنشاء Repository Layer

**الملف الجديد:** `lib/features/seller_flow/dashboard_seller/domain/repositories/seller_store_repository.dart`
**الملف الجديد:** `lib/features/seller_flow/dashboard_seller/data/repositories/seller_store_repository_impl.dart`

### المرحلة 4: إنشاء Use Case

**الملف الجديد:** `lib/features/seller_flow/dashboard_seller/domain/usecases/get_store_display_use_case.dart`

### المرحلة 5: تحديث Cubit

**الملف:** `lib/features/seller_flow/dashboard_seller/presentation/cubit/seller_store_cubit.dart`

**التغيير المطلوب:**
- استبدال `StoreDisplayModel.mock()` بـ use case حقيقي
- إضافة معالجة الأخطاء

---

## � ملاحظات مهمة

### 1. البيانات المفقودة

البيانات التالية غير متوفرة في الـ API حالياً:
- `followersCount` - سيتم استخدام 0 كقيمة افتراضية
- `couponsCount` - سيتم استخدام 0 كقيمة افتراضية  
- `reviews` - قائمة فارغة
- `ratingSummary` - كائن بقيم صفرية

### 2. التحويلات المطلوبة

- `rating_avg`: String → double
- `is_closed`: int (0/1) → bool

### 3. معالجة القيم الفارغة

الحقول التالية قد تكون فارغة أو null:
- `name` (قد يكون "")
- `description` (قد يكون "")
- `logo_url` (قد يكون null)
- `banner_url` (قد يكون null)
- `phone` (قد يكون null)

---

## 🎯 خطة التنفيذ

1. ✅ تحليل البيانات والمقارنة (تم)
2. ⏳ إنشاء Remote Data Source
3. ⏳ إنشاء Repository
4. ⏳ إنشاء Use Case
5. ⏳ تحديث Cubit
6. ⏳ اختبار التكامل
