import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../domain/entities/offer_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OFFER DETAILS PAGE
//
// Layout (top → bottom in a scroll Column):
//
//   ┌─ Stack(clipBehavior: Clip.none)  ← inner hero stack ──────────────────┐
//   │   • SizedBox(_heroH)  — hero image                                     │
//   │   • PositionedDirectional(top: topPad+10, start:16)  — back button     │
//   │   • Positioned(bottom: _dotsBottom)  — pagination dots                 │
//   │   • Positioned(bottom: -_cardPeek)   — floating store card  ◄ key      │
//   └────────────────────────────────────────────────────────────────────────┘
//   SizedBox(_cardPeek + 16)   ← reveals the part of card below image
//   _buildMainContent          ← FLAT top (no border radius)
//   Divider
//   _buildTermsRow
//
// The _cardPeek value controls how much of the store card hangs below the
// image — i.e. the visual overlap amount.
// ─────────────────────────────────────────────────────────────────────────────

class OfferDetailsPage extends StatelessWidget {
  final OfferEntity offer;
  const OfferDetailsPage({super.key, required this.offer});

  // ── Layout constants ───────────────────────────────────────────────────────
  static const double _heroH = 252; // hero image height (logical px)
  static const double _cardPeek = 28; // card portion below image
  static const double _dotsBottom = 60; // dots distance from hero bottom

  // ── Status helpers ─────────────────────────────────────────────────────────
  Color get _statusColor {
    switch (offer.offerStatus) {
      case OfferStatus.active:
        return const Color(0xFF22C55E);
      case OfferStatus.expired:
        return const Color(0xFFEF4444);
      case OfferStatus.scheduled:
        return const Color(0xFFF59E0B);
    }
  }

  String _getStatusLabel(AppLocalizations l10n) {
    return switch (offer.offerStatus) {
      OfferStatus.active => l10n.offer_details_status_active_now,
      OfferStatus.expired => l10n.seller_offer_status_expired,
      OfferStatus.scheduled => l10n.seller_offer_status_scheduled,
    };
  }

