# 📚 دليل نظام الكاش الكامل - Cache System Guide

## 🎯 نظرة عامة

نظام الكاش في التطبيق يستخدم **مستويين من التخزين** لحفظ بيانات المستخدم محلياً:

1. **SecureStorage** (flutter_secure_storage) - للبيانات الحساسة
2. **SharedPreferences** - للبيانات غير الحساسة

---

## 🗂️ هيكل نظام الكاش

```
┌─────────────────────────────────────────────────────────┐
│                    Cache System                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────┐      ┌──────────────────────┐   │
│  │ SecureStorage    │      │ SharedPreferences    │   │
│  │ (Encrypted)      │      │ (Plain Text)         │   │
│  ├──────────────────┤      ├──────────────────────┤   │
│  │ • authToken      │      │ • isGuest            │   │
│  │ • refreshToken   │      │ • {userId}_onboard.. │   │
│  │ • userId         │      │ • {userId}_stores    │   │
│  │ • userRole       │      │ • {userId}_roles     │   │
│  │ • fcmToken       │      │ • saved_emails       │   │
│  │ • selectedStoreId│      │ • hasPassedGateway   │   │
│  └──────────────────┘      └──────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🔐 SecureStorage - البيانات الحساسة

### ما يتم تخزينه:

#### 1. **authToken** (Access Token)
```dart
StorageKeys.authToken
```
**الاستخدام:**
- يُحفظ عند: Login, Register, OTP Verification, Google Sign-In
- يُقرأ في: كل API request (عبر DioClient interceptor)
- يُمسح عند: Logout, Session expiry
- **الغرض:** إثبات هوية المستخدم في كل طلب للـ API

**مثال:**
```dart
// الحفظ
await secureStorage.write(StorageKeys.authToken, user.accessToken);

// القراءة
final token = await secureStorage.read(StorageKeys.authToken);

// الحذف
await secureStorage.delete(StorageKeys.authToken);
```

---

#### 2. **refreshToken**
```dart
StorageKeys.refreshToken
```
**الاستخدام:**
- يُحفظ عند: Login, Register, OTP Verification
- يُقرأ عند: انتهاء صلاحية access token
- يُمسح عند: Logout
- **الغرض:** تجديد access token بدون إعادة تسجيل دخول

**Flow:**
```
API Request → 401 Unauthorized
    ↓
Read refreshToken
    ↓
Call /auth/refresh
    ↓
Get new accessToken
    ↓
Retry original request
```

---

#### 3. **userId**
```dart
StorageKeys.userId
```
**الاستخدام:**
- يُحفظ عند: Login (email أو id)
- يُقرأ في: كل عملية user-scoped cache
- يُمسح عند: Logout
- **الغرض:** ربط البيانات المحلية بالمستخدم الصحيح

**مثال:**
```dart
// الحفظ
final scopedId = user.email.isNotEmpty ? user.email : user.id.toString();
await secureStorage.write(StorageKeys.userId, scopedId);

// الاستخدام في user-scoped keys
String _getUserKey(String baseKey, String userId) {
  return '${userId}_$baseKey';
}
// مثال: "user@example.com_onboarding_completed"
```

**أهمية:**
- يمنع اختلاط البيانات بين users على نفس الجهاز
- كل user له cache منفصل

---

#### 4. **userRole**
```dart
StorageKeys.userRole
```
**الاستخدام:**
- يُحفظ عند: Login (من backend)
- يُقرأ في: AuthRoleCubit (للـ UI/theme)
- يُمسح عند: Logout
- **القيم:** 'customer' أو 'seller'
- **الغرض:** تحديد theme وواجهة المستخدم

**مثال:**
```dart
// الحفظ (دائماً من backend)
await secureStorage.write(StorageKeys.userRole, user.role);

// القراءة (مع fallback)
final role = await getPrimaryRole(); // يقرأ من roles array أولاً
```

---

#### 5. **fcmToken** (Firebase Cloud Messaging)
```dart
StorageKeys.fcmToken
```
**الاستخدام:**
- يُحفظ عند: Login (بعد الحصول عليه من Firebase)
- يُرسل للـ backend: لربطه بالحساب
- يُمسح عند: Logout
- **الغرض:** استقبال Push Notifications

---

#### 6. **selectedStoreId** (للـ Sellers فقط)
```dart
StorageKeys.selectedStoreId
```
**الاستخدام:**
- يُحفظ عند: اختيار store من StoreSelectionPage
- يُقرأ في: Seller Dashboard (لتحديد أي store يتم العمل عليه)
- يُمسح عند: Logout
- **الغرض:** تحديد المتجر النشط للـ seller الذي لديه عدة متاجر

---

## 📦 SharedPreferences - البيانات غير الحساسة

### ما يتم تخزينه:

#### 1. **isGuest**
```dart
StorageKeys.isGuest
```
**الاستخدام:**
- يُحفظ عند: اختيار "Continue as Guest"
- يُقرأ في: Splash Screen, Auth Guard
- يُمسح عند: Logout, Login
- **الغرض:** السماح بتصفح التطبيق بدون تسجيل دخول

**Flow:**
```
User يختار "Continue as Guest"
    ↓
isGuest = true
    ↓
Splash Screen يقرأ isGuest
    ↓
يوجه للـ home مباشرة (بدون auth check)
```

---

#### 2. **{userId}_onboarding_completed**
```dart
StorageKeys.onboardingCompletedKey
```
**الاستخدام:**
- يُحفظ عند: إكمال onboarding (customer أو seller)
- يُقرأ في: Splash Screen, Login flow
- يُمسح عند: Logout
- **الغرض:** تحديد إذا كان المستخدم أكمل الـ onboarding أم لا

**⚠️ ملاحظة مهمة:**
هذا الـ flag يُحفظ أيضاً في Hive (داخل UserPreferencesModel)، لكن:
- **SharedPreferences:** للـ routing السريع في Splash (1ms)
- **Hive:** للبيانات الكاملة + personalization (10ms)
- **لا تعارض:** يتم sync بينهم دائماً

**مثال:**
```dart
// الحفظ (user-scoped)
final userId = await _requireUserId();
await sharedPrefs.setBool(
  '${userId}_onboarding_completed',
  true
);

