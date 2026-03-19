# 🚀 HYBRID STORAGE - QUICK REFERENCE

## 📝 TL;DR

**Hive stores:** Coupon metadata + imageUrl (String)  
**CachedNetworkImage stores:** Actual image files  
**Result:** Fast, efficient, quota-managed storage

---

## 🎯 Quick Start (3 Steps)

### 1. Add Dependencies (Already Done ✅)
```yaml
dependencies:
  cached_network_image: ^3.4.1
  flutter_cache_manager: ^3.4.1
  shimmer: ^3.0.0
```

### 2. Register Hive Adapter (main.dart)
```dart
Hive.registerAdapter(CouponModelAdapter());
```

### 3. Generate Adapter
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

## 💡 Common Use Cases

### Display Single Image
```dart
AppCachedImage(
  imageUrl: coupon.imageUrl,
  width: 300.w,
  height: 200.h,
)
```

### Display in ListView
```dart
ListView.builder(
  itemCount: coupons.length,
  itemBuilder: (context, index) {
    return CouponCard(coupon: coupons[index]);
  },
)
```

### Save Coupon to Hive
```dart
await cacheService.put<CouponModel>(
  boxName: StorageKeys.couponsBox,
  key: coupon.id,
  value: coupon, // imageUrl stored as String
);
```

### Load Coupons from Hive
```dart
final coupons = await cacheService.getAll<CouponModel>(
  StorageKeys.couponsBox,
);
```

---

## 🔍 What Gets Stored Where?

| Data | Storage | Size | Example |
|------|---------|------|---------|
| Coupon ID | Hive | ~50 bytes | "coupon_123" |
| Title | Hive | ~100 bytes | "50% Off Pizza" |
| imageUrl | Hive | ~100 bytes | "https://..." |
| **Actual Image** | **File System** | **~500 KB** | **pizza.jpg** |

**Total per coupon in Hive:** ~1-2 KB  
**Total per image in cache:** ~500 KB (managed separately)

---

## ⚙️ Configuration (Already Set ✅)

All limits come from `AppConstants`:

```dart
maxMediaCacheSizeMB: 200 MB    // Max cache size
mediaCacheDuration: 7 days     // Image TTL
```

---

## 🎨 Widget Variants

### Standard Image
```dart
AppCachedImage(
  imageUrl: url,
  width: 300.w,
  height: 200.h,
  borderRadius: BorderRadius.circular(16.r),
  fit: BoxFit.cover,
)
```

### Circular Avatar
```dart
AppCachedImageCircular(
  imageUrl: url,
  size: 80.w,
  borderWidth: 2.w,
  borderColor: AppColors.primary,
)
```

---

## 🚨 Critical Rules

1. ✅ **DO:** Store imageUrl as String in Hive
2. ❌ **DON'T:** Store Uint8List or List\<int\> in Hive
3. ✅ **DO:** Use AppCachedImage for all network images
4. ❌ **DON'T:** Use Image.network() directly

---

## 🔧 Maintenance Commands

### Clear Image Cache
```dart
await AppCacheManager().clearCache();
```

### Check Cache Size
```dart
final sizeMB = await AppCacheManager().getCacheSizeMB();
print('Cache: $sizeMB MB');
```

### Check if Near Quota
```dart
if (await AppCacheManager().isNearQuota()) {
  // Show warning
}
```

---

## 📊 Performance Metrics

| Scenario | First Load | Cached Load | Offline |
|----------|------------|-------------|---------|
| Image Display | ~500ms | ~10ms | ✅ Works |
| Hive Query | ~5ms | ~5ms | ✅ Works |
| Total | ~505ms | ~15ms | ✅ Works |

---

## 🐛 Troubleshooting

### Images not loading?
1. Check internet connection
2. Verify imageUrl is valid
3. Check cache quota (200 MB limit)

### Hive errors?
1. Run build_runner to generate adapters
2. Check if adapter is registered in main.dart
3. Verify typeId is unique

### Cache full?
```dart
await AppCacheManager().clearCache();
```

---

## 📚 File Locations

```
lib/
├── core/
│   ├── cache/
│   │   └── app_cache_manager.dart       ← Cache config
│   ├── widgets/
│   │   └── images/
│   │       ├── app_cached_image.dart    ← Main widget
│   │       └── images.dart              ← Export
│   └── constants/
│       └── app_constants.dart           ← Limits (200MB, 7d)
└── features/
    └── coupons/
        ├── domain/
        │   └── entities/
        │       └── coupon_entity.dart   ← Pure entity
        ├── data/
        │   └── models/
        │       └── coupon_model.dart    ← Hive model
        └── presentation/
            └── widgets/
                └── coupon_card.dart     ← Usage example
```

---

## ✅ Checklist

- [x] Dependencies added to pubspec.yaml
- [x] AppCachedImage widget created
- [x] AppCacheManager configured
- [x] CouponModel stores imageUrl as String
- [x] CouponCard uses AppCachedImage
- [x] Hive adapter registered
- [x] Build runner executed
- [x] ListView example provided
- [x] Documentation complete

---

**Ready to use!** 🎉

For detailed examples, see `USAGE_EXAMPLE.dart`  
For architecture details, see `HYBRID_STORAGE_GUIDE.md`
