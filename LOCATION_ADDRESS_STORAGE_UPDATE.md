# تحديث: حفظ العنوان النصي مع الموقع

## 📋 الملخص
تم إضافة حقل `address` لحفظ العنوان النصي (الناتج من Geocoding) مع الإحداثيات في قاعدة البيانات المحلية باستخدام Hive.

## ✅ التغييرات المنفذة

### 1. Domain Layer - Entity
**الملف:** `lib/features/permissions/domain/entities/permission_entity.dart`

```dart
// ✅ تم إضافة
final String? address;

const PermissionEntity({
  // ...
  this.address,
  // ...
});
```

### 2. Data Layer - Model
**الملف:** `lib/features/permissions/data/models/permission_status_model.dart`

```dart
// ✅ تم إضافة HiveField
@HiveField(7)
final String? address;

// ✅ تم تحديث Constructor
PermissionStatusModel({
  // ...
  this.address,
  // ...
});

// ✅ تم تحديث copyWith
PermissionStatusModel copyWith({
  // ...
  Object? address = _sentinel,
  // ...
});

// ✅ تم تحديث toJson/fromJson
```

### 3. Data Layer - Repository Interface
**الملف:** `lib/features/permissions/domain/repositories/permission_repository.dart`

```dart
// ✅ تم إضافة parameter
Future<Either<Failure, void>> savePermissionStatus({
  // ...
  String? address,
  // ...
});
```

### 4. Data Layer - Repository Implementation
**الملف:** `lib/features/permissions/data/repositories/permission_repository_impl.dart`

```dart
// ✅ تم تحديث savePermissionStatus
final updated = existing.copyWith(
  // ...
  address: address,
  // ...
);

// ✅ تم تحديث _updateLocalPermissionStatus
Future<void> _updateLocalPermissionStatus({
  // ...
  String? address,
  // ...
});
```

### 5. Presentation Layer - Cubit
**الملف:** `lib/features/permissions/presentation/cubit/permission_flow_cubit.dart`

```dart
// ✅ تم تحديث confirmLocation لحفظ العنوان
void confirmLocation() {
  logger.i('User confirmed location');
  
  // Save the selected location with address to local storage
  if (state.userPosition != null) {
    repository.savePermissionStatus(
      latitude: state.userPosition!.latitude,
      longitude: state.userPosition!.longitude,
      address: state.currentAddress, // ✅ حفظ العنوان
    );
    logger.i('✅ Saved location with address: ${state.currentAddress}');
  }
  
  // ...
}
```

### 6. Generated Code
**الملف:** `lib/features/permissions/data/models/permission_status_model.g.dart`

```dart
// ✅ تم توليد Hive Adapter تلقائياً
class PermissionStatusModelAdapter extends TypeAdapter<PermissionStatusModel> {
  @override
  PermissionStatusModel read(BinaryReader reader) {
    // ...
    address: fields[7] as String?, // ✅ HiveField(7)
    // ...
  }
  
  @override
  void write(BinaryWriter writer, PermissionStatusModel obj) {
    // ...
    ..writeByte(7)
    ..write(obj.address) // ✅ حفظ العنوان
    // ...
  }
}
```

## 🔄 التدفق الكامل

### عند اختيار المستخدم للموقع:

1. **تحريك الخريطة** → `onCameraMove`
   - يتم تحديث `_lastCameraCenter`

2. **توقف الكاميرا** → `onCameraIdle`
   - يتم حفظ `_selectedLatLng`
   - يتم استدعاء `getAddressFromCoordinates(lat, lng)`

3. **وصول العنوان** → `state.currentAddress`
   - يتم عرض العنوان في Bottom Sheet

4. **الضغط على "تأكيد الموقع"** → `confirmLocation()`
   - ✅ يتم حفظ الإحداثيات + العنوان في Hive
   - يتم الانتقال للخطوة التالية

### البيانات المحفوظة في Hive:

```dart
{
  "location_status": "granted",
  "notification_status": "not_requested",
  "latitude": 30.0444,
  "longitude": 31.2357,
  "address": "شارع التحرير، القاهرة، مصر", // ✅ جديد
  "fcm_token": null,
  "timestamp": "2026-04-08T10:30:00.000Z",
  "has_completed_flow": false
}
```

## 🎯 الفوائد

1. ✅ **الاتساق المعماري**: البيانات المترابطة محفوظة معاً
2. ✅ **Type Safety**: استخدام Hive بدلاً من SharedPreferences
3. ✅ **الأداء**: قراءة واحدة تجيب كل البيانات
4. ✅ **Atomic Operations**: حذف/تحديث الموقع يشمل العنوان
5. ✅ **سهولة التوسع**: يمكن إضافة city, country, etc. مستقبلاً

## 📝 ملاحظات

- تم استخدام `@HiveField(7)` لتجنب تعارض مع الحقول الموجودة (0-6)
- العنوان nullable (`String?`) لأنه قد يفشل الـ Geocoding
- يتم حفظ العنوان فقط عند الضغط على "تأكيد الموقع"
- الـ State يحتوي بالفعل على `currentAddress` - لم نحتج لتعديله

## 🧪 الاختبار

```bash
# توليد Hive Adapter
flutter pub run build_runner build --delete-conflicting-outputs

# التحقق من عدم وجود أخطاء
flutter analyze lib/features/permissions
```

## ✨ النتيجة

الآن عند اختيار المستخدم للموقع والضغط على "تأكيد"، يتم حفظ:
- ✅ الإحداثيات (latitude, longitude)
- ✅ العنوان النصي (address)
- ✅ حالة الصلاحيات
- ✅ الوقت والتاريخ

كل البيانات محفوظة في Hive بشكل منظم ومترابط! 🎉