// القراءة
final isCompleted = await getOnboardingCompleted(); // returns bool
```

**Flow:**
```
Login Success
    ↓
isOnboardingCompleted?
    ↙         ↘
  true       false
    ↓          ↓
  Home    Onboarding
```

---

#### 3. **{userId}_store_created** (للـ Sellers)
```dart
StorageKeys.storeCreatedKey
```
**الاستخدام:**
- يُحفظ عند: إنشاء store بنجاح
- يُقرأ في: Seller routing logic
- يُمسح عند: Logout
- **الغرض:** تحديد إذا كان الـ seller أنشأ متجر أم لا

**Flow:**
```
Seller Login
    ↓
isStoreCreated?
    ↙         ↘
  true       false
    ↓          ↓
Store Under  Create Store
  Review       Screen
```

---

#### 4. **{userId}_cached_stores** (للـ Sellers)
```dart
StorageKeys.cachedStoresKey
```
**الاستخدام:**
- يُحفظ عند: Login (من API response)
- يُقرأ في: Seller routing, Store selection
- يُمسح عند: Logout
- **الغرض:** قائمة متاجر الـ seller مع حالاتها

**البيانات المحفوظة:**
```json
[
  {
    "id": "store_123",
    "name": "My Store",
    "status": "active",
    "isPending": false,
    "isActive": true
  },
  {
    "id": "store_456",
    "name": "Second Store",
    "status": "pending",
    "isPending": true,
    "isActive": false
  }
]
```

**Flow:**
```
Seller Login
    ↓
Read cached_stores
    ↓
stores.isEmpty?
    ↙         ↘
  true       false
    ↓          ↓
Create     Check stores status
Store      (pending/active/multiple)
```

---

#### 5. **{userId}_user_roles** (Multi-Role Support)
```dart
StorageKeys.userRolesKey
```
**الاستخدام:**
- يُحفظ عند: Login (من API response)
- يُقرأ في: Routing logic, Role determination
- يُمسح عند: Logout
- **الغرض:** دعم المستخدمين الذين لديهم أكثر من role

**القيم الممكنة:**
```
['customer']                      → customer فقط
['seller', 'customer']            → seller approved
['seller_pending', 'customer']    → seller في انتظار الموافقة
```

**مثال:**
```dart
// الحفظ
await cacheUserRoles(['seller_pending', 'customer']);

// القراءة
final roles = await getCachedUserRoles();
// returns: ['seller_pending', 'customer']

// تحديد primary role
final primaryRole = await getPrimaryRole();
// returns: 'seller' (لأن يحتوي seller_pending)
```

---

#### 6. **saved_emails** (Remember Me Feature)
```dart
// Custom key managed by SavedEmailsService
```
**الاستخدام:**
- يُحفظ عند: Login مع "Remember Me" checked
- يُقرأ في: Login Screen (للـ suggestions dropdown)
- يُمسح عند: User يحذف email من القائمة
- **الغرض:** تذكر الإيميلات المستخدمة سابقاً

**مثال:**
```dart
// الحفظ
emailsService.saveEmail('user@example.com');

// القراءة
final emails = emailsService.getSavedEmails();
// returns: ['user@example.com', 'another@example.com']

// الحذف
emailsService.removeEmail('user@example.com');
```

---

#### 7. **hasPassedWelcomeGateway**
```dart
StorageKeys.hasPassedWelcomeGateway
```
**الاستخدام:**
- يُحفظ عند: اختيار Login أو Guest من Welcome Gateway
- يُقرأ في: Splash Screen
- لا يُمسح عند: Logout (يبقى للأبد)
- **الغرض:** عدم إظهار Welcome Gateway مرة أخرى

**Flow:**
```
First App Launch
    ↓
hasPassedWelcomeGateway?
    ↙              ↘
  false           true
    ↓              ↓
Show Welcome    Check Auth
  Gateway         Status
```

---

## 🔄 دورة حياة الكاش (Cache Lifecycle)

### 1️⃣ عند تسجيل الدخول (Login)

```
User يدخل email + password
    ↓
API: POST /auth/login
    ↓
Response: {
  accessToken: "...",
  refreshToken: "...",
  user: {
    id: 123,
    email: "user@example.com",
    role: "customer",
    roles: ["customer"],
    isOnboardingCompleted: true,
    stores: []
  }
}
    ↓
cacheUser() يحفظ:
    ├─ SecureStorage:
    │   ├─ authToken = accessToken
    │   ├─ refreshToken = refreshToken
    │   ├─ userId = email
    │   ├─ userRole = role
    │   └─ fcmToken = (من Firebase)
    │
    └─ SharedPreferences:
        ├─ isGuest = false
        ├─ {userId}_onboarding_completed = true
        ├─ {userId}_store_created = false
        ├─ {userId}_cached_stores = []
        └─ {userId}_user_roles = ["customer"]
    ↓
Navigation حسب role و onboarding status
```

---

### 2️⃣ عند بدء التطبيق (Cold Start)

```
App Launch
    ↓
Splash Screen
    ↓
1. Check Language Preference
    ↓
2. Check Permissions Status
    ↓
3. Check hasPassedWelcomeGateway
    ↓
4. _checkOnboardingStatus():
    ├─ Read authToken
    ├─ Read isGuest
    │
    ├─ if (isGuest) → Home
    │
    ├─ if (no token) → Login
    │
    └─ if (has token):
        ├─ Read {userId}_onboarding_completed
        ├─ Read {userId}_store_created
        ├─ Read {userId}_cached_stores
        ├─ Read {userId}_user_roles
        │
        └─ Navigate based on:
            ├─ role (customer/seller)
            ├─ onboarding status
            └─ store status (for sellers)
