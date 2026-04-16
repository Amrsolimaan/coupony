import 'dart:math' as math;

import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/custom_bottom_nav_bar/seller_bottom_nav_bar.dart';
import 'package:coupony/core/widgets/images/app_cached_image.dart';
import 'package:coupony/features/Profile/presentation/cubit/Customer_Profile_cubit.dart';
import 'package:coupony/features/Profile/presentation/cubit/Customer_Profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/extensions/persona_extensions.dart';
import '../../../../auth/domain/entities/user_persona.dart';
import '../../../../auth/presentation/cubit/persona_cubit.dart';
import '../../domain/entities/seller_analytics_entity.dart';
import '../cubit/seller_analytics_cubit.dart';
import '../cubit/seller_analytics_state.dart';
import '../widgets/guest_seller_view.dart';
import '../widgets/pending_approval_view_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER ANALYTICS PAGE
// ─────────────────────────────────────────────────────────────────────────────

class SellerAnalyticsPage extends HookWidget {
  const SellerAnalyticsPage({super.key});

  // ── Seller brand colour alias ──────────────────────────────────────────────
  static const _blue = AppColors.primaryOfSeller; // 0xFF215194

  @override
  Widget build(BuildContext context) {
    // ✅ Load profile only for authenticated users
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final persona = context.read<PersonaCubit>().state;
        if (!persona.isGuest) {
          context.read<ProfileCubit>().loadProfile();
        }
      });
      return null;
    }, []);

    return BlocConsumer<SellerAnalyticsCubit, SellerAnalyticsState>(
      listener: (context, state) {
        if (state is SellerAnalyticsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: null, // Custom header lives inside the body
          body: _buildBody(context, state),
          bottomNavigationBar: SellerBottomNavBar(
            currentIndex: 2, // Analytics tab
            onTap: (index) => _handleNavigation(context, index, state),
          ),
        );
      },
    );
  }

  // ── Body Router ────────────────────────────────────────────────────────────
  // ✅ PersonaCubit is the single authority for view-mode branching.
  // SellerAnalyticsCubit only drives the active-seller data states below.

  Widget _buildBody(BuildContext context, SellerAnalyticsState state) {
    final persona = context.watch<PersonaCubit>().state;

    // ✅ Check for guest mode first
    if (persona is GuestPersona) {
      return const GuestSellerViewWidget(icon: FontAwesomeIcons.chartColumn);
    }
    
    // ✅ Check for seller guest mode (skip button on login)
    if (persona is SellerPersona && persona.isGuest) {
      return const GuestSellerViewWidget(icon: FontAwesomeIcons.chartColumn);
    }
    
    // ✅ Check for pending approval
    if (persona is SellerPersona && persona.isPending) {
      return PendingApprovalViewWidget(
        icon: FontAwesomeIcons.chartColumn,
        onContactUs: () {},
      );
    }

    // Active seller — delegate to SellerAnalyticsCubit state.
    if (state is SellerAnalyticsLoading) return _buildLoading();

    if (state is SellerAnalyticsError) {
      return _buildError(context, state.message);
    }

    if (state is SellerAnalyticsDataLoaded) {
      return _buildContent(context, state.analytics, state.selectedFilter);
    }

    return _buildLoading();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONTENT LAYOUT
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildContent(
    BuildContext context,
    SellerAnalyticsEntity analytics,
    AnalyticsFilter selectedFilter,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. Top Header ──────────────────────────────────────────────
            _buildHeader(context, analytics),

            // ── 2. Filter Pills ────────────────────────────────────────────
            _buildFilterRow(context, selectedFilter),
            SizedBox(height: 12.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 3. Monthly Goal Card ─────────────────────────────────
                  _buildGoalCard(context, analytics),
                  SizedBox(height: 8.h),

                  // ── 4. New Followers Card ────────────────────────────────
                  _buildFollowersCard(context, analytics),
                  SizedBox(height: 8.h),

                  // ── 5. Offer Distribution Chart ──────────────────────────
                  _buildChartCard(context, analytics),
                  SizedBox(height: 14.h),

                  // ── 6. Best Offers List ──────────────────────────────────
                  _buildTopOffersSection(context, analytics),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1 — HEADER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context, SellerAnalyticsEntity analytics) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand name + greeting + avatar (LEFT side for LTR, RIGHT for RTL)
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              String? avatarUrl;
              String userName = analytics.storeName;
              
              if (state is ProfileLoaded) {
                avatarUrl = state.user.avatar;
                userName = state.user.fullName.isNotEmpty 
                    ? state.user.fullName 
                    : analytics.storeName;
              } else if (state is ProfileUpdateSuccess) {
                avatarUrl = state.user.avatar;
                userName = state.user.fullName.isNotEmpty 
                    ? state.user.fullName 
                    : analytics.storeName;
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAvatar(context, avatarUrl),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.seller_analytics_greeting,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        userName,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          // Hamburger icon (RIGHT side for LTR, LEFT for RTL)
          IconButton(
            icon: FaIcon(FontAwesomeIcons.bars, size: 20.w, color: AppColors.textPrimary),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String? avatarUrl) {
    return AppCachedImageCircular(
      imageUrl: avatarUrl ?? '',
      size: 42.w,
      borderWidth: 2.w,
      borderColor: _blue,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2 — FILTER ROW
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFilterRow(BuildContext context, AnalyticsFilter selected) {
    final l10n = AppLocalizations.of(context)!;
    
    final filterLabels = <AnalyticsFilter, String>{
      AnalyticsFilter.all: l10n.seller_analytics_filter_all,
      AnalyticsFilter.today: l10n.seller_analytics_filter_today,
      AnalyticsFilter.last7Days: l10n.seller_analytics_filter_last_7_days,
      AnalyticsFilter.thisMonth: l10n.seller_analytics_filter_this_month,
      AnalyticsFilter.thisYear: l10n.seller_analytics_filter_this_year,
    };

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(bottom: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // No reverse: true — Directionality(rtl) makes the scroll start from
        // the right edge automatically.
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: AnalyticsFilter.values.map((filter) {
            final isSelected = filter == selected;
            return Padding(
              padding: EdgeInsetsDirectional.only(end: 7.w),
              child: GestureDetector(
                onTap: () => context
                    .read<SellerAnalyticsCubit>()
                    .changeFilter(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? _blue : AppColors.divider,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    filterLabels[filter]!,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3 — MONTHLY GOAL CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildGoalCard(BuildContext context, SellerAnalyticsEntity analytics) {
    final l10n = AppLocalizations.of(context)!;
    final completion = analytics.goalCompletionRatio;
    final completionPct = analytics.goalCompletionPercent;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3470), _blue, Color(0xFF2D66B0)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      // ── Row: START(right in RTL) = Gauge │ END(left in RTL) = Text ──────────
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── children[0] = START in RTL = physical RIGHT = Circular gauge ────
          SizedBox(
            width: 78.w,
            height: 78.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(78.w, 78.w),
                  painter: _GoalGaugePainter(completion),
                ),
                Text(
                  '$completionPct%',
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // ── children[1] = END in RTL = physical LEFT = Text section ─────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon BEFORE text: Row([icon, gap, text]) — in RTL: icon on right
                Row(
                  children: [
                    Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.bullseye,
                          size: 13.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        l10n.seller_analytics_monthly_goal_title,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // ── Achieved + Goal numbers ──────────────────────────────────
                Row(
                  children: [
                    _buildGoalStat(
                      context,
                      label: l10n.seller_analytics_achieved_label,
                      value: _formatNumber(analytics.monthlyAchieved),
                      isHighlight: true,
                    ),
                    SizedBox(width: 14.w),
                    _buildGoalStat(
                      context,
                      label: l10n.seller_analytics_goal_label,
                      value: _formatNumber(analytics.monthlyGoal),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // ── Progress bar ─────────────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: completion,
                    minHeight: 5.h,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(height: 6.h),

                // ── Footer: completion label | growth badge ──────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.seller_analytics_goal_completion(
                          completionPct.toString()),
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_upward_rounded,
                          color: Color(0xFF7DFFB3),
                          size: 12,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '+${analytics.goalGrowthPercent.toInt()}%',
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7DFFB3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStat(
    BuildContext context, {
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.customStyle(
            context,
            fontSize: isHighlight ? 22 : 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4 — NEW FOLLOWERS CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFollowersCard(
    BuildContext context,
    SellerAnalyticsEntity analytics,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      // In RTL: first child = START = RIGHT → info block on right, badge on left
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Info block — START = right in RTL (primary content) ───────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.userGroup,
                    size: 14.sp,
                    color: _blue,
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    l10n.seller_analytics_new_followers_title,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                l10n.seller_analytics_this_month(analytics.newFollowers.toString()),
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // ── Growth badge — END = left in RTL (secondary indicator) ────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_upward_rounded,
                  color: AppColors.success,
                  size: 13,
                ),
                SizedBox(width: 3.w),
                Text(
                  '+${analytics.followersGrowthPercent.toInt()}%',
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 5 — OFFER DISTRIBUTION CHART CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildChartCard(BuildContext context, SellerAnalyticsEntity analytics) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // start = RIGHT in RTL
        children: [
          Text(
            l10n.seller_analytics_offer_distribution_title,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          // In RTL: first child = START = RIGHT → donut on right, legend on left
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Donut chart — START = right in RTL (focal visual element) ─
              SizedBox(
                width: 110.w,
                height: 110.w,
                child: CustomPaint(
                  painter: _DonutChartPainter(analytics.offerDistribution),
                ),
              ),

              SizedBox(width: 10.w),

              // ── Legend — END = left in RTL ─────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: analytics.offerDistribution.map((item) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 7.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: Color(item.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 7.w),
                          Text(
                            '${item.label}  ${item.percentage.toInt()}%',
                            style: AppTextStyles.customStyle(
                              context,
                              fontSize: 11,
                              color: AppColors.textSecondary,
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

  // ══════════════════════════════════════════════════════════════════════════
  // 6 — BEST OFFERS LIST
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTopOffersSection(
    BuildContext context,
    SellerAnalyticsEntity analytics,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // start = RIGHT in RTL
      children: [
        Text(
          l10n.seller_analytics_top_offers_title,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        ...analytics.topOffers.map(
          (offer) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _buildOfferItem(context, offer),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferItem(BuildContext context, TopOfferEntity offer) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // start = RIGHT in RTL
        children: [
          // ── Title row ─────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bullet + title — START = right in RTL (primary content)
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: const BoxDecoration(
                        color: _blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        offer.title,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tag chip — END = left in RTL (secondary label)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  offer.tag,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _blue,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 5.h),

          // ── Stats row — START = right in RTL ──────────────────────────────
          Row(
            children: [
              _buildStatBadge(
                context,
                icon: FontAwesomeIcons.eye,
                value: '${offer.views}',
              ),
              SizedBox(width: 12.w),
              _buildStatBadge(
                context,
                icon: FontAwesomeIcons.arrowsRotate,
                value: l10n.seller_analytics_usage_count(offer.usages.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context, {
    required IconData icon,
    required String value,
  }) {
    // In RTL: first child = START = RIGHT → icon on right, value on left
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 11.sp, color: AppColors.textSecondary),
        SizedBox(width: 4.w),
        Text(
          value,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOADING STATE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _blue,
            strokeWidth: 3.w,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR STATE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildError(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64.w, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              message,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<SellerAnalyticsCubit>().loadAnalytics(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                padding:
                    EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                l10n.seller_analytics_retry_button,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  String _formatNumber(double value) {
    final n = value.toInt();
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = n % 1000;
      if (remainder == 0) return '$thousands,000';
      return '$thousands,${remainder.toString().padLeft(3, '0')}';
    }
    return n.toString();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ══════════════════════════════════════════════════════════════════════════

  void _handleNavigation(
    BuildContext context,
    int index,
    SellerAnalyticsState state,
  ) {
    // ✅ Get guest/pending status from PersonaCubit instead of state
    final persona = context.read<PersonaCubit>().state;
    final isGuest = persona is GuestPersona || 
                    (persona is SellerPersona && persona.isGuest);
    final isPending = persona is SellerPersona && persona.isPending;
    final args = {'isGuest': isGuest, 'isPending': isPending};

    switch (index) {
      case 0:
        context.go(AppRouter.customerProfile);
        break;
      case 1:
        context.go(AppRouter.sellerStore, extra: args);
        break;
      case 2:
        break; // Already here
      case 3:
        context.go(AppRouter.sellerOffers, extra: args);
        break;
      case 4:
        context.go(AppRouter.sellerHome, extra: args);
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DONUT CHART PAINTER
// No external chart library needed — pure CustomPainter.
// ─────────────────────────────────────────────────────────────────────────────

class _DonutChartPainter extends CustomPainter {
  final List<OfferTypeDistributionEntity> data;

  const _DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final strokeWidth = outerRadius * 0.38;
    final arcRadius = outerRadius - strokeWidth / 2;
    const gapRadians = 0.05; // tiny gap between segments

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    final total = data.fold(0.0, (sum, d) => sum + d.percentage);
    double startAngle = -math.pi / 2; // top of circle

    for (final item in data) {
      final sweep =
          (item.percentage / total) * 2 * math.pi - gapRadians;
      paint.color = Color(item.colorValue);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep + gapRadians;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) =>
      oldDelegate.data != data;
}

// ─────────────────────────────────────────────────────────────────────────────
// GOAL GAUGE PAINTER
// Circular arc showing goal completion (0.0–1.0).
// ─────────────────────────────────────────────────────────────────────────────

class _GoalGaugePainter extends CustomPainter {
  final double completion; // 0.0 – 1.0

  const _GoalGaugePainter(this.completion);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.20;
    final arcRadius = radius - strokeWidth / 2;

    // Background track
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.white.withValues(alpha: 0.20)
      ..isAntiAlias = true;

    canvas.drawCircle(center, arcRadius, bgPaint);

    // Foreground arc
    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final sweepAngle = completion.clamp(0.0, 1.0) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      -math.pi / 2, // start from 12 o'clock
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_GoalGaugePainter oldDelegate) =>
      oldDelegate.completion != completion;
}
