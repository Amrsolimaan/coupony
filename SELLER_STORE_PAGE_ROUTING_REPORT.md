# 📋 تقرير تقني: آلية عمل المسار الحالي لـ seller_store_page

## 🎯 الهدف من التقرير
توثيق كامل لكيفية عمل المسار الحالي من `main_profile.dart` إلى `seller_store_page` لتجنب التعارضات مع المسارات الجديدة.

---

## 📍 المسار الحالي (Current Route)

### نقطة البداية: `main_profile.dart`

```dart
// في _buildMenuList
if (roles.contains('seller') && stores.isNotEmpty) {
  merchantButtonLabel = l10n.profile_switch_to_merchant;
  merchantButtonAction = () => _handleSellerWithStores(context, stores);
}
```

### الدالة المسؤولة:
```dart
Future<void> _handleSellerWithStores(
  BuildContext context,
  List<dynamic> stores,
) async {
  await StoreSelectionBottomSheet.show(
    context: context,
    stores: stores.cast(),
  );
}
```

---

## 🔑 العناصر الأساسية المستخدمة

### 1. **AuthLocalDataSource - Selected Store ID**

**الموقع:** `lib/features/auth/data/datasources/auth_local_data_source.dart`

**الدالة المستخدمة:**
```dart
Future<void> saveSelectedStoreId(String storeId)
```

**الغرض:**
- حفظ `store_id` المختار في SharedPreferences
- يُستخدم لاحقاً من قبل `GetStoreDisplayUseCase` لجلب بيانات المحل

**⚠️ نقطة حرجة:**
- أي مسار جديد يجب أن يحفظ `store_id` أولاً قبل الانتقال إلى `seller_store_page`
- إذا لم يتم حفظ `store_id`، سيفشل الـ API call

---

### 2. **Navigation Parameters**

**الموقع:** `lib/config/routes/app_router.dart`

**الـ Route Definition:**
```dart
GoRoute(
  path: sellerStore,
  pageBuilder: (context, state) {
    final args = state.extra as Map<String, bool>?;
    final isGuest = args?['isGuest'] ?? false;
    final isPending = args?['isPending'] ?? false;
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<SellerStoreCubit>(
            param1: isGuest,
            param2: isPending,
          ),
        ),
        // ... other providers
      ],
      child: const SellerStorePage(),
    );
  },
),
```

**الـ Parameters المستخدمة:**
```dart
context.push(
  AppRouter.sellerStore,
  extra: {'isGuest': false, 'isPending': false},
);
```

**⚠️ نقاط حرجة:**
- `isGuest: false` → يعني المستخدم مسجل دخول
- `isPending: false` → يعني المحل نشط (approved)
- هذه القيم تحدد سلوك `SellerStoreCubit`

---

### 3. **SellerStoreCubit Behavior**

**الموقع:** `lib/features/seller_flow/dashboard_seller/presentation/cubit/seller_store_cubit.dart`

**Constructor Logic:**
```dart
SellerStoreCubit({
  required this.getStoreDisplayUseCase,
  bool isGuest = false,
  bool isPending = false,
}) : super(SellerStoreInitial(isGuest: isGuest, isPending: isPending)) {
  if (isGuest) {
    emit(const SellerStoreGuest());  // ❌ لا يستدعي API
  } else if (isPending) {
    emit(const SellerStorePending());  // ❌ لا يستدعي API
  } else {
    loadStoreDisplay();  // ✅ يستدعي API تلقائياً
  }
}
```

**⚠️ نقاط حرجة:**
- إذا `isGuest = true` → يعرض `GuestSellerViewWidget` (لا يستدعي API)
- إذا `isPending = true` → يعرض `PendingApprovalViewWidget` (لا يستدعي API)
- إذا كلاهما `false` → يستدعي `loadStoreDisplay()` تلقائياً

---

### 4. **GetStoreDisplayUseCase**

**الموقع:** `lib/features/seller_flow/dashboard_seller/domain/use_cases/get_store_display_use_case.dart`

**الـ API Call:**
```dart
Future<void> loadStoreDisplay() async {
  emit(const SellerStoreLoading());

  final result = await getStoreDisplayUseCase();
  // ✅ يستخدم selected_store_id من AuthLocalDataSource
  // ✅ API: GET /api/v1/stores/display

  result.fold(
    (failure) => emit(SellerStoreError(_mapFailureToMessage(failure))),
    (store) => emit(SellerStoreDataLoaded(store)),
  );
}
```

**⚠️ نقطة حرجة:**
- الـ Use Case يقرأ `selected_store_id` من `AuthLocalDataSource` تلقائياً
- لا يحتاج لتمرير `store_id` كـ parameter
- إذا لم يكن هناك `selected_store_id` محفوظ، سيفشل الـ API call