```

---

### 3️⃣ عند تسجيل الخروج (Logout)

```
User يضغط Logout
    ↓
logout() في AuthRepository:
    │
    ├─ 1. API: POST /auth/logout (best-effort)
    │
    ├─ 2. notificationService.deleteFCMToken()
    │
    ├─ 3. clearSessionFlags():
    │   └─ SharedPreferences:
    │       ├─ Remove isGuest
    │       ├─ Remove {userId}_onboarding_completed
    │       ├─ Remove {userId}_store_created
    │       ├─ Remove {userId}_cached_stores
    │       └─ Remove {userId}_user_roles
    │
    ├─ 4. clearUser():
    │   └─ SecureStorage:
    │       ├─ Delete authToken
    │       ├─ Delete refreshToken
    │       ├─ Delete userId
    │       ├─ Delete userRole
    │       ├─ Delete fcmToken
    │       └─ Delete selectedStoreId
    │
    ├─ 5. clearFeatureCache():
    │   └─ Hive:
    │       ├─ Clear onboarding_preferences_box
    │       └─ Clear seller_onboarding_preferences_box
    │
    └─ 6. GoogleSignInService().signOut()
    ↓
Navigate to Login
```

**⚠️ ملاحظة مهمة:**
- `clearSessionFlags()` يجب أن يُستدعى **قبل** `clearUser()`
- لأنه يحتاج `userId` لحذف الـ user-scoped keys
- إذا تم حذف `userId` أولاً، لن نستطيع حذف الـ user-scoped keys

---

## 🎯 الاستخدامات الرئيسية

### 1. **Authentication & Authorization**

```dart
// فحص إذا كان المستخدم مسجل دخول
final token = await authLocalDs.getAccessToken();
if (token != null && token.isNotEmpty) {
  // User is authenticated
}

// فحص الـ role
final role = await authLocalDs.getPrimaryRole();
if (role == 'seller') {
  // Show seller UI
} else {
  // Show customer UI
}
```

---

### 2. **Routing & Navigation**

```dart
// في Splash Screen
final isOnboardingCompleted = await authLocalDs.getOnboardingCompleted();

if (isOnboardingCompleted) {
  context.go(AppRouter.home);
} else {
  context.go(AppRouter.onboarding);
}
```

---

### 3. **Multi-User Support**

```dart
// User A logs in
userId = "userA@example.com"
Keys created:
  - "userA@example.com_onboarding_completed"
  - "userA@example.com_cached_stores"

// User A logs out
clearSessionFlags() removes:
  - "userA@example.com_onboarding_completed"
  - "userA@example.com_cached_stores"

// User B logs in
userId = "userB@example.com"
Keys created:
  - "userB@example.com_onboarding_completed"
  - "userB@example.com_cached_stores"

// ✅ No data leakage between users
```

---

### 4. **Offline-First Approach**

```dart
// عند Login
1. API call → Get user data
2. cacheUser() → Save locally
3. Navigate

// عند Cold Start
1. Read from cache (instant)
2. Navigate immediately
3. (Optional) Refresh from API in background
```

---

## 🛡️ الأمان والحماية

### 1. **SecureStorage Encryption**
```
authToken → Encrypted → Keychain (iOS) / KeyStore (Android)
```
- لا يمكن قراءتها من خارج التطبيق
- محمية بـ device encryption

### 2. **User-Scoped Keys**
```
userId = "user@example.com"
key = "user@example.com_onboarding_completed"
```
- كل user له cache منفصل
- لا اختلاط بين البيانات

### 3. **Safe Defaults**
```dart
try {
  return await getOnboardingCompleted();
} catch (e) {
  return false; // Safe default
}
```
- عند الفشل، نرجع قيمة آمنة
- لا crashes

### 4. **Logout Cleanup**
```
clearSessionFlags() → Remove user data
clearUser() → Remove tokens
clearFeatureCache() → Remove preferences
```
- تنظيف شامل عند logout
- لا تسريب للبيانات

---

## 📊 أمثلة عملية

### مثال 1: Customer Login Flow

```dart
// 1. User يسجل دخول
await loginUseCase(email: "customer@example.com", password: "***");

// 2. API Response
{
  "accessToken": "eyJ...",
  "user": {
    "email": "customer@example.com",
    "role": "customer",
    "roles": ["customer"],
    "isOnboardingCompleted": true
  }
}

// 3. Cache
SecureStorage:
  authToken = "eyJ..."
  userId = "customer@example.com"
  userRole = "customer"

SharedPreferences:
  "customer@example.com_onboarding_completed" = true
  "customer@example.com_user_roles" = "customer"

// 4. Navigation
isOnboardingCompleted = true
→ Navigate to /home
```

---

### مثال 2: Seller with Pending Store

```dart
// 1. Seller يسجل دخول
await loginUseCase(email: "seller@example.com", password: "***");

// 2. API Response
{
  "accessToken": "eyJ...",
  "user": {
    "email": "seller@example.com",
    "role": "customer",
    "roles": ["seller_pending", "customer"],
    "isOnboardingCompleted": true,
    "stores": [
      {
        "id": "store_123",
        "status": "pending"
      }
    ]
  }
}

// 3. Cache
SecureStorage:
  authToken = "eyJ..."
  userId = "seller@example.com"
  userRole = "customer"

SharedPreferences:
  "seller@example.com_onboarding_completed" = true
  "seller@example.com_user_roles" = "seller_pending,customer"
  "seller@example.com_cached_stores" = '[{"id":"store_123","status":"pending"}]'

// 4. Routing Logic
getPrimaryRole():
  roles.contains('seller_pending') → true
  → return 'seller'

