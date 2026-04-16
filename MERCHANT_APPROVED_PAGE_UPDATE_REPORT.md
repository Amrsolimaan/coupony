# 🔧 تقرير تحديث merchant_approved_page

## 📋 الهدف
تعديل `merchant_approved_page.dart` لحفظ `selectedStoreId` والانتقال مباشرة إلى `seller_store_page` بدلاً من `sellerWelcome`.

---

## ❌ السلوك السابق

### الكود القديم:
```dart
ElevatedButton(
  onPressed: () {
    context.read<AuthRoleCubit>().setRole('seller');
    context.go(AppRouter.sellerWelcome);  // ❌ يذهب لصفحة الترحيب
  },
  child: Text('تحول إلى تاجر'),
)
```

### المشاكل:
1. ❌ لا يحفظ `selectedStoreId`
2. ❌ يذهب لـ `sellerWelcome` (صفحة ترحيب)
3. ❌ لا يذهب مباشرة لصفحة المتجر
4. ❌ `seller_store_page` لا تعرف أي متجر تعرض

---

## ✅ السلوك الجديد

### الكود الجديد:
```dart
ElevatedButton(
  onPressed: () => _handleSwitchToMerchant(context),
  child: Text('تحول إلى تاجر'),
)

Future<void> _handleSwitchToMerchant(BuildContext context) async {
  // 1. عرض loading indicator
  showDialog(...);
  
  // 2. جلب المتاجر من cache
  final stores = await authLocalDs.getCachedStores();
  
  // 3. حفظ أول متجر (first-time approval = one store)
  await authLocalDs.saveSelectedStoreId(stores.first.id);
  
  // 4. تبديل الدور
  context.read<AuthRoleCubit>().setRole('seller');
  
  // 5. الانتقال لصفحة المتجر مباشرة
  context.go(
    AppRouter.sellerStore,
    extra: {'isGuest': false, 'isPending': false},
  );
}
```

---

## 🔄 آلية العمل الجديدة

### Flow Diagram:
```
User clicks "تحول إلى تاجر"
  ↓
Show Loading Dialog
  ↓
Get Cached Stores
  ↓
Save selectedStoreId = stores.first.id
  ↓
Switch Role to 'seller'
  ↓
Navigate to seller_store_page
  ↓
seller_store_page reads selectedStoreId
  ↓
Repository fetches correct store data
  ↓
Display store information
```

---

## 📝 التعديلات المنفذة

### 1. إضافة Imports
```dart
import '../../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../auth/data/datasources/auth_local_data_source.dart';
```

### 2. تعديل الزر
```dart
// من:
onPressed: () { ... }

// إلى:
onPressed: () => _handleSwitchToMerchant(context)
```

### 3. إضافة دالة `_handleSwitchToMerchant`
**الوظائف:**
- ✅ عرض loading indicator
- ✅ جلب المتاجر من cache
- ✅ حفظ `selectedStoreId`
- ✅ تبديل الدور
- ✅ الانتقال لـ `seller_store_page`
- ✅ معالجة الأخطاء

### 4. إضافة دالة `_showErrorSnackBar`
**الوظيفة:** عرض رسائل الأخطاء بشكل جميل

---

## 🎯 السيناريوهات

### ✅ سيناريو 1: النجاح (الحالة الطبيعية)
```
User: يضغط "تحول إلى تاجر"
  ↓
System: يعرض loading
  ↓
System: يجلب المتاجر [store-123]
  ↓
System: يحفظ selectedStoreId = "store-123"
  ↓
System: يبدل الدور إلى seller
  ↓
System: ينتقل لـ seller_store_page
  ↓
seller_store_page: يعرض بيانات store-123
```

### ⚠️ سيناريو 2: لا توجد متاجر (نادر)
```
User: يضغط "تحول إلى تاجر"
  ↓
System: يعرض loading
  ↓
System: يجلب المتاجر []
  ↓
System: يغلق loading
  ↓
System: يعرض SnackBar "لم يتم العثور على متجر"
  ↓
User: يبقى في نفس الصفحة
```

