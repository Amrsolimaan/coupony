import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/home_offer_entity.dart';
import 'home_offer_card_widget.dart';
import 'home_section_header_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME OFFERS ROW (reusable)
// Section header + horizontal scroll of HomeOfferCardWidget.
// Used for: Personalized, Travel, Egypt, Favorites sections.
// ─────────────────────────────────────────────────────────────────────────────

class HomeOffersRowWidget extends StatelessWidget {
  final String title;
  final List<HomeOfferEntity> offers;
  final VoidCallback? onSeeAll;
  final ValueChanged<HomeOfferEntity>? onOfferTap;
  final ValueChanged<String>? onFavoriteTap;

  const HomeOffersRowWidget({
    super.key,
    required this.title,
    required this.offers,
    this.onSeeAll,
    this.onOfferTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeaderWidget(title: title, onSeeAll: onSeeAll),
        SizedBox(height: 6.h),
        SizedBox(
          height: 220.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: offers.length,
            itemBuilder: (_, i) => HomeOfferCardWidget(
              offer: offers[i],
              onTap: () => onOfferTap?.call(offers[i]),
              onFavoriteTap: () => onFavoriteTap?.call(offers[i].id),
            ),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}
