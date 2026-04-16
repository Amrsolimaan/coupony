import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../domain/entities/home_banner_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME BANNER CAROUSEL
// Full-width PageView with dark overlay cards + animated dot indicators.
// ─────────────────────────────────────────────────────────────────────────────

class HomeBannerCarouselWidget extends StatefulWidget {
  final List<HomeBannerEntity> banners;

  const HomeBannerCarouselWidget({super.key, required this.banners});

  @override
  State<HomeBannerCarouselWidget> createState() =>
      _HomeBannerCarouselWidgetState();
}

class _HomeBannerCarouselWidgetState extends State<HomeBannerCarouselWidget> {
  final _ctrl = PageController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          // ── PageView ───────────────────────────────────────────────────────
          SizedBox(
            height: 160.h,
            child: PageView.builder(
              controller: _ctrl,
              itemCount: widget.banners.length,
              itemBuilder: (_, i) =>
                  _BannerCard(banner: widget.banners[i]),
            ),
          ),

          SizedBox(height: 10.h),

          // ── Dots indicator ─────────────────────────────────────────────────
          Skeleton.ignore(
            child: SmoothPageIndicator(
              controller: _ctrl,
              count: widget.banners.length,
              effect: ExpandingDotsEffect(
                dotHeight: 6.h,
                dotWidth: 6.w,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.grey200,
                expansionFactor: 3,
                spacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANNER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BannerCard extends StatelessWidget {
  final HomeBannerEntity banner;

  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: const Color(0xFF1A1A2E),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // ── Background image (right side, RTL start) ───────────────────
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 160.w,
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: const Color(0xFF2A2A3E)),
                errorWidget: (_, _, _) => Container(
                  color: const Color(0xFF2A2A3E),
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.white.withValues(alpha: 0.20),
                    size: 36,
                  ),
                ),
              ),
            ),

            // ── Dark gradient overlay (for text readability) ───────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF1A1A2E).withValues(alpha: 0.95),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    stops: const [0.30, 0.75],
                  ),
                ),
              ),
            ),

            // ── Text content (left side, RTL end) ─────────────────────────
            Positioned(
              left: 16.w,
              top: 0,
              bottom: 0,
              right: 130.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discount up to',
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.70),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    banner.discountLabel,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'minimum transaction ${banner.minTransaction}',
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    banner.dateRange,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // CTA button
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      banner.ctaLabel,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── "Term of Condition" ────────────────────────────────────────
            Positioned(
              left: 16.w,
              bottom: 10.h,
              child: Text(
                'Term of Condition',
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
