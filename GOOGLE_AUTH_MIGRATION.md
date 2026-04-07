# تحويل تسجيل الدخول بجوجل من Firebase إلى Endpoint مباشر

## التغييرات المنفذة

### 1. إضافة Endpoint جديد
**الملف:** `lib/core/constants/api_constants.dart`
- تمت إضافة: `static const String googleAuth = '/auth/google';`

### 2. تبسيط GoogleSignInService
**الملف:** `lib/core/services/google_sign_in_service.dart`

**التغييرات:**
- ✅ إزالة dependency على `firebase_auth`
- ✅ تغيير `signInWithGoogleAndGetUserData()` إلى `signInWithGoogleAndGetIdToken()`
- ✅ الآن يُرجع `String?` (idToken) بدلاً من `Map<String, String>?`
- ✅ إزالة كل منطق Firebase Auth
- ✅ تبسيط `signOut()` لإزالة `firebaseAuth.signOut()`

**قبل:**
```dart
Future<Map<String, String>?> signInWithGoogleAndGetUserData()
// يحصل على بيانات المستخدم من Firebase
```

**بعد:**
```dart
Future<String?> signInWithGoogleAndGetIdToken()
// يحصل على idToken فقط من Google
```

### 3. إضافة Method جديد في AuthRemoteDataSource
**الملف:** `lib/features/auth/data/datasources/auth_remote_data_source.dart`

**تمت إضافة:**
```dart
Future<UserModel> googleSignIn({
  required String idToken,
  required String role,
});
```

**Implementation:**
- يرسل POST request إلى `/auth/google`
- Body: `{ "id_token": "...", "role": "customer|seller" }`
- يُرجع `UserModel` مباشرة من الـ backend

### 4. تبسيط AuthRepositoryImpl.googleSignIn()
**الملف:** `lib/features/auth/data/repositories/auth_repository_impl.dart`

**التغييرات:**
- ✅ إزالة منطق login/register المعقد
- ✅ إزالة `_registerGoogleUser()` method
- ✅ إزالة helper methods: `_exceptionMessage()`, `_isUnverifiedError()`, `_isNotFoundError()`, `_isAlreadyRegisteredError()`
- ✅ تبسيط الكود إلى خطوتين فقط:
  1. الحصول على idToken من Google
  2. إرساله إلى `/auth/google` endpoint

**قبل (معقد):**
```dart
1. Get user data from Firebase
2. Create fake password
3. Try login
4. If failed, check error type
5. Try register if not found
6. Handle multiple error cases
```

**بعد (بسيط):**
```dart
1. Get idToken from Google
2. Send to /auth/google endpoint
3. Done!
```

## الفوائد

### 1. كود أبسط وأنظف
- تقليل عدد الأسطر بشكل كبير
- إزالة المنطق المعقد
- سهولة الصيانة

### 2. أداء أفضل
- طلب واحد فقط بدلاً من عدة طلبات
- لا حاجة لـ Firebase Auth
- استجابة أسرع

### 3. أمان أفضل
- التحقق من idToken يتم في الـ backend
- لا حاجة لإنشاء passwords وهمية
- الـ backend يتحكم في كل المنطق

### 4. صيانة أسهل
- كل المنطق في مكان واحد (backend)
- تقليل الـ dependencies
- أقل احتمالية للأخطاء

## كيفية العمل الآن

### Flow الجديد:
```
1. User clicks "Sign in with Google"
   ↓
2. GoogleSignInService.signInWithGoogleAndGetIdToken()
   - يفتح Google Sign-In dialog
   - يحصل على idToken
   ↓
3. AuthRemoteDataSource.googleSignIn(idToken, role)
   - يرسل POST /auth/google
   - Body: { "id_token": "...", "role": "customer" }
   ↓
4. Backend يتحقق من idToken
   - إذا كان المستخدم موجود: يسجل الدخول
   - إذا كان جديد: ينشئ حساب جديد
   - يُرجع access_token و refresh_token
   ↓
5. App يحفظ الـ tokens ويسجل الدخول
```

## ملاحظات مهمة

### Backend Requirements:
الـ backend يجب أن:
1. يتحقق من صحة `id_token` باستخدام Google's token verification API
2. يستخرج email و name من الـ token
3. يبحث عن المستخدم في قاعدة البيانات
4. إذا موجود: يسجل الدخول ويُرجع tokens
5. إذا جديد: ينشئ حساب جديد بالـ role المحدد ويُرجع tokens

### Dependencies:
- يمكن الآن إزالة `firebase_auth` من `pubspec.yaml` إذا لم يكن مستخدم في أماكن أخرى
- `google_sign_in` package لا يزال مطلوب

### Testing:
تأكد من اختبار:
- ✅ تسجيل دخول مستخدم موجود
- ✅ تسجيل مستخدم جديد
- ✅ إلغاء عملية تسجيل الدخول
- ✅ أخطاء الشبكة
- ✅ idToken غير صالح

## الملفات المعدلة

1. ✅ `lib/core/constants/api_constants.dart`
2. ✅ `lib/core/services/google_sign_in_service.dart`
3. ✅ `lib/features/auth/data/datasources/auth_remote_data_source.dart`
4. ✅ `lib/features/auth/data/repositories/auth_repository_impl.dart`

## الملفات غير المتأثرة

- ✅ `lib/features/auth/presentation/cubit/google_sign_in_cubit.dart` (لا تغيير)
- ✅ `lib/features/auth/domain/use_cases/google_sign_in_use_case.dart` (لا تغيير)
- ✅ `lib/features/auth/presentation/widgets/google_sign_in_button.dart` (لا تغيير)
- ✅ UI screens (لا تغيير)

## الخلاصة

تم تحويل تسجيل الدخول بجوجل بنجاح من استخدام Firebase Auth إلى استخدام `/auth/google` endpoint مباشرة. الكود الآن أبسط، أسرع، وأسهل في الصيانة.