SellerRoutingResolver:
  roles.contains('seller_pending') → true
  → Navigate to /store-under-review
```

---

### مثال 3: Multiple Users Same Device

```dart
// User A Login
userId = "userA@example.com"
Cache:
  "userA@example.com_onboarding_completed" = true
  "userA@example.com_user_roles" = "customer"

// User A Logout
clearSessionFlags():
  Remove "userA@example.com_onboarding_completed"
  Remove "userA@example.com_user_roles"
clearUser():
  Delete userId

// User B Login
userId = "userB@example.com"
Cache:
  "userB@example.com_onboarding_completed" = false
  "userB@example.com_user_roles" = "customer"

// ✅ User B لا يرى بيانات User A
```

---

## 🔍 Debugging & Troubleshooting

### كيف تفحص الكاش؟

#### 1. **SecureStorage (صعب الفحص)**
```dart
// في الكود
final token = await secureStorage.read(StorageKeys.authToken);
print('Token: $token');
```

#### 2. **SharedPreferences (سهل الفحص)**
```dart
// في الكود
final prefs = await SharedPreferences.getInstance();
final keys = prefs.getKeys();
print('All keys: $keys');

for (var key in keys) {
  print('$key: ${prefs.get(key)}');
}
```

#### 3. **Logs في الكود**
```dart
// الآن كل الدوال تطبع logs
print('💾 cacheUser — email: ${user.email}');
print('✅ Loaded primary role: $role');
print('⚠️ getCachedUserRoles failed: $e');
```

---

### مشاكل شائعة وحلولها:

#### مشكلة: "User يرى بيانات user آخر"
```
السبب: clearSessionFlags() فشل
الحل: ✅ تم إضافة try-catch في جلسة 3
```

#### مشكلة: "App crashes عند cold start"
```
السبب: getOnboardingCompleted() يرمي exception
الحل: ✅ تم إضافة safe defaults في جلسة 2
```

#### مشكلة: "UI customer لكن routing seller"
```
السبب: تضارب بين userRole و userRoles
الحل: ✅ تم توحيد المصدر في جلسة 5
```

---

## 📝 Best Practices

### ✅ Do's

1. **استخدم user-scoped keys دائماً**
```dart
final key = _getUserKey(StorageKeys.onboardingCompletedKey, userId);
```

2. **استخدم safe defaults**
```dart
try {
  return await getData();
} catch (e) {
  return defaultValue; // Safe
}
```

3. **امسح البيانات عند logout**
```dart
await clearSessionFlags(); // First
await clearUser();          // Second
```

4. **استخدم getPrimaryRole() للـ role**
```dart
final role = await authLocalDs.getPrimaryRole();
```

### ❌ Don'ts

1. **لا تحفظ بيانات حساسة في SharedPreferences**
```dart
// ❌ Wrong
await sharedPrefs.setString('password', password);

// ✅ Correct
await secureStorage.write('authToken', token);
```

2. **لا تستخدم flat keys للـ user data**
```dart
// ❌ Wrong
await sharedPrefs.setBool('onboarding_completed', true);

// ✅ Correct
await sharedPrefs.setBool('${userId}_onboarding_completed', true);
```

3. **لا ترمي exceptions في getters**
```dart
// ❌ Wrong
Future<bool> getData() async {
  final userId = await _requireUserId(); // throws
  return sharedPrefs.getBool(key) ?? false;
}

