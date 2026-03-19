# 🔄 HYBRID STORAGE IMPLEMENTATION GUIDE

## Overview
This guide explains how the hybrid storage system works, combining Hive (for metadata) and CachedNetworkImage (for actual images).

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    API Response                         │
│  {                                                      │
│    "id": "123",                                         │
│    "title": "50% Off Pizza",                           │
│    "image_url": "https://cdn.example.com/pizza.jpg"    │
│  }                                                      │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│              CouponModel (Hive Storage)                 │
│  ┌───────────────────────────────────────────────┐     │
│  │ @HiveField(9)                                 │     │
│  │ final String imageUrl;  ← URL ONLY           │     │
│  │                                               │     │
│  │ ✅ Stored: "https://cdn.example.com/pizza.jpg"│     │
│  │ ❌ NOT Stored: Image bytes                    │     │
│  └───────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│              AppCachedImage Widget                      │
│  ┌───────────────────────────────────────────────┐     │
│  │ AppCachedImage(                               │     │
│  │   imageUrl: coupon.imageUrl,  ← From Hive    │     │
│  │ )                                             │     │
│  └───────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│         CachedNetworkImage (File System)                │
│  ┌───────────────────────────────────────────────┐     │
│  │ Downloads image from URL                      │     │
│  │ Caches in: /temp/app_image_cache/            │     │
│  │ Max Size: 200 MB (from AppConstants)         │     │
│  │ TTL: 7 days (from AppConstants)              │     │
│  └───────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

---

## 📦 Components Created

### 1. AppCachedImage Widget
**Location:** `lib/core/widgets/images/app_cached_image.dart`

**Features:**
- ✅ Automatic image caching via CachedNetworkImage
- ✅ Professional shimmer loading effect
- ✅ Error state with fallback icon
- ✅ Customizable border radius and fit
- ✅ Circular variant for avatars

**Usage:**
```dart
// Basic usage
AppCachedImage(
  imageUrl: coupon.imageUrl,
  width: 300.w,
  height: 200.h,
)

// With custom border radius
AppCachedImage(
  imageUrl: coupon.imageUrl,
  borderRadius: BorderRadius.circular(20.r),
  fit: BoxFit.contain,
)

// Circular variant (for avatars)
AppCachedImageCircular(
  imageUrl: user.profileImageUrl,
  size: 80.w,
  borderWidth: 2.w,
  borderColor: AppColors.primary,
)
```

---

### 2. AppCacheManager
**Location:** `lib/core/cache/app_cache_manager.dart`

**Features:**
- ✅ Uses AppConstants.maxMediaCacheSizeMB (200 MB)
- ✅ Uses AppConstants.mediaCacheDuration (7 days)
- ✅ Automatic cleanup when quota exceeded
- ✅ Singleton pattern

**Configuration:**
```dart
// Already configured automatically
// No manual setup needed

// Optional: Check cache size
final cacheManager = AppCacheManager();
final sizeMB = await cacheManager.getCacheSizeMB();
print('Cache size: $sizeMB MB');

// Optional: Clear cache manually
await cacheManager.clearCache();
```

---

### 3. CouponModel (Hive Model)
**Location:** `lib/features/coupons/data/models/coupon_model.dart`

**Critical Field:**
```dart
@HiveField(9)
final String imageUrl; // ✅ String URL only, NOT binary data
```

**Usage:**
```dart
// Create from API response
final coupon = CouponModel.fromJson(apiResponse);

// Save to Hive (only URL stored)
await cacheService.put<CouponModel>(
  boxName: StorageKeys.couponsBox,
  key: coupon.id,
  value: coupon,
);

// Load from Hive
final coupon = await cacheService.get<CouponModel>(
  boxName: StorageKeys.couponsBox,
  key: couponId,
);

// Display image (automatically cached)
AppCachedImage(imageUrl: coupon.imageUrl)
```

---

### 4. CouponCard Widget
**Location:** `lib/features/coupons/presentation/widgets/coupon_card.dart`

**Features:**
- ✅ Displays coupon with cached image
- ✅ Discount badge overlay
- ✅ Favorite button
- ✅ Expiring soon indicator
- ✅ Store name and pricing

**Usage:**
```dart
CouponCard(
  coupon: coupon,
  onTap: () => navigateToCouponDetails(coupon),
  onFavorite: () => toggleFavorite(coupon),
)
```

---

## 🚀 Complete Usage Example

