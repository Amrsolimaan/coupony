import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/entities/home_offer_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME OFFER CARD (reusable)
// Image top (CachedNetworkImage) + "Save X%" badge + heart + title + prices.
// To swap to real images: update imageUrl in home_mock_datasource.dart only.
// ─────────────────────────────────────────────────────────────────────────────

class HomeOfferCardWidget extends StatelessWidget {
  final HomeOfferEntity offer;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const HomeOfferCardWidget({
    super.key,
    required this.offer,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 148.w,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ──────────────────────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14.r),
                      topRight: Radius.circular(14.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: offer.imageUrl,
                      width: double.infinity,
                      height: 112.h,
                      fit: BoxFit.cover,
                      // Shimmer placeholder while loading
                      placeholder: (_, _) => Container(
                        width: double.infinity,
                        height: 112.h,
                        color: AppColors.grey200,
                        child: Center(
                          child: SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary.withValues(alpha: 0.50),
                            ),
                          ),
                        ),
                      ),
                      // Fallback on error
                      errorWidget: (_, _, _) => Container(
                        width: double.infinity,
                        height: 112.h,
                        color: AppColors.grey200,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textSecondary.withValues(alpha: 0.40),
                          size: 28.w,
                        ),
                      ),
                    ),
                  ),

                  // Save % badge — top right (RTL start)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'وفر ${offer.savePercent}%',
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Heart icon — top left (RTL end)
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          offer.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: offer.isFavorite
                              ? AppColors.error
                              : AppColors.textSecondary,
                          size: 15.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Content ────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),

                    Text(
                      offer.storeName,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    Row(
                      children: [
                        Text(
                          '${offer.discountedPrice.toInt()} ج',
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          '${offer.originalPrice.toInt()}',
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ).copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