// ✅ Correct
Future<bool> getData() async {
  try {
    final userId = await _requireUserId();
    return sharedPrefs.getBool(key) ?? false;
  } catch (e) {
    return false; // Safe default
  }
}
```

---

## 🎓 للفريق: نقاط مهمة

### 1. **الكاش ليس Database**
- استخدمه للـ session data فقط
- لا تحفظ بيانات كبيرة
- لا تعتمد عليه كـ source of truth

### 2. **Backend هو Source of Truth**
- الكاش للـ performance فقط
- دائماً sync مع backend
- عند التضارب، backend يفوز

### 3. **User-Scoped Keys ضرورية**
- تمنع data leakage
- تدعم multiple users
- سهلة الحذف عند logout

### 4. **Safe Defaults مهمة**
- تمنع crashes
- تحسن UX
- تجعل التطبيق fault-tolerant

### 5. **Logout Cleanup حرج**
- clearSessionFlags() أولاً
- clearUser() ثانياً
- لا تنسى Hive boxes

---

## 🗑️ المسح اليدوي للكاش (Manual Cache Cleanup)

### الموقع:
**Settings Page** → قسم "إدارة التخزين" → زر "مسح الكاش"

### ماذا يتم مسحه؟ (آمن ✅)
```dart
// API Cache Boxes (safe to delete)
- coupons_box          // الكوبونات المحفوظة
- stores_box           // المتاجر المحفوظة
- categories_box       // التصنيفات المحفوظة
- public_products_box  // المنتجات المحفوظة
- Media Files          // الصور والفيديوهات المؤقتة
```

### ماذا لا يتم مسحه؟ (محمي ❌)
```dart
// Critical Data (preserved)
- Auth Tokens (SecureStorage)
- User Preferences (onboarding_preferences_box)
- Permission Status (permissions_box)
- Settings (settings_box)
- User Profile Data
```

### الكود:
```dart
// في settings_page.dart
Future<void> _clearSafeCache(BuildContext context) async {
  await cacheService.clearBox('coupons_box');
  await cacheService.clearBox('stores_box');
  await cacheService.clearBox('categories_box');
  await cacheService.clearBox('public_products_box');
  await cacheService.performManualCleanup(); // Media files
}
```

### الفائدة:
- تحرير مساحة التخزين
- حل مشاكل البيانات القديمة
- إعادة تحميل البيانات من السيرفر

---

## 📚 الخلاصة

**نظام الكاش يستخدم في:**
1. ✅ Authentication (tokens, userId)
2. ✅ User Profile (role, roles)
3. ✅ Onboarding Status (completed flag)
4. ✅ Seller Data (stores, selectedStoreId)
5. ✅ Guest Mode (isGuest flag)
6. ✅ Remember Me (saved emails)
7. ✅ Navigation (routing decisions)
8. ✅ Offline-First (instant app start)

**الفوائد:**
- ⚡ Performance (instant load)
- 🔒 Security (encrypted storage)
- 👥 Multi-User Support (user-scoped)
- 💪 Reliability (safe defaults)
- 🎯 Consistency (single source)

**الملفات الرئيسية:**
- `auth_local_data_source.dart` - Core cache logic
- `storage_keys.dart` - All cache keys
- `auth_repository_impl.dart` - Cache orchestration
- `splash_screen.dart` - Cache reading on start
- `settings_page.dart` - Manual cache cleanup

---

**تاريخ:** اليوم
**الإصدار:** 2.1 (بعد إضافة Manual Cleanup + Role Toggle Fix)
**الحالة:** ✅ Production Ready


---

## 📦 Hive - التخزين المحلي المتقدم (Level 3)

### 🎯 ما هو Hive؟

Hive هو **NoSQL database** محلي سريع جداً، يُستخدم لتخزين:
- بيانات معقدة (Objects, Lists, Maps)
- بيانات كبيرة الحجم
- بيانات تحتاج TTL (Time-To-Live)
- Media metadata
- User preferences

---

### 🗂️ Hive Boxes المستخدمة

```dart
// في StorageKeys.dart
static const String couponsBox = 'coupons_box';
static const String storesBox = 'stores_box';
static const String categoriesBox = 'categories_box';
static const String onboardingPreferencesBox = 'onboarding_preferences_box';
static const String sellerOnboardingPreferencesBox = 'seller_onboarding_preferences_box';
static const String permissionsBox = 'permissions_box';
static const String mediaMetadataBox = 'media_metadata_box';
static const String publicProductsBox = 'public_products_box';
static const String settingsBox = 'settings_box';
```

---

### 📊 تفصيل كل Box

#### 1. **onboardingPreferencesBox** (Customer Preferences)
```dart
Box<UserPreferencesModel>
```

**ما يُحفظ:**
```json
{
  "selectedCategories": ["electronics", "fashion", "food"],
  "budget": "medium",
  "shoppingStyle": "online",
  "categoryScores": {
    "electronics": 75,
    "fashion": 50,
    "food": 30
  },
  "seenProductIds": ["prod_123", "prod_456"],
  "lastDecayDate": "2024-01-15T10:30:00Z"
}
```

**الاستخدام:**
- يُحفظ عند: إكمال customer onboarding
- يُقرأ في: Home feed (للتخصيص)
- يُحدث عند: User interaction (clicks, favorites)
- يُمسح عند: Logout

**Interest Tracking System:**
```dart
// عند click على product
await updateCategoryScore(
  categoryId: 'electronics',
  points: 1  // productClickScore
);

// عند view details
await updateCategoryScore(
  categoryId: 'electronics',
  points: 5  // viewDetailsScore
);

// عند add to favorites
await updateCategoryScore(
  categoryId: 'electronics',
  points: 15  // addToFavoritesScore
);

// عند conversion (purchase)
await updateCategoryScore(
  categoryId: 'electronics',
  points: 20  // conversionScore
);
```

**Decay System:**
```dart
// كل يوم، يتم تطبيق decay factor (0.95x)
// مثال:
Initial score: 100
After 1 day: 95
After 2 days: 90
After 7 days: 70
After 30 days: 21

// الهدف: تقليل تأثير الاهتمامات القديمة
```

---

#### 2. **sellerOnboardingPreferencesBox** (Seller Preferences)
```dart
Box<SellerPreferencesModel>
```

**ما يُحفظ:**
```json
{
  "businessType": "retail",
  "priceCategory": "medium",
  "targetAudience": ["young_adults", "families"],
  "deliveryOptions": ["pickup", "delivery"]
}
```

**الاستخدام:**
- يُحفظ عند: إكمال seller onboarding
- يُقرأ في: Seller dashboard (للتخصيص)
- يُمسح عند: Logout

---

#### 3. **couponsBox** (Coupons Cache)
```dart
Box<List<CouponModel>>
```

**ما يُحفظ:**
```json
{
  "featured_coupons": [
    {
      "id": "coupon_123",
      "title": "50% Off Electronics",
      "discount": 50,
      "expiryDate": "2024-12-31"
    }
  ],
  "featured_coupons_timestamp": "2024-01-15T10:00:00Z"
}
```

**TTL:** 15 دقيقة (AppConstants.couponsCacheDuration)

**الاستخدام:**
- يُحفظ عند: API call success
- يُقرأ في: Home screen (offline-first)
- يُمسح عند: TTL expired أو manual refresh

---

#### 4. **storesBox** (Stores Cache)
```dart
Box<List<StoreModel>>
```

**ما يُحفظ:**
```json
{
  "nearby_stores": [
    {
      "id": "store_123",
      "name": "Tech Store",
      "location": {"lat": 30.0, "lng": 31.0},
      "distance": 2.5
    }
  ],
  "nearby_stores_timestamp": "2024-01-15T10:00:00Z"
}
```

**TTL:** 30 دقيقة

**الاستخدام:**
- يُحفظ عند: API call success
- يُقرأ في: Stores list (offline-first)
- يُمسح عند: TTL expired

---

#### 5. **categoriesBox** (Categories Cache)
```dart
Box<List<CategoryModel>>
```

**ما يُحفظ:**
```json
{
  "categories_list": [
    {"id": "cat_1", "name": "Electronics"},
    {"id": "cat_2", "name": "Fashion"}
  ],
  "public_categories_list": [...],
  "categories_list_timestamp": "2024-01-15T10:00:00Z"
}
```

**TTL:** 1 ساعة

---

#### 6. **publicProductsBox** (Product Details Cache)
```dart
Box<ProductDetailModel>
```

**ما يُحفظ:**
```json
{
  "public_product_prod_123": {
    "id": "prod_123",
    "name": "iPhone 15",
    "price": 999,
    "images": [...]
  },
  "public_product_prod_123_timestamp": "2024-01-15T10:00:00Z",
  
  "public_products_page1": {
    "products": [...],
    "pagination": {...}
  }
}
```

**TTL:** 15 دقيقة

**الاستخدام:**
- يُحفظ عند: View product details
- يُقرأ في: Product detail page (instant load)
- يُمسح عند: TTL expired

---

#### 7. **mediaMetadataBox** (Media Files Metadata)
```dart
Box<Map>
```

**⚠️ مهم جداً:** Hive لا يحفظ الصور نفسها!

**ما يُحفظ في Hive:**
```json
{
  "https://example.com/image.jpg": {
    "url": "https://example.com/image.jpg",
    "path": "/data/user/0/com.app/media/images/abc123.jpg",
    "type": "MediaType.image",
    "size": 245678,
    "timestamp": "2024-01-15T10:00:00Z"
  }
}
```

**ما يُحفظ في File System:**
```
/data/user/0/com.app/media/
  ├── images/
  │   ├── abc123.jpg  ← الصورة الفعلية
  │   └── def456.jpg
  └── videos/
      └── xyz789.mp4