### Step 1: Register Hive Adapter (main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(UserPreferencesModelAdapter());
  Hive.registerAdapter(PermissionStatusModelAdapter());
  Hive.registerAdapter(CouponModelAdapter()); // ✅ NEW
  
  await di.init();
  await di.sl<LocalCacheService>().init();
  
  runApp(const MyApp());
}
```

### Step 2: Generate Hive Adapter
```bash
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Step 3: Fetch and Cache Coupons
```dart
// In your repository or data source
Future<List<CouponModel>> fetchAndCacheCoupons() async {
  // 1. Fetch from API
  final response = await dio.get('/coupons');
  final coupons = (response.data as List)
      .map((json) => CouponModel.fromJson(json))
      .toList();
  
  // 2. Save to Hive (only URLs stored)
  for (final coupon in coupons) {
    await cacheService.put<CouponModel>(
      boxName: StorageKeys.couponsBox,
      key: coupon.id,
      value: coupon,
    );
  }
  
  return coupons;
}
```

### Step 4: Display in ListView
```dart
class CouponsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CouponModel>>(
      future: _loadCoupons(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        
        final coupons = snapshot.data!;
        
        return ListView.builder(
          itemCount: coupons.length,
          itemBuilder: (context, index) {
            final coupon = coupons[index];
            
            // ✅ CouponCard uses AppCachedImage internally
            // imageUrl from Hive → CachedNetworkImage caches actual image
            return CouponCard(
              coupon: coupon,
              onTap: () => _showDetails(coupon),
              onFavorite: () => _toggleFavorite(coupon),
            );
          },
        );
      },
    );
  }
  
  Future<List<CouponModel>> _loadCoupons() async {
    return await cacheService.getAll<CouponModel>(
      StorageKeys.couponsBox,
    );
  }
}
```

---

## 📊 Storage Breakdown

### What's Stored in Hive:
```dart
CouponModel {
  id: "123",
  title: "50% Off Pizza",
  imageUrl: "https://cdn.example.com/pizza.jpg", // ✅ URL only
  // ... other metadata
}
```
**Size:** ~1-2 KB per coupon

### What's Stored in File System:
```
/data/user/0/com.example.coupon/cache/app_image_cache/
├── abc123def456.jpg  (actual image bytes)
├── xyz789ghi012.jpg
└── ...
```
**Size:** Varies (managed by AppCacheManager, max 200 MB)

---

## 🎯 Benefits

1. **Lightweight Hive Storage**
   - Only metadata stored
   - Fast queries
   - No bloat

2. **Efficient Image Caching**
   - Automatic by CachedNetworkImage
   - Quota-managed (200 MB)
   - TTL-based expiration (7 days)

3. **Consistent Configuration**
   - Uses AppConstants for all limits
   - Single source of truth

4. **Offline Support**
   - Metadata always available (Hive)
   - Images cached for offline viewing

5. **Performance**
   - Shimmer loading for better UX
   - Lazy image loading
   - Memory efficient

---

## 🔧 Maintenance

### Clear Image Cache
```dart
final cacheManager = AppCacheManager();
await cacheManager.clearCache();
```

### Check Cache Size
```dart
final sizeMB = await cacheManager.getCacheSizeMB();
if (await cacheManager.isNearQuota()) {
  // Show warning to user
}
```

### Update Coupon Image URL
```dart
final updatedCoupon = coupon.copyWith(
  imageUrl: newImageUrl,
);

await cacheService.put<CouponModel>(
  boxName: StorageKeys.couponsBox,
  key: coupon.id,
  value: updatedCoupon,
);

// Old image will be cleaned up automatically after 7 days
```

---

## ✅ Verification Checklist

- [x] CouponModel stores imageUrl as String (not Uint8List)
- [x] AppCachedImage uses CachedNetworkImage
- [x] AppCacheManager uses AppConstants limits
- [x] Shimmer loading effect implemented
- [x] Error state with fallback icon
- [x] Hive adapter generated
- [x] ListView example provided
- [x] Offline support working

---

## 🚨 Important Notes

1. **Never store binary data in Hive**
   - Always store URLs as String
   - Let CachedNetworkImage handle caching

2. **Quota Management**
   - 200 MB limit enforced automatically
   - Oldest images deleted when exceeded

3. **TTL**
   - Images expire after 7 days
   - Automatically re-downloaded if needed

4. **Performance**
   - First load: Downloads image
   - Subsequent loads: Instant from cache
   - Offline: Shows cached image

---

**Implementation Complete!** 🎉
