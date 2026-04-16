import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/store_display_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHOP INFO VIEW
// Displays everything below the 3 tab icons for tab index 0 (Info).
// Pure StatelessWidget — receives StoreDisplayEntity, has no BLoC dependency.
// ─────────────────────────────────────────────────────────────────────────────

class ShopInfoView extends StatelessWidget {
  final StoreDisplayEntity store;

  const ShopInfoView({super.key, required this.store});

  static const _blue = AppColors.primaryOfSeller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 4. Edit Button ─────────────────────────────────────────────────
        _buildEditButton(context),
        Divider(color: AppColors.divider, height: 1, thickness: 1),

        // ── 5. Expandable Sections ─────────────────────────────────────────
        _buildExpandableSection(
          context,
          title: l10n.shop_display_description_title,
          child: _buildDescription(context),
        ),
        Divider(color: AppColors.divider, height: 1, thickness: 1),

        _buildExpandableSection(
          context,
          title: l10n.shop_display_category_title,
          child: _buildCategory(context),
        ),
        Divider(color: AppColors.divider, height: 1, thickness: 1),

        _buildExpandableSection(
          context,
          title: l10n.shop_display_hours_title,
          child: _buildHours(context),
        ),
        Divider(color: AppColors.divider, height: 1, thickness: 1),

        // ── 6. Rating Summary Card ─────────────────────────────────────────
        _buildRatingSummaryCard(context),

        // ── 7. Customer Reviews ────────────────────────────────────────────
        _buildReviewsSection(context),

        SizedBox(height: 24.h),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4 — EDIT BUTTON
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildEditButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: ElevatedButton.icon(
        onPressed: () => context.push(AppRouter.sellerEditStore, extra: store),
        icon: Icon(Icons.edit_rounded, size: 16.w, color: Colors.white),
        label: Text(
          l10n.shop_display_edit_button,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          minimumSize: Size(double.infinity, 48.h),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 5 — EXPANDABLE SECTIONS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        childrenPadding:
            EdgeInsets.only(right: 16.w, left: 16.w, bottom: 12.h),
        trailing: Icon(Icons.chevron_left_rounded,
            size: 22.w, color: AppColors.textSecondary),
        title: Text(
          title,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        children: [child],
      ),
    );
  }

  // ── Description ────────────────────────────────────────────────────────────
  Widget _buildDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final desc = store.description;
    if (desc == null || desc.isEmpty) {
      return Text(
        l10n.shop_display_no_description,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      );
    }
    return Text(
      desc,
      style: AppTextStyles.customStyle(
        context,
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }

  // ── Category ───────────────────────────────────────────────────────────────
  Widget _buildCategory(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (store.categories.isEmpty) {
      return Text(
        l10n.shop_display_no_category,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      );
    }
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: store.categories.map((cat) {
        final name = isArabic ? cat.nameAr : cat.nameEn;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: _blue.withValues(alpha: 0.3)),
          ),
          child: Text(
            name,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _blue,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Hours ──────────────────────────────────────────────────────────────────
  Widget _buildHours(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dayNames = [
      l10n.shop_display_day_sun,
      l10n.shop_display_day_mon,
      l10n.shop_display_day_tue,
      l10n.shop_display_day_wed,
      l10n.shop_display_day_thu,
      l10n.shop_display_day_fri,
      l10n.shop_display_day_sat,
    ];

    final sorted = [...store.hours]
      ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

    return Column(
      children: sorted.map((slot) {
        final isClosed = slot.isClosed;
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status badge — START = right in RTL
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isClosed
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isClosed
                      ? l10n.shop_display_closed
                      : l10n.shop_display_open,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isClosed ? AppColors.error : AppColors.success,
                  ),
                ),
              ),

              // Day name + hours — END = left in RTL
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isClosed) ...[
                    Text(
                      '${slot.openDisplay} - ${slot.closeDisplay}',
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    dayNames[slot.dayOfWeek],
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 6 — RATING SUMMARY CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildRatingSummaryCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summary = store.ratingSummary;

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.star_rounded,
                  color: const Color(0xFFFFB800), size: 20.w),
              SizedBox(width: 6.w),
              Text(
                l10n.shop_display_reviews_title,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Rating breakdown ────────────────────────────────────────────
          // In RTL: child[0] = RIGHT (big score), child[1] = LEFT (bars)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big score block — START = RIGHT in RTL
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    summary.averageRating.toStringAsFixed(1),
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  _buildStarRow(summary.averageRating, size: 18),
                  SizedBox(height: 6.h),
                  Text(
                    l10n.shop_display_total_reviews(summary.totalCount),
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              SizedBox(width: 20.w),

              // Rating bars — END = LEFT in RTL
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          // Star number — START = RIGHT in RTL
                          Text(
                            '$star',
                            style: AppTextStyles.customStyle(
                              context,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(Icons.star_rounded,
                              size: 12.w,
                              color: const Color(0xFFFFB800)),
                          SizedBox(width: 6.w),
                          // Gradient bar
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 8.h,
                                    color: AppColors.divider,
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: summary.ratioForStar(star),
                                    child: Container(
                                      height: 8.h,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFD700),
                                            Color(0xFFFFB800),
                                          ],
                                          begin: Alignment.centerRight,
                                          end: Alignment.centerLeft,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          // Count
                          SizedBox(
                            width: 28.w,
                            child: Text(
                              '${summary.distribution[star] ?? 0}',
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(double rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          half
              ? Icons.star_half_rounded
              : filled
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
          color: const Color(0xFFFFB800),
          size: size.w,
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 7 — CUSTOMER REVIEWS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildReviewsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.shop_display_customer_reviews_title,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          if (store.reviews.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text(
                  l10n.shop_display_no_reviews,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...store.reviews.map(
              (review) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildReviewCard(context, review),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, UserReviewEntity review) {
    final daysAgo = DateTime.now().difference(review.createdAt).inDays;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Reviewer header ────────────────────────────────────────────
          // In RTL: avatar on START (right), name in middle, stars on END (left)
          Row(
            children: [
              // Avatar — START = RIGHT in RTL
              CircleAvatar(
                radius: 20.r,
                backgroundColor: _blue.withValues(alpha: 0.15),
                backgroundImage: review.reviewerAvatar != null
                    ? NetworkImage(review.reviewerAvatar!)
                    : null,
                child: review.reviewerAvatar == null
                    ? Text(
                        review.reviewerName.isNotEmpty
                            ? review.reviewerName[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _blue,
                        ),
                      )
                    : null,
              ),

              SizedBox(width: 10.w),

              // Name + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      daysAgo == 0 ? 'اليوم' : 'منذ $daysAgo أيام',
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Star rating — END = LEFT in RTL
              _buildStarRow(review.rating, size: 14),
            ],
          ),

          SizedBox(height: 10.h),

          // ── Comment ────────────────────────────────────────────────────
          Text(
            review.comment,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
