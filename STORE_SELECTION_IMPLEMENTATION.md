# Store Selection Bottom Sheet Implementation

## ✅ تم التنفيذ بنجاح

تم إضافة ميزة اختيار المتجر من قائمة محلات التاجر في صفحة الملف الشخصي.

---

## 📁 الملفات المعدلة/المضافة

### 1. **Localization Files**
- `lib/core/localization/l10n/app_en.arb` ✅
- `lib/core/localization/l10n/app_ar.arb` ✅

**المفاتيح المضافة:**
```json
{
  "store_selection_sheet_title": "Select Your Store" / "اختر متجرك",
  "store_selection_sheet_subtitle": "Choose the store you want to manage" / "اختر المتجر الذي تريد إدارته",
  "store_status_active": "Active" / "نشط",
  "store_status_pending": "Pending Review" / "قيد المراجعة",
  "store_status_rejected": "Rejected" / "مرفوض",
  "store_not_active_pending_message": "This store cannot be selected because it is pending approval" / "لا يمكن اختيار هذا المتجر لأنه قيد المراجعة",
  "store_not_active_rejected_message": "This store cannot be selected because it was rejected" / "لا يمكن اختيار هذا المتجر لأنه تم رفضه"
}
```

### 2. **New Widget**
- `lib/features/Profile/presentation/widgets/store_selection_bottom_sheet.dart` ✅

**المكونات:**
- `StoreSelectionBottomSheet` - Main bottom sheet widget
- `_StoreCard` - Individual store card with status badge
- `_StoreLogo` - Store logo with fallback initial
- `_StatusBadge` - Color-coded status badge (Active/Pending/Rejected)

### 3. **Updated File**
- `lib/features/Profile/presentation/pages/customer/main_profile.dart` ✅

**التغييرات:**
- إضافة import للـ `store_selection_bottom_sheet.dart`
- تعديل `_buildMenuList` لتغيير نص الزر إلى "التحول إلى تاجر"
- إضافة `_handleSellerWithStores` لفتح الـ Bottom Sheet
- إزالة `_handleActiveSeller` القديم
- إزالة جميع الـ print statements

---

## 🎨 التصميم

### Bottom Sheet Header:
```
┌─────────────────────────────────────┐
│  [Drag Handle]                      │
│                                     │
│  🏪  اختر متجرك                     │
│      اختر المتجر الذي تريد إدارته   │
├─────────────────────────────────────┤
```

### Store Cards:
```
┌─────────────────────────────────────┐
│ [Logo] متجر الإلكترونيات      [→]  │
│        🟢 نشط                        │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ [Logo] متجر الملابس           [🔒]  │
│        🟡 قيد المراجعة               │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ [Logo] متجر الأثاث            [🔒]  │
│        🔴 مرفوض                      │
└─────────────────────────────────────┘
```

---

## 🔄 تدفق العمل (Flow)

```
User في main_profile.dart
  ↓
يرى زر "التحول إلى تاجر" (role='seller' && stores.isNotEmpty)
  ↓
يضغط على الزر
  ↓
يفتح Bottom Sheet يعرض جميع محلاته
  ↓
يرى:
  - محل نشط (أخضر) ✅ → قابل للضغط
  - محل معلق (أصفر) ⏳ → disabled + رسالة عند الضغط
  - محل مرفوض (أحمر) ❌ → disabled + رسالة عند الضغط
  ↓
يختار محل نشط
  ↓
يتم حفظ store.id في AuthLocalDataSource
  ↓
الانتقال إلى seller_store_page
  ↓
seller_store_page يعرض بيانات المحل المختار
```

---

## 🎯 الحالات المختلفة

| الحالة | الشرط | نص الزر | الإجراء |
|--------|-------|---------|---------|
| **تاجر مع محلات** | `roles.contains('seller') && stores.isNotEmpty` | "التحول إلى تاجر" | فتح Bottom Sheet |
| **تاجر معلق** | `roles.contains('seller_pending')` | "مراجعة الطلب المعلق" | الانتقال إلى merchant_pending |
| **عميل عادي** | لا يوجد role تاجر | "كن تاجر" | الانتقال إلى become_merchant |

---

## ✅ المميزات

1. ✅ **UI نظيف وعصري** - يتناسب مع تصميم التطبيق الحالي
2. ✅ **دعم كامل للترجمة** - عربي وإنجليزي
3. ✅ **Status Badges ملونة** - أخضر/أصفر/أحمر حسب الحالة
4. ✅ **Disabled State** - المحلات غير النشطة غير قابلة للاختيار
5. ✅ **رسائل خطأ واضحة** - للمحلات المعلقة والمرفوضة
6. ✅ **Loading State** - أثناء حفظ الاختيار
7. ✅ **Clean Architecture** - لا تعديل على seller_store_page أو app_router
8. ✅ **RTL Support** - دعم كامل للعربية

---

## 🚀 الاستخدام

```dart
// في main_profile.dart
if (roles.contains('seller') && stores.isNotEmpty) {
  merchantButtonLabel = l10n.profile_switch_to_merchant;
  merchantButtonAction = () => _handleSellerWithStores(context, stores);
}

// الدالة
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

## 📝 ملاحظات

- الـ Bottom Sheet يستخدم `showModalBottomSheet` مع `isScrollControlled: true`
- الـ Cards تستخدم `AnimatedOpacity` للـ disabled state
- الـ Status Badges تستخدم ألوان مخصصة لكل حالة
- الـ Logo يعرض الحرف الأول إذا لم يكن هناك صورة
- الـ Navigation يستخدم نفس الطريقة الحالية (`context.push` مع `extra`)

---

## ✅ تم الاختبار

- ✅ عرض المحلات النشطة
- ✅ عرض المحلات المعلقة (disabled)
- ✅ عرض المحلات المرفوضة (disabled)
- ✅ رسائل الخطأ للمحلات غير النشطة
- ✅ حفظ store ID والانتقال إلى seller_store_page
- ✅ دعم العربية والإنجليزية
- ✅ RTL Support

---

## 🎉 النتيجة

تم تنفيذ الميزة بنجاح بأسلوب نظيف وعصري يتناسب مع الـ UI الحالي، مع دعم كامل للترجمة والـ Clean Architecture.
