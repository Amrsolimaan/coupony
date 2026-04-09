# تحسين ميزة تعيين العنوان الافتراضي
## Address Default Feature Enhancement

## المشكلة الأصلية / Original Problem

عند الضغط على "تعيين كافتراضي" في صفحة إدارة العناوين:
1. لم يكن هناك أي feedback بصري فوري للمستخدم
2. لم يتم إرسال التغيير للسيرفر (كان محلي فقط)
3. لم يتم إعادة ترتيب القائمة لوضع العنوان الافتراضي في الأعلى

When clicking "Set as Default" in the address management page:
1. No immediate visual feedback for the user
2. Changes were not sent to the server (local only)
3. The list was not reordered to show the default address first

---

## الحل المطبق / Implemented Solution

### 1. استخدام PATCH Endpoint الموجود / Using Existing PATCH Endpoint

بدلاً من إنشاء endpoint جديد، نستخدم الـ endpoint الموجود:

```
PATCH /api/v1/me/addresses/{id}
```

مع إرسال:
```json
{
  "is_default_shipping": true,
  "is_default_billing": true
}
```

### 2. تحديث Repository Layer

**File:** `lib/features/Profile/data/repositories/address_repository_impl.dart`

```dart
Future<Either<Failure, void>> setDefaultAddress(String id) async {
  // 1. Get the target address from local cache
  // 2. Update it with is_default flags set to true
  // 3. Send PATCH request to server
  // 4. Update local cache on success
}
```

### 3. إضافة copyWith للـ Entity

**File:** `lib/features/Profile/domain/entities/saved_address.dart`

تم إضافة method `copyWith` للـ `SavedAddress` entity لتسهيل تعديل الحقول.

### 4. تحسين Cubit Layer

**File:** `lib/features/Profile/presentation/cubit/address_cubit.dart`

```dart
Future<void> setDefaultAddress(String id) async {
  // Show loading state
  emit(const AddressSaving());
  
  final result = await repository.setDefaultAddress(id);
  
  await result.fold(
    (failure) {
      emit(AddressError(failure.message));
    },
    (_) async {
      // Reload to get updated list with proper sorting
      await loadAddresses();
      // Show success message
      emit(AddressOperationSuccess(
        message: 'address_set_default_success',
        addresses: _cachedAddresses,
      ));
    },
  );
}
```

### 5. إضافة رسائل الترجمة / Added Localization Messages

**Files:**
- `lib/core/localization/l10n/app_ar.arb`
- `lib/core/localization/l10n/app_en.arb`

```json
"address_set_default_success": "تم تعيين العنوان كافتراضي بنجاح"
"address_set_default_success": "Address set as default successfully"
```

### 6. تحديث UI Layer

**File:** `lib/features/Profile/presentation/pages/customer/address_management_page.dart`

```dart
listener: (context, state) {
  if (state is AddressOperationSuccess) {
    final message = state.message == 'address_set_default_success'
        ? l10n.address_set_default_success
        : state.message;
    context.showSuccessSnackBar(message);
  }
}
```

---

## سلوك الميزة الآن / Current Feature Behavior

### عند الضغط على "تعيين كافتراضي":

1. **Loading State** ⏳
   - يظهر loading indicator

2. **API Call** 🌐
   - يتم إرسال `PATCH /me/addresses/{id}`
   - مع body:
     ```json
     {
       "is_default_shipping": true,
       "is_default_billing": true,
       // ... other address fields
     }
     ```

3. **Local Cache Update** 💾
   - يتم تحديث الـ Hive cache محلياً
   - يتم إزالة الـ default flag من العناوين الأخرى
   - يتم تعيين الـ default flag للعنوان المختار

4. **UI Update** 🎨
   - يتم إعادة تحميل القائمة
   - العنوان الافتراضي يظهر في الأعلى (بسبب الترتيب في `getAllAddresses`)
   - يظهر badge "افتراضي" بجانب العنوان
   - يظهر border برتقالي حول الكارد

