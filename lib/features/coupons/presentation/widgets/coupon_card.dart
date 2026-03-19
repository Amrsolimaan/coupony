import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/images/app_cached_image.dart';
import '../../domain/entities/coupon_entity.dart';

/// Coupon Card Widget
/// Displays a coupon with cached image from Hive data
/// 
/// ✅ Uses AppCachedImage for automatic image caching
/// ✅ Reads imageUrl from CouponEntity (stored in Hive as String)
/// ✅ CachedNetworkImage handles actual image caching in file system
class CouponCard extends StatelessWidget {
  final CouponEntity coupon;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const CouponCard({
    super.key,
    required this.coupon,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Discount Badge
            _buildImageSection(),

            // Content Section
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(),
                  SizedBox(height: 8.h),
                  _buildDescription(),
                  SizedBox(height: 12.h),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // ✅ CRITICAL: AppCachedImage automatically caches the image
        // imageUrl is read from Hive (stored as String)
        // Actual image cached by CachedNetworkImage in file system
        AppCachedImage(
          imageUrl: coupon.imageUrl,
          height: 180.h,
          width: double.infinity,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
          fit: BoxFit.cover,
        ),

        // Discount Badge
        Positioned(
          top: 12.h,
          right: 12.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${coupon.discountPercentage.toInt()}% OFF',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Favorite Button
        if (onFavorite != null)
          Positioned(
            top: 12.h,
            left: 12.w,
            child: GestureDetector(
              onTap: onFavorite,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  coupon.isFavorited
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: coupon.isFavorited
                      ? AppColors.error
                      : AppColors.textSecondary,
                  size: 20.w,
                ),
              ),
            ),
          ),

        // Expiring Soon Badge
        if (coupon.isExpiringSoon)
          Positioned(
            bottom: 12.h,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14.w,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Expires in ${coupon.daysUntilExpiry} days',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            coupon.title,
            style: AppTextStyles.h4,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      coupon.description,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Store Icon
        Icon(
          Icons.store,
          size: 16.w,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 4.w),
        // Store Name
        Expanded(
          child: Text(
            coupon.storeName,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Price Section
        if (coupon.originalPrice != null && coupon.discountedPrice != null)
          Row(
            children: [
              Text(
                '\$${coupon.originalPrice!.toStringAsFixed(2)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '\$${coupon.discountedPrice!.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
