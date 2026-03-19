// ═══════════════════════════════════════════════════════════
// HYBRID STORAGE USAGE EXAMPLE
// ═══════════════════════════════════════════════════════════
// This file demonstrates how to use the hybrid storage system
// combining Hive (metadata) and CachedNetworkImage (images)
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/storage/local_cache_service.dart';
import '../../core/widgets/images/app_cached_image.dart';
import 'data/models/coupon_model.dart';
import 'presentation/widgets/coupon_card.dart';

// ═══════════════════════════════════════════════════════════
// EXAMPLE 1: Basic Image Display
// ═══════════════════════════════════════════════════════════

class BasicImageExample extends StatelessWidget {
  final String imageUrl;

  const BasicImageExample({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return AppCachedImage(
      imageUrl: imageUrl,
      width: 300.w,
      height: 200.h,
      borderRadius: BorderRadius.circular(16.r),
      fit: BoxFit.cover,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// EXAMPLE 2: Save Coupon to Hive (with imageUrl)
// ═══════════════════════════════════════════════════════════

Future<void> saveCouponExample() async {
  final cacheService = LocalCacheService();

  // Create coupon with imageUrl (NOT binary data)
  final coupon = CouponModel(
    id: '123',
    title: '50% Off Pizza',
    description: 'Get half off on all pizzas',
    discountPercentage: 50.0,
    storeName: 'Pizza Palace',
    storeId: 'store_1',
    categoryId: 'restaurants',
    imageUrl: 'https://cdn.example.com/pizza.jpg', // ✅ URL only
    expiryDate: DateTime.now().add(const Duration(days: 30)),
    createdAt: DateTime.now(),
  );

  // Save to Hive (only URL stored, not image bytes)
  await cacheService.put<CouponModel>(
    boxName: StorageKeys.couponsBox,
    key: coupon.id,
    value: coupon,
  );

  print('✅ Coupon saved to Hive with imageUrl');
}

// ═══════════════════════════════════════════════════════════
// EXAMPLE 3: Load Coupons from Hive and Display
// ═══════════════════════════════════════════════════════════

class CouponsListExample extends StatefulWidget {
  const CouponsListExample({super.key});

  @override
  State<CouponsListExample> createState() => _CouponsListExampleState();
}

class _CouponsListExampleState extends State<CouponsListExample> {
  final LocalCacheService _cacheService = LocalCacheService();
  List<CouponModel> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() => _isLoading = true);

    // Load all coupons from Hive
    final coupons = await _cacheService.getAll<CouponModel>(
      StorageKeys.couponsBox,
    );

    setState(() {
      _coupons = coupons;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _coupons.length,
      itemBuilder: (context, index) {
        final coupon = _coupons[index];

        // ✅ CouponCard uses AppCachedImage internally
        // imageUrl from Hive → CachedNetworkImage caches actual image
        return CouponCard(
          coupon: coupon,
          onTap: () => _showCouponDetails(coupon),
          onFavorite: () => _toggleFavorite(coupon),
        );
      },
    );
  }

  void _showCouponDetails(CouponModel coupon) {
    // Navigate to details page
  }

  Future<void> _toggleFavorite(CouponModel coupon) async {
    final updated = coupon.copyWith(isFavorited: !coupon.isFavorited);

    await _cacheService.put<CouponModel>(
      boxName: StorageKeys.couponsBox,
      key: coupon.id,
      value: updated,
    );

    _loadCoupons();
  }
}

// ═══════════════════════════════════════════════════════════
// EXAMPLE 4: Fetch from API and Cache
// ═══════════════════════════════════════════════════════════

Future<List<CouponModel>> fetchAndCacheCouponsExample() async {
  final cacheService = LocalCacheService();

  // Simulate API response
  final apiResponse = [
    {
      'id': '1',
      'title': '50% Off Pizza',
      'description': 'Get half off on all pizzas',
      'discount_percentage': 50.0,
      'store_name': 'Pizza Palace',
      'store_id': 'store_1',
      'category_id': 'restaurants',
      'image_url': 'https://cdn.example.com/pizza.jpg', // ✅ URL from API
      'expiry_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'is_active': true,
    },
    {
      'id': '2',
      'title': '30% Off Shoes',
      'description': 'Discount on all footwear',
      'discount_percentage': 30.0,
      'store_name': 'Shoe Store',
      'store_id': 'store_2',
      'category_id': 'fashion',
      'image_url': 'https://cdn.example.com/shoes.jpg', // ✅ URL from API
      'expiry_date': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'is_active': true,
    },
  ];

  // Parse and save to Hive
  final coupons = <CouponModel>[];
  for (final json in apiResponse) {
    final coupon = CouponModel.fromJson(json);
    coupons.add(coupon);

    // Save to Hive (only URL stored)
    await cacheService.put<CouponModel>(
      boxName: StorageKeys.couponsBox,
      key: coupon.id,
      value: coupon,
    );
  }

  print('✅ ${coupons.length} coupons cached in Hive');
  return coupons;
}

// ═══════════════════════════════════════════════════════════
// EXAMPLE 5: Grid View with Cached Images
// ═══════════════════════════════════════════════════════════

class CouponsGridExample extends StatelessWidget {
  final List<CouponModel> coupons;

  const CouponsGridExample({super.key, required this.coupons});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.75,
      ),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ AppCachedImage automatically caches
              AppCachedImage(
                imageUrl: coupon.imageUrl,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${coupon.discountPercentage.toInt()}% OFF',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// EXAMPLE 6: Circular Avatar with Cached Image
// ═══════════════════════════════════════════════════════════

class UserAvatarExample extends StatelessWidget {
  final String profileImageUrl;

  const UserAvatarExample({super.key, required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return AppCachedImageCircular(
      imageUrl: profileImageUrl,
      size: 80.w,
      borderWidth: 3.w,
      borderColor: Colors.orange,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// EXAMPLE 7: Custom Error and Loading States
// ═══════════════════════════════════════════════════════════

class CustomStatesExample extends StatelessWidget {
  final String imageUrl;

  const CustomStatesExample({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return AppCachedImage(
      imageUrl: imageUrl,
      width: 300.w,
      height: 200.h,
      placeholder: Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: Container(
        color: Colors.red[50],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 8),
              Text('Failed to load image'),
            ],
          ),
        ),
      ),
    );
  }
}