```

**TTL:** 7 أيام (AppConstants.mediaCacheDuration)

**Quota:** 100 MB (AppConstants.maxMediaCacheSizeMB)

**الاستخدام:**
```dart
// حفظ صورة
final path = await saveMediaFile(
  url: 'https://example.com/image.jpg',
  bytes: imageBytes,
  type: MediaType.image,
);

// قراءة صورة
final path = await getMediaFilePath(
  url: 'https://example.com/image.jpg',
);
if (path != null) {
  // عرض الصورة من path
  Image.file(File(path));
}
```

---

#### 8. **permissionsBox** (Permissions Status)
```dart
Box<PermissionStatusModel>
```

**ما يُحفظ:**
```json
{
  "permission_status": {
    "locationGranted": true,
    "notificationGranted": true,
    "hasCompletedFlow": true,
    "lastUpdated": "2024-01-15T10:00:00Z"
  }
}
```

**الاستخدام:**
- يُحفظ عند: إكمال permission flow
- يُقرأ في: Splash screen
- لا يُمسح عند: Logout (يبقى للأبد)

---

#### 9. **settingsBox** (App Settings)
```dart
Box<dynamic>
```

**ما يُحفظ:**
```json
{
  "last_cleanup_date": "2024-01-15T10:00:00Z",
  "app_version": "1.0.0",
  "theme_mode": "light"
}
```

---

### 🔄 دورة حياة Hive Cache

#### 1️⃣ **Initialization (في main.dart)**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Hive
  await LocalCacheService().init();
  
  // 2. Register adapters (if needed)
  LocalCacheService().registerAdapters();
  
  runApp(MyApp());
}
```

**ما يحدث:**
```
1. Hive.initFlutter()
   ↓
2. Create directories:
   - /cache (للـ Hive boxes)
   - /media (للـ images/videos)
   ↓
3. Open boxes (lazy - عند أول استخدام)
   ↓
4. Run automatic cleanup (background)
   ↓
5. Apply interest decay (if needed)
```

---

#### 2️⃣ **Write Operation (حفظ البيانات)**

```dart
// مثال: حفظ coupons
await localCacheService.put<List<CouponModel>>(
  boxName: StorageKeys.couponsBox,
  key: 'featured_coupons',
  value: coupons,
);
```

**ما يحدث:**
```
1. Open box (أو استخدام المفتوح)
   ↓
2. Put data في الـ box
   ↓
3. Store timestamp (للـ TTL)
   ↓
4. Data saved to disk (async)
```

---

#### 3️⃣ **Read Operation (قراءة البيانات)**

```dart
// مثال: قراءة coupons
final coupons = await localCacheService.get<List<CouponModel>>(
  boxName: StorageKeys.couponsBox,
  key: 'featured_coupons',
  maxAge: Duration(minutes: 15),
);
```

**ما يحدث:**
```
1. Open box
   ↓
2. Check if key exists
   ↓
3. Validate TTL (إذا maxAge محدد)
   ↓
4. If expired:
   - Delete entry
   - Return null
   ↓
5. If valid:
   - Return data
```

---

#### 4️⃣ **Automatic Cleanup (كل 24 ساعة)**

```dart
// يتم تلقائياً عند بدء التطبيق
await _performAutomaticCleanup();
```

**ما يحدث:**
```
1. Check last cleanup date
   ↓
2. If > 24 hours:
   ├─ Clean expired data caches
   │  ├─ couponsBox (TTL: 15 min)
   │  ├─ storesBox (TTL: 30 min)
   │  ├─ categoriesBox (TTL: 1 hour)
   │  └─ publicProductsBox (TTL: 15 min)
   │
   ├─ Clean expired media files (TTL: 7 days)
   │
   └─ Enforce media quota (max: 100 MB)
      └─ Delete oldest files if exceeded
   ↓
3. Update last cleanup date
```

---

#### 5️⃣ **Logout Cleanup**

```dart
// في auth_repository_impl.dart
await clearFeatureCache(StorageKeys.onboardingPreferencesBox);
await clearFeatureCache(StorageKeys.sellerOnboardingPreferencesBox);
```