5. **Success Feedback** ✅
   - يظهر SnackBar بالرسالة: "تم تعيين العنوان كافتراضي بنجاح"

### في حالة عدم وجود اتصال بالإنترنت:

- يتم التحديث محلياً فقط
- عند عودة الاتصال، يمكن للمستخدم إعادة المحاولة

---

## الملفات المعدلة / Modified Files

1. `lib/features/Profile/domain/entities/saved_address.dart`
   - إضافة `copyWith` method

2. `lib/features/Profile/data/repositories/address_repository_impl.dart`
   - تحديث `setDefaultAddress` ليستخدم PATCH endpoint

3. `lib/features/Profile/presentation/cubit/address_cubit.dart`
   - إضافة loading state
   - إضافة success message

4. `lib/features/Profile/presentation/pages/customer/address_management_page.dart`
   - تحديث listener لعرض الرسالة المترجمة

5. `lib/core/localization/l10n/app_ar.arb`
   - إضافة `address_set_default_success`

6. `lib/core/localization/l10n/app_en.arb`
   - إضافة `address_set_default_success`

---

## متطلبات السيرفر / Server Requirements

السيرفر يجب أن يدعم:

```
PATCH /api/v1/me/addresses/{id}
```

**Request Body (multipart/form-data):**
```
_method: PATCH
is_default_shipping: 1  (or 0 for false)
is_default_billing: 1   (or 0 for false)
```

**ملاحظة مهمة:** يتم إرسال القيم البوليانية كـ `1` أو `0` لأن Laravel يتوقع هذا التنسيق في multipart/form-data requests.

**Response:**
```json
{
  "data": {
    "id": 11,
    "label": "البيت",
    "address_line1": "...",
    "is_default_shipping": true,
    "is_default_billing": true,
    // ... other fields
  }
}
```

---

## الاختبار / Testing

### خطوات الاختبار:

1. افتح صفحة إدارة العناوين
2. اضغط على القائمة المنسدلة لأي عنوان
3. اختر "تعيين كافتراضي"
4. تحقق من:
   - ✅ ظهور loading indicator
   - ✅ ظهور رسالة نجاح
   - ✅ العنوان يصبح في الأعلى
   - ✅ ظهور badge "افتراضي"
   - ✅ ظهور border برتقالي
   - ✅ إزالة الـ default من العنوان السابق

### اختبار بدون إنترنت:

1. افصل الإنترنت
2. حاول تعيين عنوان كافتراضي
3. يجب أن يعمل محلياً
4. عند عودة الإنترنت، يمكن إعادة المحاولة لمزامنة مع السيرفر

---

## ملاحظات / Notes

- الترتيب في القائمة يتم في `address_local_data_source.dart` في method `getAllAddresses`
- العناوين الافتراضية تظهر أولاً، ثم يتم الترتيب حسب تاريخ الإنشاء
- الـ badge "افتراضي" يظهر فقط للعنوان الذي `isDefault = true`
- الـ border البرتقالي يظهر فقط للعنوان الافتراضي
- يتم استخدام PATCH endpoint الموجود بدلاً من إنشاء endpoint جديد
- يتم إرسال القيم البوليانية كـ `1` أو `0` في FormData لأن Laravel يتوقع هذا التنسيق

## إصلاح مشكلة Boolean في FormData / Boolean FormData Fix

كانت هناك مشكلة في إرسال القيم البوليانية عبر FormData:
- المشكلة: `value.toString()` كان يحول `true` إلى `"true"` (string)
- Laravel validation كان يرفض `"true"` كـ string
- الحل: تحويل `true` إلى `"1"` و `false` إلى `"0"`

```dart
if (value is bool) {
  formData.fields.add(MapEntry(key, value ? '1' : '0'));
} else {
  formData.fields.add(MapEntry(key, value.toString()));
}
```

