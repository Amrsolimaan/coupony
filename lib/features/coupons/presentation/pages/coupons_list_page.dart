import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../data/models/coupon_model.dart';
import '../widgets/coupon_card.dart';

/// Coupons List Page
/// Example implementation showing how to:
/// 1. Load coupons from Hive (with imageUrl as String)
/// 2. Display them in a ListView
/// 3. AppCachedImage automatically caches images
/// 
/// ✅ HYBRID STORAGE:
/// - Coupon data (including imageUrl) stored in Hive
/// - Actual images cached by CachedNetworkImage in file system
class CouponsListPage extends StatefulWidget {
  const CouponsListPage({super.key});

  @override
  State<CouponsListPage> createState() => _CouponsListPageState();
}

class _CouponsListPageState extends State<CouponsListPage> {
  final LocalCacheService _cacheService = LocalCacheService();
  List<CouponModel> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  /// Load coupons from Hive
  Future<void> _loadCoupons() async {
    setState(() => _isLoading = true);

    try {
      // Get all coupons from Hive box
      final coupons = await _cacheService.getAll<CouponModel>(
        StorageKeys.couponsBox,
      );

      setState(() {
        _coupons = coupons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupons'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _coupons.isEmpty
              ? _buildEmptyState()
              : _buildCouponsList(),
    );
  }

  Widget _buildCouponsList() {
    return RefreshIndicator(
      onRefresh: _loadCoupons,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        itemCount: _coupons.length,
        itemBuilder: (context, index) {
          final coupon = _coupons[index];

          // ✅ CRITICAL: CouponCard uses AppCachedImage
          // imageUrl is read from Hive (String)
          // CachedNetworkImage handles actual caching
          return CouponCard(
            coupon: coupon,
            onTap: () => _onCouponTap(coupon),
            onFavorite: () => _onFavoriteTap(coupon),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 80.w,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'No coupons available',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _onCouponTap(CouponModel coupon) {
    // Navigate to coupon details
    // Navigator.push(...)
  }

  void _onFavoriteTap(CouponModel coupon) async {
    // Toggle favorite status
    final updated = coupon.copyWith(isFavorited: !coupon.isFavorited);

    // Save back to Hive
    await _cacheService.put<CouponModel>(
      boxName: StorageKeys.couponsBox,
      key: coupon.id,
      value: updated,
    );

    // Reload list
    _loadCoupons();
  }
}
