import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/custom_bottom_nav_bar/seller_bottom_nav_bar.dart';
import 'package:coupony/core/widgets/images/app_cached_image.dart';
import 'package:coupony/core/widgets/side_bar.dart';
import 'package:coupony/features/auth/presentation/widgets/role_animation_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/extensions/persona_extensions.dart';
import '../../../../../features/Profile/presentation/cubit/Customer_Profile_cubit.dart';
import '../../../../../features/Profile/presentation/cubit/Customer_Profile_state.dart';
import '../../../../../features/auth/domain/entities/user_persona.dart';
import '../../../../../features/auth/presentation/cubit/persona_cubit.dart';
import '../../domain/entities/offer_entity.dart';
import '../../domain/entities/store_stats_entity.dart';
import '../cubit/seller_home_cubit.dart';
import '../cubit/seller_home_state.dart';
import '../widgets/guest_seller_view.dart';
import '../widgets/pending_approval_view_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER HOME PAGE
// ─────────────────────────────────────────────────────────────────────────────

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  static const _blue = AppColors.primaryOfSeller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataIfAuthenticated();
    });
  }

  /// ✅ Guard: Only load data for authenticated users
  void _loadDataIfAuthenticated() {
    final persona = context.read<PersonaCubit>().state;
    
    // Skip API calls for guest users
    if (persona.isGuest) return;
    
    // Authenticated user - load profile data
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLogoutSuccess) {
          context.go(AppRouter.login);
        }
      },
      child: BlocConsumer<SellerHomeCubit, SellerHomeState>(
        listener: (context, state) {
          // Reserved for real API error snackbars.
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            appBar: null,
            body: _buildBody(context, state),
            bottomNavigationBar: SellerBottomNavBar(
              currentIndex: 4,
              onTap: (index) => _handleNavigation(context, index, state),
            ),
          );
        },
      ),
    );
  }

  // ── Body router ────────────────────────────────────────────────────────────
  // PersonaCubit is the single authority for view-mode branching.
  // SellerHomeCubit only drives the active-seller data states below.

  Widget _buildBody(BuildContext context, SellerHomeState state) {
    final persona = context.watch<PersonaCubit>().state;

    // ✅ Check for guest mode first
    if (persona is GuestPersona) {
      return const GuestSellerViewWidget(icon: FontAwesomeIcons.house);
    }
    
    // ✅ Check for seller guest mode (skip button on login)
    if (persona is SellerPersona && persona.isGuest) {
      return const GuestSellerViewWidget(icon: FontAwesomeIcons.house);
    }
    
    // ✅ Check for pending approval
    if (persona is SellerPersona && persona.isPending) {
      return PendingApprovalViewWidget(
        icon: FontAwesomeIcons.house,
        onContactUs: () {},
      );
    }

    // Active seller — delegate to SellerHomeCubit state.
    if (state is SellerHomeLoading || state is SellerHomeInitial) {
      return _buildLoading();
    }
    if (state is SellerHomeDataLoaded) {
      return _buildDashboard(context, state);
    }
    if (state is SellerHomeError) {
      return _buildError(context, state.message);
    }
    return _buildLoading();
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Widget _buildLoading() =>
      Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 3));

  // ── Error ──────────────────────────────────────────────────────────────────

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
              textAlign: TextAlign.center,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.read<SellerHomeCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
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
  // DASHBOARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildDashboard(BuildContext context, SellerHomeDataLoaded state) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: _blue,
        onRefresh: () => context.read<SellerHomeCubit>().refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                _buildHeader(context),
                SizedBox(height: 12.h),
                _buildSubscriptionBanner(context),
                SizedBox(height: 14.h),
                _buildDateFilter(context, state),
                SizedBox(height: 8.h),
                _buildStatsGrid(context, state.stats),
                SizedBox(height: 16.h),
                _buildQuickActionsSection(context),
                SizedBox(height: 16.h),
                _buildActiveOffersSection(context, state.activeOffers),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1 — HEADER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        String? avatarUrl;
        String userName = 'M Brand';

        if (profileState is ProfileLoaded) {
          avatarUrl = profileState.user.avatar;
          userName = profileState.user.fullName.isNotEmpty
              ? profileState.user.fullName
              : 'M Brand';
        } else if (profileState is ProfileUpdateSuccess) {
          avatarUrl = profileState.user.avatar;
          userName = profileState.user.fullName.isNotEmpty
              ? profileState.user.fullName
              : 'M Brand';
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Menu + Bell ────────────────────────────────────────────────
            Row(
              children: [
                IconButton(
                  onPressed: () => _openSideBar(context, l10n, userName),
                  icon: Icon(
                    Icons.menu_rounded,
                    size: 26.w,
                    color: AppColors.textPrimary,
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () => context.push(AppRouter.notificationsPage),
                      icon: Icon(
                        Icons.notifications_outlined,
                        size: 26.w,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    PositionedDirectional(
                      top: 8.h,
                      end: 8.w,
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: _blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Name + Avatar ──────────────────────────────────────────────
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.seller_analytics_greeting,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 13,
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
                SizedBox(width: 10.w),
                // Avatar
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _blue, width: 2),
                  ),
                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? AppCachedImage(
                            imageUrl: avatarUrl,
                            width: 44.w,
                            height: 44.w,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: _blue.withValues(alpha: 0.15),
                            child: Center(
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : 'M',
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _blue,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2 — SUBSCRIPTION BANNER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSubscriptionBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.seller_home_subscription_renew_title,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.seller_home_subscription_renew_body,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 11,
                    color: const Color(0xFFB45309),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(
                Icons.autorenew_rounded,
                color: Colors.white,
                size: 22.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3 — DATE FILTER CHIP
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildDateFilter(BuildContext context, SellerHomeDataLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    String filterText = l10n.seller_analytics_filter_last_7_days;

    if (state.filterType == DateFilterType.last30Days) {
      filterText = l10n.seller_analytics_filter_last_30_days;
    } else if (state.filterType == DateFilterType.custom &&
        state.customDateRange != null) {
      final start =
          '${state.customDateRange!.start.day}/${state.customDateRange!.start.month}';
      final end =
          '${state.customDateRange!.end.day}/${state.customDateRange!.end.month}';
      filterText = '$start - $end';
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: PopupMenuButton<DateFilterType>(
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        color: Colors.white,
        onSelected: (type) async {
          if (type == DateFilterType.custom) {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: _blue,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: AppColors.textPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (range != null && context.mounted) {
              context.read<SellerHomeCubit>().changeDateFilter(
                type,
                customRange: range,
              );
            }
          } else {
            context.read<SellerHomeCubit>().changeDateFilter(type);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: DateFilterType.last7Days,
            child: Text(
              l10n.seller_analytics_filter_last_7_days,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          PopupMenuItem(
            value: DateFilterType.last30Days,
            child: Text(
              l10n.seller_analytics_filter_last_30_days,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          PopupMenuItem(
            value: DateFilterType.custom,
            child: Text(
              l10n.seller_analytics_filter_custom,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14.w,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                filterText,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18.w,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4 — STATS 2×2 GRID
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStatsGrid(BuildContext context, StoreStatsEntity stats) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: l10n.seller_home_stat_active_offers,
                value: StoreStatsEntity.compact(stats.activeOffers),
                icon: Icons.confirmation_number_outlined,
                valueColor: _blue,
                iconColor: _blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                label: l10n.seller_home_stat_used_coupons,
                value: StoreStatsEntity.compact(stats.usedCoupons),
                icon: Icons.discount_outlined,
                valueColor: AppColors.textPrimary,
                iconColor: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: l10n.seller_home_stat_views,
                value: StoreStatsEntity.compact(stats.views),
                icon: Icons.remove_red_eye_outlined,
                valueColor: _blue,
                iconColor: _blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                label: l10n.seller_home_stat_shares,
                value: StoreStatsEntity.compact(stats.shares),
                icon: Icons.people_outline_rounded,
                valueColor: AppColors.textPrimary,
                iconColor: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 5 — QUICK ACTIONS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildQuickActionsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.seller_home_quick_actions_title,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),

        _buildActionButton(
          context,
          label: l10n.seller_home_add_offer_label,
          subtitle: l10n.seller_home_add_offer_subtitle,
          filled: true,
          onTap: () => context.push(AppRouter.sellerManageOffer),
        ),
        SizedBox(height: 8.h),

        _buildActionButton(
          context,
          label: l10n.seller_home_add_product_label,
          subtitle: l10n.seller_home_add_product_subtitle,
          filled: false,
          onTap: () {
            // TODO: navigate to CreateProductPage when built
          },
        ),

        SizedBox(height: 12.h),

        _buildStaffRow(context),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required String subtitle,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final bg = filled ? _blue : Colors.white;
    final textColor = filled ? Colors.white : AppColors.textPrimary;
    final subColor = filled
        ? Colors.white.withValues(alpha: 0.75)
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14.r),
          border: filled ? null : Border.all(color: AppColors.divider),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: _blue.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 11,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: filled
                    ? Colors.white.withValues(alpha: 0.2)
                    : _blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: filled ? Colors.white : _blue,
                size: 18.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // ── First row: QR Scanner + Add Employee ──────────────────────────
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 56.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedPrimaryColor(
                        builder: (context, primaryColor) {
                          return Icon(
                            Icons.qr_code_scanner_rounded,
                            color: primaryColor,
                            size: 24.w,
                          );
                        },
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        l10n.seller_home_scan_qr,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.push(AppRouter.addStaffMember);
                },
                child: Container(
                  height: 56.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedPrimaryColor(
                        builder: (context, primaryColor) {
                          return Icon(
                            Icons.person_add_alt_1_rounded,
                            color: primaryColor,
                            size: 24.w,
                          );
                        },
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        l10n.seller_home_add_employee,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // ── Second row: Employee Management (full width) ──────────────────
        GestureDetector(
          onTap: () {
            context.push(AppRouter.displayStaffDetails);
          },
          child: Container(
            width: double.infinity,
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedPrimaryColor(
                  builder: (context, primaryColor) {
                    return Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        color: primaryColor,
                        size: 22.w,
                      ),
                    );
                  },
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.seller_home_manage_employees_title,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10n.seller_home_manage_employees_subtitle,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 6 — ACTIVE OFFERS SECTION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildActiveOffersSection(
    BuildContext context,
    List<OfferEntity> offers,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // ── Section header ────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.seller_home_active_offers_section,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                final args = <String, dynamic>{
                  'isGuest': false,
                  'isPending': false,
                };
                context.go(AppRouter.sellerOffers, extra: args);
              },
              child: Text(
                l10n.home_see_all,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _blue,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Offer rows ────────────────────────────────────────────────────
        if (offers.isEmpty)
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(
                l10n.seller_home_no_active_offers,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: offers
                  .take(3)
                  .map((offer) => _OfferRow(offer: offer))
                  .toList(),
            ),
          ),
      ],
    );
  }

  // ── Sidebar ────────────────────────────────────────────────────────────────

  void _openSideBar(
    BuildContext context,
    AppLocalizations l10n,
    String userName,
  ) {
    showSellerSideBar(
      context,
      userName: userName,
      userSubtitle: l10n.seller_home_sidebar_active_seller,
      items: [
        SideBarItem(
          icon: Icons.notifications_outlined,
          label: l10n.seller_home_sidebar_notifications,
          onTap: () => context.push(AppRouter.notificationsPage),
        ),
        SideBarItem(
          icon: Icons.settings_outlined,
          label: l10n.settings_page_title,
          onTap: () => context.push(AppRouter.settingsPage),
        ),
        SideBarItem(
          icon: Icons.headset_mic_outlined,
          label: l10n.help_contact_us_title,
          onTap: () => context.push(AppRouter.contactUsPage),
        ),
        SideBarItem(
          icon: Icons.flag_outlined,
          label: l10n.help_report_problem_title,
          onTap: () => context.push(AppRouter.reportProblemPage),
        ),
        SideBarItem(
          icon: Icons.logout_rounded,
          label: l10n.logout,
          isDestructive: true,
          onTap: () => context.read<ProfileCubit>().logout(),
        ),
      ],
    );
  }

  // ── Bottom navigation ──────────────────────────────────────────────────────

  void _handleNavigation(
    BuildContext context,
    int index,
    SellerHomeState state,
  ) {
    // ✅ Derive guest/pending flags from PersonaCubit — the single authority.
    final persona = context.read<PersonaCubit>().state;
    final isGuestVal = persona is GuestPersona || 
                       (persona is SellerPersona && persona.isGuest);
    final isPendingVal = persona is SellerPersona && persona.isPending;

    final args = {'isGuest': isGuestVal, 'isPending': isPendingVal};

    switch (index) {
      case 0:
        context.go(AppRouter.customerProfile);
        break;
      case 1:
        context.go(AppRouter.sellerStore, extra: args);
        break;
      case 2:
        context.go(AppRouter.sellerAnalytics, extra: args);
        break;
      case 3:
        context.go(AppRouter.sellerOffers, extra: args);
        break;
      case 4:
        break; // already here
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Single KPI card used in the 2×2 stats grid.
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color valueColor;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.valueColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(7.r),
                ),
                child: Icon(icon, color: iconColor, size: 15.w),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// A single row in the "Active Offers" list.
class _OfferRow extends StatelessWidget {
  final OfferEntity offer;
  const _OfferRow({required this.offer});

  static const _blue = AppColors.primaryOfSeller;

  Color get _chipColor {
    switch (offer.discountType) {
      case DiscountType.percentage:
        return const Color(0xFFF59E0B);
      case DiscountType.fixedAmount:
        return const Color(0xFF3B82F6);
      case DiscountType.buyGet:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final String chipLabel;
    switch (offer.discountType) {
      case DiscountType.percentage:
        chipLabel = l10n.offer_discount_type_percentage;
        break;
      case DiscountType.fixedAmount:
        chipLabel = l10n.offer_discount_type_fixed;
        break;
      case DiscountType.buyGet:
        chipLabel = l10n.offer_discount_type_buy_get;
        break;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet dot
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(color: _blue, shape: BoxShape.circle),
            ),
          ),
          SizedBox(width: 10.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + chip on same row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        offer.title,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: _chipColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        chipLabel,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _chipColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                // Stats row: views | usage
                Row(
                  children: [
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 13.w,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      StoreStatsEntity.compact(offer.viewCount),
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Icon(
                      Icons.confirmation_number_outlined,
                      size: 13.w,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      l10n.seller_home_offer_usage_count(
                        StoreStatsEntity.compact(offer.usageCount),
                      ),
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
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
}