  String _fmtDate(DateTime d, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return intl.DateFormat('d MMMM yyyy', locale).format(d);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildEditButton(context, l10n),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero section: image + overlays + floating card ──────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                // [1] Hero image — defines Stack's intrinsic height
                SizedBox(
                  height: _heroH.h,
                  width: double.infinity,
                  child: _buildHeroImage(),
                ),

                // [2] Back button — leading (start) side in both LTR and RTL
                PositionedDirectional(
                  top: topPad + 10.h,
                  start: 16.w,
                  child: _buildBackButton(context),
                ),

                // [3] Pagination dots — near image bottom, above card
                Positioned(
                  bottom: _dotsBottom.h,
                  left: 0,
                  right: 0,
                  child: _buildDots(),
                ),

                // [4] Floating store card — negative bottom = overlaps image
                Positioned(
                  bottom: -_cardPeek.h,
                  left: 16.w,
                  right: 16.w,
                  child: _buildStoreCard(context),
                ),
              ],
            ),

            // ── Space that reveals the card sticking out below the image ────
            SizedBox(height: _cardPeek.h + 16.h),

            // ── Main content — FLAT top (zero border radius) ─────────────────
            _buildMainContent(context, l10n),

            Divider(height: 1, color: Colors.grey.shade200),
            _buildTermsRow(context, l10n),
            SizedBox(height: botPad + 16.h),
          ],
        ),
      ),
    );
  }

  // ── Hero image ─────────────────────────────────────────────────────────────

  Widget _buildHeroImage() {
    if (offer.imageUrl != null) {
      return Image.network(
        offer.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, st) => _heroPlaceholder(),
        loadingBuilder: (ctx, child, progress) =>
            progress == null ? child : _heroPlaceholder(),
      );
    }
    return _heroPlaceholder();
  }

  Widget _heroPlaceholder() => Container(
        color: const Color(0xFFF3F4F6),
        child: Center(
          child: Icon(Icons.image_outlined,
              size: 60, color: Colors.grey.shade400),
        ),
      );

  // ── Back button ────────────────────────────────────────────────────────────

  Widget _buildBackButton(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x20000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isRtl
                ? Icons.chevron_right_rounded
                : Icons.chevron_left_rounded,
            color: Colors.black87,
            size: 22.w,
          ),
        ),
      ),
    );
  }

  // ── Pagination dots ────────────────────────────────────────────────────────

  Widget _buildDots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final active = i == 0;
          return Container(
            width: active ? 8.w : 6.w,
            height: 6.w,
            margin: EdgeInsets.symmetric(horizontal: 2.5.w),
            decoration: BoxDecoration(
              color: active ? Colors.black87 : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4.r),
            ),
          );
        }),
      );

  // ── Floating store card ────────────────────────────────────────────────────

  Widget _buildStoreCard(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(16.r),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: _storeLogoWidget(),
            ),
            SizedBox(width: 14.w),
            // Name + rating
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.storeName,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        offer.storeRating.toStringAsFixed(1),
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      ...List.generate(
                        5,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 16.w,
                          color: i < offer.storeRating.round()
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFD1D5DB),
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
    );
  }

  Widget _storeLogoWidget() {
    const double s = 62;
    if (offer.storeLogoUrl != null) {
      return Image.network(
        offer.storeLogoUrl!,
        width: s,
        height: s,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, st) => _logoFallback(s),
      );
    }
    return _logoFallback(s);
  }

  Widget _logoFallback(double s) => Container(
        width: s,
        height: s,
        color: AppColors.primaryOfSeller.withValues(alpha: 0.1),
        child: const Icon(
          Icons.store_rounded,
          color: AppColors.primaryOfSeller,
          size: 28,
        ),
      );

  // ── Main scrollable content — FLAT top ────────────────────────────────────

  Widget _buildMainContent(BuildContext context, AppLocalizations l10n) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            offer.title,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.4,
            ),
          ),
          SizedBox(height: 6.h),
          // Description
          Text(
            offer.description,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 14.h),
          // Categories
          if (offer.category != null || offer.subCategory != null) ...[
            _buildCategoryRow(context, l10n),
            SizedBox(height: 16.h),
          ],
          // Sizes
          if (offer.sizes.isNotEmpty) ...[
            _buildSizesSection(context, l10n),
            SizedBox(height: 16.h),
          ],
          // Colors
          if (offer.colorValues.isNotEmpty) ...[
            _buildColorsSection(context, l10n),
            SizedBox(height: 24.h),
          ],
          // Status + date
          _buildStatusRow(context, l10n),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ── Category row ───────────────────────────────────────────────────────────

  Widget _buildCategoryRow(BuildContext context, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.offer_details_category_label,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 8.w),
        if (offer.category != null) _GreyChip(label: offer.category!),
        if (offer.subCategory != null) ...[
          SizedBox(width: 6.w),
          _GreyChip(label: offer.subCategory!),
        ],
      ],
    );
  }

  // ── Sizes section ──────────────────────────────────────────────────────────

  Widget _buildSizesSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.offer_details_sizes_title,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          direction: Axis.horizontal,
          spacing: 8.w,
          runSpacing: 8.h,
          children: List.generate(offer.sizes.length, (i) {
            final isSelected = i == offer.sizes.length - 1;
            return _SizeChip(label: offer.sizes[i], isSelected: isSelected);
          }),
        ),
      ],
    );
  }

  // ── Colors section ─────────────────────────────────────────────────────────

  Widget _buildColorsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.offer_details_colors_title,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          direction: Axis.horizontal,
          spacing: 10.w,
          runSpacing: 8.h,
          children: offer.colorValues.map((cv) {
            final c = Color(cv);
            final isLight = c.r > 0.86 && c.g > 0.86 && c.b > 0.86;
            return Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLight
                      ? const Color(0xFFD1D5DB)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Status row ─────────────────────────────────────────────────────────────

  Widget _buildStatusRow(BuildContext context, AppLocalizations l10n) {
    final ed = offer.endDate;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Start: expiry date
        if (ed != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.offer_details_valid_until,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _fmtDate(ed, context),
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          )
        else
          const SizedBox.shrink(),

        // End: rounded status pill
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: _statusColor,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Text(
            _getStatusLabel(l10n),
            style: AppTextStyles.customStyle(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ── Terms row ──────────────────────────────────────────────────────────────

  Widget _buildTermsRow(BuildContext context, AppLocalizations l10n) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: () => _showTermsSheet(context, l10n),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.gavel_rounded,
              color: AppColors.primaryOfSeller,
              size: 18.w,
            ),
            SizedBox(width: 8.w),
            Text(
              l10n.offer_details_terms_title,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              isRtl
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 22.w,
            ),
          ],
        ),
      ),
    );
  }

  // ── Terms bottom sheet ─────────────────────────────────────────────────────

  void _showTermsSheet(BuildContext context, AppLocalizations l10n) {
    final terms = _buildTermsList(context, l10n);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.90,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ────────────────────────────────────────────────
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // ── Header ─────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryOfSeller.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.gavel_rounded,
                        color: AppColors.primaryOfSeller,
                        size: 18.w,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      l10n.offer_details_terms_title,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 6.h),
              Divider(color: Colors.grey.shade100, height: 1),
              SizedBox(height: 4.h),

              // ── Terms list ──────────────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
                  itemCount: terms.length,
                  separatorBuilder: (_, __) => SizedBox(height: 14.h),
                  itemBuilder: (_, i) => _TermItem(
                    number: i + 1,
                    text: terms[i],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a contextual, offer-specific list of terms using l10n strings.
  List<String> _buildTermsList(BuildContext context, AppLocalizations l10n) {
    final terms = <String>[];

    // ── Validity ──────────────────────────────────────────────────────────────
    if (offer.endDate != null) {
      terms.add(
        l10n.offer_terms_validity_date(_fmtDate(offer.endDate!, context)),
      );
    } else {
      terms.add(l10n.offer_terms_validity_open);
    }

    // ── Discount type ─────────────────────────────────────────────────────────
    switch (offer.discountType) {
      case DiscountType.percentage:
        terms.add(
          l10n.offer_terms_discount_percentage(
            offer.discountPercent.toStringAsFixed(0),
            offer.originalPrice.toStringAsFixed(0),
            offer.discountedPrice.toStringAsFixed(0),
          ),
        );
      case DiscountType.fixedAmount:
        final saved =
            (offer.originalPrice - offer.discountedPrice).toStringAsFixed(0);
        terms.add(l10n.offer_terms_discount_fixed(saved));
      case DiscountType.buyGet:
        terms.add(l10n.offer_terms_discount_buy_get);
    }

    // ── Category scope ────────────────────────────────────────────────────────
    if (offer.category != null) {
      final scope = offer.subCategory != null
          ? '${offer.category!} › ${offer.subCategory!}'
          : offer.category!;
      terms.add(l10n.offer_terms_category_scope(scope));
    }

    // ── Sizes ─────────────────────────────────────────────────────────────────
    if (offer.sizes.isNotEmpty) {
      final sizeList = offer.sizes.join('، ');
      terms.add(l10n.offer_terms_sizes(sizeList));
    }

    // ── Scheduling ────────────────────────────────────────────────────────────
    if (offer.startDate != null &&
        offer.startDate!.isAfter(DateTime.now())) {
      terms.add(
        l10n.offer_terms_start_date(_fmtDate(offer.startDate!, context)),
      );
    }

    // ── Store rights (always shown) ───────────────────────────────────────────
    terms.addAll([
      l10n.offer_terms_no_combine,
      l10n.offer_terms_store_rights(offer.storeName),
      l10n.offer_terms_return_policy,
    ]);

    return terms;
  }

  // ── Bottom edit button ─────────────────────────────────────────────────────

  Widget _buildEditButton(BuildContext context, AppLocalizations l10n) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: () => context.push(
              AppRouter.sellerManageOffer,
              extra: offer,
            ),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            label: Text(
              l10n.offer_details_edit_button,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOfSeller,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Light-grey category chip  e.g. "ملابس"
class _GreyChip extends StatelessWidget {
  final String label;
  const _GreyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Fixed-size size chip  44 × 44.  isSelected → filled primary blue, else outlined.
class _SizeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _SizeChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryOfSeller : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryOfSeller
              : const Color(0xFFD1D5DB),
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// A single numbered term item used inside the terms bottom sheet.
class _TermItem extends StatelessWidget {
  final int number;
  final String text;
  const _TermItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numbered badge
        Container(
          width: 26.w,
          height: 26.w,
          decoration: BoxDecoration(
            color: AppColors.primaryOfSeller.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: AppTextStyles.customStyle(
              context,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryOfSeller,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        // Term text
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