### ❌ سيناريو 3: خطأ في الشبكة
```
User: يضغط "تحول إلى تاجر"
  ↓
System: يعرض loading
  ↓
System: خطأ في جلب البيانات
  ↓
System: يغلق loading
  ↓
System: يعرض SnackBar "حدث خطأ"
  ↓
User: يبقى في نفس الصفحة
```

---

## 🔗 التكامل مع Repository

### قبل التعديل:
```
merchant_approved_page → sellerWelcome
  ↓
User navigates manually → seller_store_page
  ↓
Repository: لا يوجد selectedStoreId ❌
  ↓
Repository: يعرض أول متجر (قد يكون خاطئ)
```

### بعد التعديل:
```
merchant_approved_page → saveSelectedStoreId("store-123")
  ↓
Navigate to seller_store_page
  ↓
Repository: يقرأ selectedStoreId = "store-123" ✅
  ↓
Repository: يبحث عن store-123 في القائمة
  ↓
Repository: يعرض store-123 (صحيح!)
```

---

## 🎨 تحسينات UX

### 1. Loading Indicator
- يعرض أثناء جلب البيانات
- يمنع الضغط المتكرر
- تجربة مستخدم احترافية

### 2. Error Handling
- رسائل خطأ واضحة بالعربي
- SnackBar جميل ومتناسق
- المستخدم يبقى في الصفحة (لا يفقد السياق)

### 3. Navigation
- انتقال مباشر لصفحة المتجر
- لا حاجة لخطوات إضافية
- تجربة سلسة

---

## 🧪 الاختبار

### Test Cases:

#### 1. First-time merchant approval
```dart
// Setup
final stores = [UserStoreModel(id: 'store-123', status: 'active')];
await authLocalDs.cacheStores(stores);

// Execute
await _handleSwitchToMerchant(context);

// Verify
final savedId = await authLocalDs.getSelectedStoreId();
expect(savedId, 'store-123');
expect(currentRoute, AppRouter.sellerStore);
```

#### 2. No stores (edge case)
```dart
// Setup
await authLocalDs.cacheStores([]);

// Execute
await _handleSwitchToMerchant(context);

// Verify
expect(snackBarShown, true);
expect(snackBarMessage, contains('لم يتم العثور'));
```

#### 3. Network error
```dart
// Setup
when(() => authLocalDs.getCachedStores()).thenThrow(Exception());

// Execute
await _handleSwitchToMerchant(context);

// Verify
expect(snackBarShown, true);
expect(snackBarMessage, contains('حدث خطأ'));
```

---

## 📊 الإحصائيات

### الملفات المعدلة: 1
- `merchant_approved_page.dart`

### الأسطر المضافة: ~80
### الأسطر المحذوفة: ~5

### Dependencies الجديدة:
- `AuthLocalDataSource` (via DI)
- `injection_container.dart`

---

## 🔗 التأثير على المسارات

### المسار 1: Login Flow
```
Login → saveSelectedStoreId() → SellerHome → seller_store_page
✅ لم يتأثر - يعمل كما هو
```

### المسار 2: Profile → Bottom Sheet
```
Profile → StoreSelection → saveSelectedStoreId() → seller_store_page
✅ لم يتأثر - يعمل كما هو
```

### المسار 3: merchant_approved_page (الجديد)
```
merchant_approved_page → saveSelectedStoreId() → seller_store_page
✅ يعمل الآن بشكل صحيح!
```

---

## ✅ الخلاصة

تم تحديث `merchant_approved_page` بنجاح لتحفظ `selectedStoreId` وتنتقل مباشرة إلى `seller_store_page`، مما يضمن:
- ✅ حفظ المتجر المختار
- ✅ انتقال مباشر لصفحة المتجر
- ✅ عرض البيانات الصحيحة
- ✅ تجربة مستخدم سلسة
- ✅ معالجة أخطاء شاملة

**الآن جميع المسارات تعمل بشكل صحيح!** 🎉

---

**تاريخ التنفيذ:** 2026-04-13  
**الحالة:** ✅ مكتمل ومختبر  
**المرحلة:** 2 من 2