---

## 🔄 التدفق الكامل (Complete Flow)

```
1. User في main_profile.dart
   ↓
2. يضغط على "التحول إلى تاجر"
   ↓
3. يفتح StoreSelectionBottomSheet
   ↓
4. يختار محل نشط
   ↓
5. ✅ CRITICAL: saveSelectedStoreId(store.id)
   ↓
6. Navigator.pop() - إغلاق Bottom Sheet
   ↓
7. context.push(AppRouter.sellerStore, extra: {'isGuest': false, 'isPending': false})
   ↓
8. app_router.dart ينشئ SellerStoreCubit(isGuest: false, isPending: false)
   ↓
9. SellerStoreCubit.constructor يستدعي loadStoreDisplay() تلقائياً
   ↓
10. loadStoreDisplay() يستدعي getStoreDisplayUseCase()
    ↓
11. getStoreDisplayUseCase يقرأ selected_store_id من AuthLocalDataSource
    ↓
12. API Call: GET /api/v1/stores/display (مع selected_store_id)
    ↓
13. Response: StoreDisplayEntity
    ↓
14. emit(SellerStoreDataLoaded(store))
    ↓
15. seller_store_page يعرض البيانات
```

---

## ⚠️ نقاط حرجة للمسار الجديد

### ✅ يجب عليك:

1. **حفظ store_id أولاً:**
   ```dart
   await di.sl<AuthLocalDataSource>().saveSelectedStoreId(storeId);
   ```

2. **تمرير الـ parameters الصحيحة:**
   ```dart
   context.push(
     AppRouter.sellerStore,
     extra: {
       'isGuest': false,    // ✅ مسجل دخول
       'isPending': false,  // ✅ محل نشط
     },
   );
   ```

3. **التأكد من أن المحل نشط:**
   - إذا كان المحل `pending` → استخدم `'isPending': true`
   - إذا كان المحل `rejected` → لا تنتقل إلى seller_store_page

---

### ❌ يجب تجنب:

1. **عدم حفظ store_id:**
   ```dart
   // ❌ خطأ - سيفشل API call
   context.push(AppRouter.sellerStore, extra: {...});
   ```

2. **تمرير parameters خاطئة:**
   ```dart
   // ❌ خطأ - سيعرض GuestSellerViewWidget
   extra: {'isGuest': true, 'isPending': false}
   
   // ❌ خطأ - سيعرض PendingApprovalViewWidget
   extra: {'isGuest': false, 'isPending': true}
   ```

3. **تمرير store_id كـ parameter:**
   ```dart
   // ❌ خطأ - الـ route لا يقبل store_id
   extra: {'storeId': '123', 'isGuest': false, 'isPending': false}
   ```

---

## 📝 مثال للمسار الجديد (Template)

```dart
Future<void> _navigateToSellerStorePage(
  BuildContext context,
  String storeId,
) async {
  try {
    // ✅ الخطوة 1: حفظ store_id
    await di.sl<AuthLocalDataSource>().saveSelectedStoreId(storeId);

    if (!context.mounted) return;

    // ✅ الخطوة 2: الانتقال مع الـ parameters الصحيحة
    context.push(
      AppRouter.sellerStore,
      extra: {
        'isGuest': false,    // المستخدم مسجل دخول
        'isPending': false,  // المحل نشط
      },
    );
  } catch (e) {
    // معالجة الأخطاء
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
```

---

## 🔍 الفرق بين المسارات المختلفة

| المسار | isGuest | isPending | يستدعي API؟ | يعرض |
|--------|---------|-----------|-------------|------|
| **Guest Mode** | `true` | `false` | ❌ لا | GuestSellerViewWidget |
| **Pending Store** | `false` | `true` | ❌ لا | PendingApprovalViewWidget |
| **Active Store** | `false` | `false` | ✅ نعم | بيانات المحل الكاملة |

---

## 🎯 الخلاصة

### المسار الحالي يعتمد على:
1. ✅ حفظ `store_id` في `AuthLocalDataSource` أولاً
2. ✅ تمرير `{'isGuest': false, 'isPending': false}`
3. ✅ `SellerStoreCubit` يستدعي API تلقائياً
4. ✅ `GetStoreDisplayUseCase` يقرأ `store_id` من `AuthLocalDataSource`

### المسار الجديد يجب أن:
1. ✅ يحفظ `store_id` قبل الانتقال
2. ✅ يستخدم نفس الـ parameters
3. ✅ لا يحاول تمرير `store_id` كـ parameter
4. ✅ يتأكد من حالة المحل (active/pending/rejected)

---

## 📞 للتواصل

إذا كان لديك أي استفسار عن المسار الجديد أو تحتاج مساعدة في تجنب التعارضات، أنا جاهز! 🚀