**ما يحدث:**
```
1. Clear onboarding preferences
   ↓
2. Clear seller onboarding preferences
   ↓
3. ⚠️ لا يتم مسح:
   - couponsBox (عام للجميع)
   - storesBox (عام للجميع)
   - categoriesBox (عام للجميع)
   - mediaMetadataBox (عام للجميع)
   - permissionsBox (يبقى للأبد)
```

---

### 📊 مقارنة بين الـ 3 مستويات

| المعيار | SecureStorage | SharedPreferences | Hive |
|---------|---------------|-------------------|------|
| **الأمان** | 🔒 Encrypted | ⚠️ Plain text | ⚠️ Plain text |
| **السرعة** | 🐢 بطيء | ⚡ سريع | ⚡⚡ أسرع |
| **الحجم** | 📦 صغير | 📦 صغير | 📦📦 كبير |
| **النوع** | String only | Primitives | Any object |
| **TTL** | ❌ لا | ❌ لا | ✅ نعم |
| **الاستخدام** | Tokens, IDs | Flags, Settings | Complex data |

---

### 🎯 متى تستخدم أي نوع؟

#### استخدم **SecureStorage** لـ:
- ✅ Tokens (access, refresh)
- ✅ User IDs
- ✅ Passwords (إذا لزم الأمر)
- ✅ API keys
- ✅ أي بيانات حساسة

#### استخدم **SharedPreferences** لـ:
- ✅ Boolean flags (isGuest, hasPassedGateway)
- ✅ User-scoped flags (onboarding_completed)
- ✅ Simple settings
- ✅ Last sync timestamps

#### استخدم **Hive** لـ:
- ✅ Lists of objects (coupons, stores)
- ✅ Complex models (UserPreferences)
- ✅ Media metadata
- ✅ Cached API responses
- ✅ Interest tracking data
- ✅ أي بيانات تحتاج TTL

---

## ⏰ عمر الكاش (Cache Lifetime)

### 📅 TTL (Time-To-Live) لكل نوع

| النوع | TTL | السبب |
|-------|-----|-------|
| **Auth Tokens** | حتى logout | Session data |
| **User Preferences** | حتى logout | User-specific |
| **Coupons** | 15 دقيقة | تتغير بسرعة |
| **Stores** | 30 دقيقة | تتغير بشكل متوسط |
| **Categories** | 1 ساعة | نادراً ما تتغير |
| **Product Details** | 15 دقيقة | الأسعار تتغير |
| **Media Files** | 7 أيام | توفير bandwidth |
| **Permissions** | للأبد | لا تتغير |

---

### 🔄 Cache Invalidation Strategies

#### 1. **Time-Based (TTL)**
```dart
// تلقائي - يتم فحصه عند القراءة
final data = await get(
  boxName: 'coupons_box',
  key: 'featured',
  maxAge: Duration(minutes: 15),
);
```

#### 2. **Event-Based**
```dart
// عند logout
await clearFeatureCache(StorageKeys.onboardingPreferencesBox);

// عند update profile
await delete(boxName: 'user_box', key: 'profile');
```

#### 3. **Manual Refresh**
```dart
// Pull-to-refresh
await clearBox(StorageKeys.couponsBox);
await fetchCouponsFromAPI();
```

#### 4. **Quota-Based (للـ Media)**
```dart
// تلقائي - عند تجاوز 100 MB
await _enforceMediaQuota();
// يحذف أقدم الملفات
```

---

## 🔄 الـ Lifecycle الكامل (من البداية للنهاية)

### 📱 First App Launch (أول مرة)

```
1. main() starts
   ↓
2. LocalCacheService().init()
   ├─ Initialize Hive
   ├─ Create directories
   └─ Run cleanup (nothing to clean)
   ↓
3. Splash Screen
   ├─ Check language preference → None
   │  └─ Navigate to /language-selection
   ↓
4. User selects language
   ├─ Save to SharedPreferences
   └─ Navigate to /permission-splash
   ↓
5. Permission Flow
   ├─ Request location
   ├─ Request notification
   ├─ Save to Hive (permissionsBox)
   └─ Navigate to /welcome-gateway
   ↓
6. Welcome Gateway
   ├─ User chooses: Login or Guest
   └─ Save hasPassedWelcomeGateway = true
   ↓
7a. If Login:
    ├─ API: POST /auth/login
    ├─ Save to SecureStorage (tokens, userId)
    ├─ Save to SharedPreferences (flags)
    └─ Navigate based on role
    ↓
7b. If Guest:
    ├─ Save isGuest = true
    └─ Navigate to /home
```

---

### 🔄 Normal App Launch (بعد أول مرة)

```
1. main() starts
   ↓
2. LocalCacheService().init()
   ├─ Initialize Hive
   ├─ Run cleanup (if > 24 hours)
   │  ├─ Clean expired coupons
   │  ├─ Clean expired media
   │  └─ Enforce quota
   └─ Apply interest decay (if needed)
   ↓
3. Splash Screen
   ├─ Check language → Exists ✅
   ├─ Check permissions → Completed ✅
   ├─ Check hasPassedGateway → true ✅
   └─ _checkOnboardingStatus():
      ├─ Read authToken
      ├─ Read isGuest
      │
      ├─ If guest:
      │  └─ Navigate to /home
      │
      ├─ If no token:
      │  └─ Navigate to /login
      │
      └─ If has token:
         ├─ Read user-scoped flags
         ├─ Read roles
         └─ Navigate based on:
            ├─ role (customer/seller)
            ├─ onboarding status
            └─ store status
```

---

### 🏠 Using the App (أثناء الاستخدام)

```
User opens Home Screen
   ↓
1. Try read from Hive cache:
   ├─ couponsBox → Check TTL
   │  ├─ If valid → Show cached data ⚡
   │  └─ If expired → Fetch from API
   ↓
2. Fetch from API (background):
   ├─ GET /coupons
   ├─ Save to Hive
   └─ Update UI
   ↓
3. User clicks on coupon:
   ├─ Navigate to details
   ├─ Try read from publicProductsBox
   │  ├─ If cached → Show instantly ⚡
   │  └─ If not → Fetch from API
   ↓
4. User adds to favorites:
   ├─ Update categoryScores in Hive
   │  └─ electronics: 50 → 65 (+15)
   └─ This affects future recommendations
```

