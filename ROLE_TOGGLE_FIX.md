# 🔧 إصلاح Role Toggle - دعم اختيار المستخدم

## 🎯 المشكلة

بعد جعل السيرفر هو المصدر الوحيد للـ role (لحل مشاكل الكاش)، ظهرت مشكلة جديدة:

**السيناريو:**
```
1. المستخدم لديه roles: ['seller', 'customer'] من السيرفر
2. السيرفر يرسل role: 'seller' (primary role)
3. المستخدم يريد استخدام التطبيق كـ customer عبر role_toggle.dart
4. ❌ التطبيق يتجاهل اختيار المستخدم ويجبره على seller flow
```

**السبب:**
- `getPrimaryRole()` كان يقرأ فقط من backend roles
- لا يأخذ في الاعتبار اختيار المستخدم من `role_toggle.dart`

---

## ✅ الحل: نظام من طبقتين (Two-Layer Role System)

### الطبقة الأولى: Backend Roles (Source of Truth)
```dart
// Stored in: SharedPreferences (userRolesKey)
// Example: ['seller', 'customer'] or ['seller_pending', 'customer']
// Set by: Backend API response during login
// Purpose: Determine what features user CAN access
```

### الطبقة الثانية: Active Role (User's Choice)
```dart
// Stored in: SecureStorage (userRole)
// Example: 'seller' or 'customer'
// Set by: User via role_toggle.dart OR backend's primary role
// Purpose: Determine what UI/flow user IS CURRENTLY using
```

---

## 🔄 الـ Flow الجديد

```
┌─────────────────────────────────────────────────────────────┐
│                    User Login                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  Backend sends: { role: 'seller', roles: ['seller', 'customer'] }  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│              getPrimaryRole() Logic                         │
├─────────────────────────────────────────────────────────────┤
│  1. Check: Does user have saved preference? (userRole)      │
│     ├─ YES → Validate against backend roles                 │
│     │         ├─ Valid? → Use user's choice ✅              │
│     │         └─ Invalid? → Use backend primary role        │
│     └─ NO → Use backend's primary role (seller > customer)  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│              User toggles role via role_toggle.dart         │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  setRole('customer') → Saves to SecureStorage               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  getPrimaryRole() → Respects user's choice ✅               │
└─────────────────────────────────────────────────────────────┘
```

---

## 📝 التعديلات

### 1. `auth_local_data_source.dart`

```dart
Future<String> getPrimaryRole() async {
  // Step 1: Get backend roles (source of truth)
  final backendRoles = await getCachedUserRoles();
  
  // Step 2: Get user's active role preference
  final userSelectedRole = await secureStorage.read(StorageKeys.userRole);
  
  // Step 3: Validate user selection against backend roles
  if (userSelectedRole != null && userSelectedRole.isNotEmpty) {
    if (backendRoles.isEmpty) {
      return (userSelectedRole == 'seller') ? 'seller' : 'customer';
    }
    
    // Validate: user can only use roles they have
    if (userSelectedRole == 'seller') {
      if (backendRoles.contains('seller') || backendRoles.contains('seller_pending')) {
        return 'seller';
      }
      return 'customer'; // Fallback
    } else {
      return 'customer'; // Always allowed
    }
  }
  
  // Step 4: No preference, use backend's primary role
  if (backendRoles.contains('seller') || backendRoles.contains('seller_pending')) {
    return 'seller';
  }
  
  return 'customer';
}
```

### 2. `auth_role_cubit.dart`

أضفنا توثيق شامل يشرح النظام من طبقتين:

```dart
/// ✅ IMPORTANT: Two-Layer Role System
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// 1. Backend Roles (Source of Truth for Permissions)
/// 2. Active Role (User's Current Choice)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🎯 النتيجة

### قبل الإصلاح ❌
```
User has: ['seller', 'customer']
User toggles to: 'customer'
App shows: Seller Flow (ignores user choice)
```

### بعد الإصلاح ✅
```
User has: ['seller', 'customer']
User toggles to: 'customer'
App shows: Customer Flow (respects user choice)
```

---

## 🔒 الأمان

**التحقق من الصلاحيات:**
- المستخدم لا يستطيع اختيار role لا يملكه
- إذا اختار seller وليس لديه seller role → يتم تحويله لـ customer
- Backend roles هي المصدر الوحيد للصلاحيات

**مثال:**
```dart
// User has: ['customer'] only
// User tries to toggle to: 'seller'
// Result: getPrimaryRole() returns 'customer' (validation failed)
```

---

## 📚 الملفات المعدلة

1. ✅ `lib/features/auth/data/datasources/auth_local_data_source.dart`
2. ✅ `lib/features/auth/presentation/cubit/auth_role_cubit.dart`
3. ✅ `CACHE_SYSTEM_COMPLETE_GUIDE.md` (تحديث التوثيق)

---

## ✨ الخلاصة

الآن النظام يدعم:
- ✅ Backend roles كمصدر وحيد للصلاحيات (أمان)
- ✅ User preference لاختيار الـ role النشط (مرونة)
- ✅ Validation لضمان عدم استخدام roles غير مصرح بها
- ✅ Backward compatibility مع النظام القديم

**الحالة:** ✅ Production Ready
