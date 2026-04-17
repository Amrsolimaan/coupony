import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/extensions/persona_extensions.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/features/auth/domain/entities/user_persona.dart';
import 'package:coupony/features/auth/presentation/cubit/persona_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            // ✅ Wrap with BlocBuilder to get dynamic color
            BlocBuilder<PersonaCubit, UserPersona>(
              builder: (context, persona) {
                final primaryColor = persona.primaryColor;
                return Column(
                  children: store.reviews.map(
                    (review) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _ModernReviewCard(
                        review: review,
                        primaryColor: primaryColor,
                      ),
                    ),
                  ).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// MODERN REVIEW CARD — STATEFUL WITH LIKE & REPLY
// ══════════════════════════════════════════════════════════════════════════

class _ModernReviewCard extends StatefulWidget {
  final UserReviewEntity review;
  final Color primaryColor;

  const _ModernReviewCard({
    required this.review,
    required this.primaryColor,
  });

  @override
  State<_ModernReviewCard> createState() => _ModernReviewCardState();
}

class _ModernReviewCardState extends State<_ModernReviewCard> {
  bool _isLiked = false;
  int _likeCount = 0;
  bool _showReplyField = false;
  final _replyController = TextEditingController();
  final _replyFocusNode = FocusNode();
  final List<_ReplyData> _replies = [];

  @override
  void initState() {
    super.initState();
    // TODO: Load initial like state and count from backend
    _likeCount = widget.review.likesCount ?? 0;
    _isLiked = widget.review.isLikedByCurrentUser ?? false;
    
    // TODO: Load existing replies from backend
    if (widget.review.replies != null) {
      _replies.addAll(widget.review.replies!.map((r) => _ReplyData(
        authorName: r.authorName,
        content: r.content,
        timestamp: r.createdAt,
      )));
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    
    // TODO: Call API to persist like state
    // context.read<ReviewCubit>().toggleLike(widget.review.id, _isLiked);
  }

  void _toggleReplyField() {
    setState(() {
      _showReplyField = !_showReplyField;
      if (_showReplyField) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _replyFocusNode.requestFocus();
        });
      }
    });
  }

  void _submitReply() {
    final content = _replyController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _replies.add(_ReplyData(
        authorName: 'أنت', // TODO: Get from current user
        content: content,
        timestamp: DateTime.now(),
      ));
      _replyController.clear();
      _showReplyField = false;
    });

    // TODO: Call API to persist reply
    // context.read<ReviewCubit>().addReply(widget.review.id, content);
  }

  @override
  Widget build(BuildContext context) {
    final daysAgo = DateTime.now().difference(widget.review.createdAt).inDays;
    
    // ✅ Use the passed primaryColor from parent
    final primaryColor = widget.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header Row ─────────────────────────────────────────────────
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                // Avatar — START (right in RTL)
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: primaryColor.withValues(alpha: 0.12),
                  backgroundImage: widget.review.reviewerAvatar != null
                      ? NetworkImage(widget.review.reviewerAvatar!)
                      : null,
                  child: widget.review.reviewerAvatar == null
                      ? Text(
                          widget.review.reviewerName.isNotEmpty
                              ? widget.review.reviewerName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        )
                      : null,
                ),

                SizedBox(width: 12.w),

                // Name + Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.review.reviewerName,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3.h),
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

                // Star Rating — END (left in RTL)
                _buildStarRow(widget.review.rating, size: 16),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // ── Comment Text ───────────────────────────────────────────────
          Text(
            widget.review.comment,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
            textAlign: TextAlign.start,
          ),

          SizedBox(height: 14.h),

          // ── Action Buttons (Like & Reply) ──────────────────────────────
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                // Like Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleLike,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: _isLiked
                            ? primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: _isLiked
                              ? primaryColor.withValues(alpha: 0.3)
                              : AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18.w,
                            color: _isLiked ? primaryColor : AppColors.textSecondary,
                          ),
                          if (_likeCount > 0) ...[
                            SizedBox(width: 6.w),
                            Text(
                              '$_likeCount',
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _isLiked ? primaryColor : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                // Reply Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleReplyField,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: _showReplyField
                            ? primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: _showReplyField
                              ? primaryColor.withValues(alpha: 0.3)
                              : AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18.w,
                            color: _showReplyField
                                ? primaryColor
                                : AppColors.textSecondary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'رد',
                            style: AppTextStyles.customStyle(
                              context,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _showReplyField
                                  ? primaryColor
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Reply Input Field ──────────────────────────────────────────
          if (_showReplyField) ...[
            SizedBox(height: 12.h),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      focusNode: _replyFocusNode,
                      maxLines: null,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب ردك...',
                        hintStyle: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.scaffoldBackground,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: AppColors.divider.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: _submitReply,
                    icon: Icon(
                      Icons.send_rounded,
                      color: primaryColor,
                      size: 22.w,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],

          // ── Replies List ───────────────────────────────────────────────
          if (_replies.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _replies.map((reply) {
                  final replyDaysAgo = DateTime.now()
                      .difference(reply.timestamp)
                      .inDays;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Reply indicator icon
                          Container(
                            margin: EdgeInsets.only(top: 2.h, left: 8.w),
                            child: Icon(
                              Icons.subdirectory_arrow_left_rounded,
                              size: 16.w,
                              color: primaryColor.withValues(alpha: 0.6),
                            ),
                          ),
                          
                          // Reply content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      reply.authorName,
                                      style: AppTextStyles.customStyle(
                                        context,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: primaryColor,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      replyDaysAgo == 0
                                          ? 'اليوم'
                                          : 'منذ $replyDaysAgo أيام',
                                      style: AppTextStyles.customStyle(
                                        context,
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  reply.content,
                                  style: AppTextStyles.customStyle(
                                    context,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
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
}

// ══════════════════════════════════════════════════════════════════════════
// REPLY DATA MODEL
// ══════════════════════════════════════════════════════════════════════════

class _ReplyData {
  final String authorName;
  final String content;
  final DateTime timestamp;

  _ReplyData({
    required this.authorName,
    required this.content,
    required this.timestamp,
  });
}