---

### 🚪 Logout Flow

```
User clicks Logout
   ↓
1. API: POST /auth/logout (best-effort)
   ↓
2. notificationService.deleteFCMToken()
   ↓
3. clearSessionFlags() (SharedPreferences):
   ├─ Remove isGuest
   ├─ Remove {userId}_onboarding_completed
   ├─ Remove {userId}_store_created
   ├─ Remove {userId}_cached_stores
   └─ Remove {userId}_user_roles
   ↓
4. clearUser() (SecureStorage):
   ├─ Delete authToken
   ├─ Delete refreshToken
   ├─ Delete userId
   ├─ Delete userRole
   ├─ Delete fcmToken
   └─ Delete selectedStoreId
   ↓
5. clearFeatureCache() (Hive):
   ├─ Clear onboarding_preferences_box
   └─ Clear seller_onboarding_preferences_box
   ↓
6. GoogleSignInService().signOut()
   ↓
7. Navigate to /login
   ↓
8. ⚠️ ما لا يُمسح:
   ├─ couponsBox (عام)
   ├─ storesBox (عام)
   ├─ categoriesBox (عام)
   ├─ mediaMetadataBox (عام)
   ├─ permissionsBox (دائم)
   └─ hasPassedWelcomeGateway (دائم)
```

---

### 🧹 Automatic Cleanup (كل 24 ساعة)

```
App Launch (after 24 hours)
   ↓
_performAutomaticCleanup():
   ↓
1. Clean expired data caches:
   ├─ couponsBox:
   │  └─ Delete entries older than 15 min
   ├─ storesBox:
   │  └─ Delete entries older than 30 min
   ├─ categoriesBox:
   │  └─ Delete entries older than 1 hour
   └─ publicProductsBox:
      └─ Delete entries older than 15 min
   ↓
2. Clean expired media files:
   └─ Delete files older than 7 days
   ↓
3. Enforce media quota:
   ├─ Calculate total size
   ├─ If > 100 MB:
   │  └─ Delete oldest files until < 100 MB
   └─ Log statistics
   ↓
4. Update last_cleanup_date
```

---

## 🎓 للفريق: Best Practices

### ✅ Do's

1. **استخدم الـ cache المناسب لكل نوع بيانات**
```dart
// ✅ Correct
await secureStorage.write('authToken', token);  // Sensitive
await sharedPrefs.setBool('isGuest', true);     // Simple flag
await hive.put('coupons', couponsList);         // Complex data
```

2. **حدد TTL مناسب لكل نوع**
```dart
// ✅ Correct
Coupons: 15 minutes  // تتغير بسرعة
Stores: 30 minutes   // تتغير بشكل متوسط
Categories: 1 hour   // نادراً ما تتغير
```

3. **استخدم user-scoped keys للبيانات الشخصية**
```dart
// ✅ Correct
final key = '${userId}_onboarding_completed';
```

4. **امسح الكاش عند logout**
```dart
// ✅ Correct
await clearSessionFlags();  // First
await clearUser();           // Second
await clearFeatureCache();   // Third
```

### ❌ Don'ts

1. **لا تحفظ بيانات حساسة في Hive**
```dart
// ❌ Wrong
await hive.put('password', password);

// ✅ Correct
await secureStorage.write('authToken', token);
```

2. **لا تحفظ صور كبيرة في Hive**
```dart
// ❌ Wrong
await hive.put('image', imageBytes);  // سيبطئ التطبيق

// ✅ Correct
await saveMediaFile(url: url, bytes: bytes);  // في file system
```

3. **لا تنسى TTL**
```dart
// ❌ Wrong
await hive.put('coupons', data);  // لا TTL

// ✅ Correct
await hive.put('coupons', data);
await _setCacheTimestamp('coupons_box', 'coupons');
```

---

## 📚 الخلاصة النهائية

### 🎯 نظام الكاش الكامل:

```
┌─────────────────────────────────────────────────────┐
│              Cache System Layers                    │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Layer 1: SecureStorage (Encrypted)                │
│  ├─ Auth tokens                                    │
│  ├─ User IDs                                       │
│  └─ Sensitive data                                 │
│                                                     │
│  Layer 2: SharedPreferences (Fast)                 │
│  ├─ Boolean flags                                  │
│  ├─ User-scoped flags                              │
│  └─ Simple settings                                │
│                                                     │
│  Layer 3: Hive (Complex + TTL)                     │
│  ├─ Lists & Objects                                │
│  ├─ Cached API responses                           │
│  ├─ User preferences                               │
│  └─ Media metadata                                 │
│                                                     │
│  Layer 4: File System (Media)                      │
│  ├─ Images                                         │
│  └─ Videos                                         │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### ⏰ Cache Lifetime Summary:

| البيانات | المكان | TTL | يُمسح عند |
|---------|--------|-----|-----------|
| Auth Tokens | SecureStorage | Session | Logout |
| User Flags | SharedPreferences | Session | Logout |
| Preferences | Hive | Session | Logout |
| Coupons | Hive | 15 min | TTL/Cleanup |
| Stores | Hive | 30 min | TTL/Cleanup |
| Categories | Hive | 1 hour | TTL/Cleanup |
| Products | Hive | 15 min | TTL/Cleanup |
| Media | File System | 7 days | TTL/Quota |
| Permissions | Hive | Forever | Never |

---

**تاريخ التحديث:** اليوم
**الإصدار:** 3.0 (Complete with Hive)
**الحالة:** ✅ Production Ready
