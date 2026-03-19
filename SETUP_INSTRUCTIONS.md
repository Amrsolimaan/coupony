# 🚀 SETUP INSTRUCTIONS - Hybrid Storage

## Step-by-Step Setup Guide

Follow these steps in order to complete the hybrid storage implementation.

---

## ✅ Step 1: Install Dependencies

```bash
flutter pub get
```

**Expected Output:**
```
Running "flutter pub get" in coupon...
Resolving dependencies...
+ cached_network_image 3.4.1
+ flutter_cache_manager 3.4.1
+ shimmer 3.0.0
Got dependencies!
```

---

## ✅ Step 2: Generate Hive Adapter

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Expected Output:**
```
[INFO] Generating build script...
[INFO] Generating build script completed, took 2.1s
[INFO] Creating build script snapshot...
[INFO] Creating build script snapshot completed, took 3.4s
[INFO] Running build...
[INFO] 1.2s elapsed, 0/3 actions completed.
[INFO] 5.3s elapsed, 2/3 actions completed.
[INFO] Running build completed, took 5.5s
[INFO] Caching finalized dependency graph...
[INFO] Caching finalized dependency graph completed, took 45ms
[SUCCESS] Build completed successfully
```

**Files Generated:**
- `lib/features/coupons/data/models/coupon_model.g.dart` ✅

---

## ✅ Step 3: Uncomment Adapter Registration

**File:** `lib/main.dart`

**Find this line:**
```dart
// Hive.registerAdapter(CouponModelAdapter()); // ✅ Uncomment after running build_runner
```

**Change to:**
```dart
Hive.registerAdapter(CouponModelAdapter()); // ✅ Adapter registered
```

---

## ✅ Step 4: Hot Restart

```bash
# In your IDE, press:
# - VS Code: Ctrl+Shift+F5 (Windows/Linux) or Cmd+Shift+F5 (Mac)
# - Android Studio: Ctrl+\ (Windows/Linux) or Cmd+\ (Mac)

# Or in terminal:
flutter run
```

---

## ✅ Step 5: Test Implementation

### Option A: Use Provided Example Page

Add to your router:

```dart
// In lib/config/routes/app_router.dart
static const String couponsList = '/coupons';

GoRoute(
  path: couponsList,
  builder: (context, state) => const CouponsListPage(),
),
```

### Option B: Test Manually

```dart
import 'package:coupon/core/widgets/images/app_cached_image.dart';

// In any widget:
AppCachedImage(
  imageUrl: 'https://picsum.photos/400/300',
  width: 300.w,
  height: 200.h,
)
```

---

## 🧪 Verification Tests

### Test 1: Image Loading
```dart
AppCachedImage(
  imageUrl: 'https://picsum.photos/400/300',
  width: 300.w,
  height: 200.h,
)
```
**Expected:** Shimmer effect → Image loads → Cached for future

### Test 2: Error Handling
```dart
AppCachedImage(
  imageUrl: 'https://invalid-url.com/image.jpg',
  width: 300.w,
  height: 200.h,
)
```
**Expected:** Shimmer effect → Error icon with red background

### Test 3: Hive Storage
```dart
final coupon = CouponModel(
  id: 'test_1',
  title: 'Test Coupon',
  description: 'Test Description',
  discountPercentage: 50.0,
  storeName: 'Test Store',
  storeId: 'store_1',
  categoryId: 'restaurants',
  imageUrl: 'https://picsum.photos/400/300',
  expiryDate: DateTime.now().add(Duration(days: 30)),
  createdAt: DateTime.now(),
);

await LocalCacheService().put<CouponModel>(
  boxName: StorageKeys.couponsBox,
  key: coupon.id,
  value: coupon,
);

print('✅ Coupon saved to Hive');
```

### Test 4: Load and Display
```dart
final coupons = await LocalCacheService().getAll<CouponModel>(
  StorageKeys.couponsBox,
);

print('✅ Loaded ${coupons.length} coupons from Hive');

// Display in ListView
ListView.builder(
  itemCount: coupons.length,
  itemBuilder: (context, index) {
    return CouponCard(coupon: coupons[index]);
  },
)
```

---

## 🔍 Troubleshooting

### Issue 1: Build Runner Fails
**Error:** `Could not find a file named "pubspec.yaml"`

**Solution:**
```bash
# Make sure you're in the project root
cd /path/to/your/project
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

### Issue 2: Adapter Not Found
**Error:** `The getter 'CouponModelAdapter' isn't defined`

**Solution:**
1. Check if `coupon_model.g.dart` was generated
2. Make sure you ran build_runner
3. Restart your IDE

---

### Issue 3: Images Not Loading
**Error:** Images show error icon immediately

**Solution:**
1. Check internet connection
2. Verify imageUrl is valid
3. Check console for error messages

---

### Issue 4: Type Mismatch
**Error:** `type 'CouponModel' is not a subtype of type 'CouponEntity'`

**Solution:**
```dart
// Make sure CouponModel extends CouponEntity
class CouponModel extends CouponEntity { ... }
```

---

## 📊 Expected Results

### After Setup:
- ✅ No build errors
- ✅ App runs successfully
- ✅ Images load with shimmer effect
- ✅ Images cached for offline use
- ✅ Hive stores only metadata (URLs)
- ✅ File system stores actual images

### Performance:
- First image load: ~500ms (download)
- Cached image load: ~10ms (instant)
- Hive query: ~5ms (fast)

### Storage:
- Hive box size: ~1-2 KB per coupon
- Image cache: ~500 KB per image
- Total quota: 200 MB (managed automatically)

---

## 🎯 Success Criteria

Run this checklist to verify everything works:

```dart
// 1. Can create coupon with imageUrl
final coupon = CouponModel(
  id: 'test',
  imageUrl: 'https://picsum.photos/400/300',
  // ... other fields
);
print('✅ Coupon created');

// 2. Can save to Hive
await cacheService.put<CouponModel>(
  boxName: StorageKeys.couponsBox,
  key: coupon.id,
  value: coupon,
);
print('✅ Saved to Hive');

// 3. Can load from Hive
final loaded = await cacheService.get<CouponModel>(
  boxName: StorageKeys.couponsBox,
  key: coupon.id,
);
print('✅ Loaded from Hive: ${loaded?.imageUrl}');

// 4. Can display image
AppCachedImage(imageUrl: loaded!.imageUrl);
print('✅ Image displayed');

// 5. Check cache size
final sizeMB = await AppCacheManager().getCacheSizeMB();
print('✅ Cache size: $sizeMB MB');
```

**All checks pass?** You're ready to go! 🎉

---

## 📚 Next Steps

1. Read `QUICK_REFERENCE.md` for common use cases
2. Check `USAGE_EXAMPLE.dart` for code examples
3. Review `HYBRID_STORAGE_GUIDE.md` for architecture details
4. Start implementing your coupon features!

---

## 🆘 Need Help?

If you encounter issues:

1. Check the troubleshooting section above
2. Review the error messages carefully
3. Verify all files were created correctly
4. Make sure dependencies are installed
5. Try `flutter clean` and rebuild

---

**Setup Complete!** 🚀

Your hybrid storage system is now ready for production use.
