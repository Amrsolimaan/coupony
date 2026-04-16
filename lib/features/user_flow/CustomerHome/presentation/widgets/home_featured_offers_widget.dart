import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME FEATURED OFFERS WIDGET
// Large horizontal scrollable offer cards with image, discount badge, and details.
// ─────────────────────────────────────────────────────────────────────────────

class HomeFeaturedOffersWidget extends StatelessWidget {
  final List<FeaturedOfferItem> offers;
  final ValueChanged<FeaturedOfferItem>? onOfferTap;
  final ValueChanged<String>? onFavoriteTap;

  const HomeFeaturedOffersWidget({
    super.key,
    required this.offers,
    this.onOfferTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 6.h),
          child: Text(
            AppLocalizations.of(context)!.home_featured_offers_title,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Offers list
        SizedBox(
          height: 280.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: offers.length,
            itemBuilder: (_, i) => _FeaturedOfferCard(
              offer: offers[i],
              onTap: () => onOfferTap?.call(offers[i]),
              onFavoriteTap: () => onFavoriteTap?.call(offers[i].id),
            ),
          ),
        ),

        SizedBox(height:12.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FEATURED OFFER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturedOfferCard extends StatelessWidget {
  final FeaturedOfferItem offer;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const _FeaturedOfferCard({
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
          width: 200.w,
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + badges
              Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 160.h,
                      color: Colors.grey.shade200,
                      child: offer.imageUrl != null
                          ? Image.network(
                              offer.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),

                  // Discount badge (top right)
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: Colors.white,
                            size: 14.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Save ${offer.discountPercent}%',
                            style: AppTextStyles.customStyle(
                              context,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Heart icon (top left)
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          offer.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: offer.isFavorite
                              ? AppColors.error
                              : AppColors.textSecondary,
                          size: 18.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      offer.title,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6.h),

                    // Store name
                    Text(
                      offer.storeName,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8.h),

                    // Prices
                    Row(
                      children: [
                        Text(
                          '${offer.discountedPrice.toInt()} ج',
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '${offer.originalPrice.toInt()} ج',
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 12,
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

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.shade400,
          size: 40,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FEATURED OFFER ITEM MODEL
// ─────────────────────────────────────────────────────────────────────────────

class FeaturedOfferItem {
  final String id;
  final String title;
  final String storeName;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercent;
  final String? imageUrl;
  final bool isFavorite;

  const FeaturedOfferItem({
    required this.id,
    required this.title,
    required this.storeName,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercent,
    this.imageUrl,
    this.isFavorite = false,
  });
}
