import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/features/auth/domain/entities/user_persona.dart';
import 'package:coupony/features/auth/presentation/cubit/persona_cubit.dart';
import 'package:coupony/features/notifications/domain/entities/notification_entity.dart';
import 'package:coupony/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:coupony/features/notifications/presentation/cubit/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATIONS PAGE
// ─────────────────────────────────────────────────────────────────────────────

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Read PersonaCubit to determine user role
    final persona = context.watch<PersonaCubit>().state;
    final isSeller = persona is SellerPersona;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(context, isSeller),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return _buildLoading(isSeller);
          }
          if (state is NotificationLoaded) {
            return _buildContent(context, state, isSeller);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // APP BAR
  // ══════════════════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isSeller) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        l10n.notifications_page_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is! NotificationLoaded) return const SizedBox.shrink();
            return _buildSortButton(context, l10n, state, isSeller);
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  // ── Sort popup ─────────────────────────────────────────────────────────────

  Widget _buildSortButton(
    BuildContext context,
    AppLocalizations l10n,
    NotificationLoaded state,
    bool isSeller,
  ) {
    final primaryColor = isSeller ? AppColors.primaryOfSeller : AppColors.primary;
    
    return PopupMenuButton<NotificationSortOrder>(
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Colors.white,
      elevation: 4,
      icon: Icon(
        Icons.sort_rounded,
        color: AppColors.textPrimary,
        size: 24.w,
      ),
      onSelected: (order) =>
          context.read<NotificationCubit>().setSortOrder(order),
      itemBuilder: (context) => [
        _sortItem(
          context: context,
          l10n: l10n,
          label: l10n.notifications_sort_newest,
          value: NotificationSortOrder.newest,
          isSelected: state.sortOrder == NotificationSortOrder.newest,
          primaryColor: primaryColor,
        ),
        _sortItem(
          context: context,
          l10n: l10n,
          label: l10n.notifications_sort_oldest,
          value: NotificationSortOrder.oldest,
          isSelected: state.sortOrder == NotificationSortOrder.oldest,
          primaryColor: primaryColor,
        ),
      ],
    );
  }

  PopupMenuItem<NotificationSortOrder> _sortItem({
    required BuildContext context,
    required AppLocalizations l10n,
    required String label,
    required NotificationSortOrder value,
    required bool isSelected,
    required Color primaryColor,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (isSelected) ...[
            Icon(Icons.check_rounded, size: 16.w, color: primaryColor),
            SizedBox(width: 6.w),
          ],
          Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? primaryColor : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOADING
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLoading(bool isSeller) {
    final primaryColor = isSeller ? AppColors.primaryOfSeller : AppColors.primary;
    return Center(
      child: CircularProgressIndicator(
        color: primaryColor,
        strokeWidth: 3,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONTENT
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildContent(BuildContext context, NotificationLoaded state, bool isSeller) {
    final primaryColor = isSeller ? AppColors.primaryOfSeller : AppColors.primary;
    
    return Column(
      children: [
        _buildFilterChips(context, state, isSeller),
        const Divider(height: 1, thickness: 0.5, color: AppColors.divider),
        Expanded(
          child: state.displayedNotifications.isEmpty
              ? _buildEmpty(context)
              : ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: state.displayedNotifications.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.divider,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final item = state.displayedNotifications[index];
                    return _NotificationItem(
                      notification: item,
                      isSeller: isSeller,
                      onTap: () {
                        context.read<NotificationCubit>().markAsRead(item.id);
                        context.push(
                          AppRouter.notificationDetails,
                          extra: item,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips(BuildContext context, NotificationLoaded state, bool isSeller) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = isSeller ? AppColors.primaryOfSeller : AppColors.primary;

    // ✅ Dynamic filters based on user role
    final filters = isSeller ? _getSellerFilters(l10n) : _getCustomerFilters(l10n);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: filters.map((entry) {
            final isSelected = state.activeFilter == entry.$1;
            return Padding(
              padding: EdgeInsetsDirectional.only(end: 8.w),
              child: GestureDetector(
                onTap: () =>
                    context.read<NotificationCubit>().setFilter(entry.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    entry.$2,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
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

  // ✅ Customer filters
  List<(NotificationFilter, String)> _getCustomerFilters(AppLocalizations l10n) {
    return [
      (NotificationFilter.all, l10n.notifications_filter_all),
      (NotificationFilter.offer, l10n.notifications_filter_offer),
      (NotificationFilter.coupon, l10n.notifications_filter_coupon),
      (NotificationFilter.system, l10n.notifications_filter_system),
      (NotificationFilter.general, l10n.notifications_filter_general),
    ];
  }

  // ✅ Seller filters
  List<(NotificationFilter, String)> _getSellerFilters(AppLocalizations l10n) {
    return [
      (NotificationFilter.all, l10n.notifications_filter_all),
      (NotificationFilter.order, l10n.seller_notifications_filter_order),
      (NotificationFilter.store, l10n.seller_notifications_filter_store),
      (NotificationFilter.analytics, l10n.seller_notifications_filter_analytics),
      (NotificationFilter.employee, l10n.seller_notifications_filter_employee),
      (NotificationFilter.system, l10n.notifications_filter_system),
      (NotificationFilter.general, l10n.notifications_filter_general),
    ];
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64.w,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.notifications_empty_title,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.notifications_empty_subtitle,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 13,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION ITEM WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final bool isSeller;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.isSeller,
  });

  // ── Type helpers ───────────────────────────────────────────────────────────

  Color get _typeColor {
    switch (notification.type) {
      // Customer types
      case NotificationType.coupon:
        return AppColors.primary;
      case NotificationType.offer:
        return const Color(0xFF10B981);
      // Seller types
      case NotificationType.order:
        return isSeller ? AppColors.primaryOfSeller : AppColors.primary;
      case NotificationType.store:
        return const Color(0xFF8B5CF6); // Purple
      case NotificationType.analytics:
        return const Color(0xFF0EA5E9); // Sky blue
      case NotificationType.employee:
        return const Color(0xFFF59E0B); // Amber
      // Shared
      case NotificationType.system:
        return AppColors.info;
      case NotificationType.general:
        return AppColors.textSecondary;
    }
  }

  IconData get _typeIcon {
    switch (notification.type) {
      // Customer types
      case NotificationType.coupon:
        return Icons.access_time_rounded;
      case NotificationType.offer:
        return Icons.location_on_outlined;
      // Seller types
      case NotificationType.order:
        return Icons.shopping_bag_outlined;
      case NotificationType.store:
        return Icons.store_outlined;
      case NotificationType.analytics:
        return Icons.bar_chart_rounded;
      case NotificationType.employee:
        return Icons.people_outline_rounded;
      // Shared
      case NotificationType.system:
        return Icons.settings_outlined;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  String _typeLabel(AppLocalizations l10n) {
    switch (notification.type) {
      // Customer types
      case NotificationType.coupon:
        return l10n.notifications_type_coupon;
      case NotificationType.offer:
        return l10n.notifications_type_offer;
      // Seller types
      case NotificationType.order:
        return l10n.seller_notifications_type_order;
      case NotificationType.store:
        return l10n.seller_notifications_type_store;
      case NotificationType.analytics:
        return l10n.seller_notifications_type_analytics;
      case NotificationType.employee:
        return l10n.seller_notifications_type_employee;
      // Shared
      case NotificationType.system:
        return l10n.notifications_type_system;
      case NotificationType.general:
        return l10n.notifications_type_general;
    }
  }

  // ── Time helper — locale-aware, no parametric l10n keys needed ─────────────

  String _timeAgo(BuildContext context) {
    final diff = DateTime.now().difference(notification.createdAt);
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
      if (diff.inDays == 1) return 'منذ يوم';
      if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
      if (diff.inDays < 30) return 'منذ أسبوع';
      return 'منذ شهر';
    } else {
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '1w ago';
      return '1mo ago';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? AppColors.scaffoldBackground
            : Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── START: icon + type badge ──────────────────────────────────
            _buildIconBadgeColumn(context, l10n),
            SizedBox(width: 12.w),

            // ── CENTER: expanded title + body ─────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // ── END: unread dot + time ────────────────────────────────────
            _buildTimeDotColumn(context),
          ],
        ),
      ),
    );
  }

  // ── Icon + badge column ────────────────────────────────────────────────────

  Widget _buildIconBadgeColumn(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    // ✅ Get badge label and color
    final badgeInfo = _getBadgeInfo(l10n);
    
    return SizedBox(
      width: 60.w, // ✅ Fixed width to prevent overflow
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Badge (status or type)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: badgeInfo.$2.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              badgeInfo.$1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: badgeInfo.$2,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          // ✅ Image or Icon
          _buildImageOrIcon(),
        ],
      ),
    );
  }

  // ✅ Build image (for store/order/employee) or icon (for others)
  Widget _buildImageOrIcon() {
    // Show image for store, order, employee notifications
    if (notification.imageUrl != null && 
        (notification.type == NotificationType.store ||
         notification.type == NotificationType.order ||
         notification.type == NotificationType.employee)) {
      return Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _typeColor.withValues(alpha: 0.3), width: 1.5),
        ),
        child: ClipOval(
          child: Image.network(
            notification.imageUrl!,
            width: 36.w,
            height: 36.w,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: _typeColor.withValues(alpha: 0.08),
              child: Icon(_typeIcon, size: 18.w, color: _typeColor),
            ),
          ),
        ),
      );
    }
    
    // Default: show icon
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: _typeColor.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(_typeIcon, size: 18.w, color: _typeColor),
    );
  }

  // ✅ Get badge label and color based on status or type
  (String, Color) _getBadgeInfo(AppLocalizations l10n) {
    // Priority: badge status first
    switch (notification.badgeStatus) {
      case NotificationBadgeStatus.approved:
        return (l10n.notification_badge_approved, const Color(0xFF4CAF50));
      case NotificationBadgeStatus.rejected:
        return (l10n.notification_badge_rejected, const Color(0xFFF44336));
      case NotificationBadgeStatus.pending:
        return (l10n.notification_badge_pending, const Color(0xFFFF9800));
      case NotificationBadgeStatus.used:
        return (l10n.notification_badge_used, isSeller ? AppColors.primaryOfSeller : AppColors.primary);
      case NotificationBadgeStatus.none:
        // Fallback to type label
        return (_typeLabel(l10n), _typeColor);
    }
  }

  // ── Time + unread dot column ───────────────────────────────────────────────

  Widget _buildTimeDotColumn(BuildContext context) {
    final primaryColor = isSeller ? AppColors.primaryOfSeller : AppColors.primary;
    
    return SizedBox(
      width: 50.w, // ✅ Fixed width to prevent overflow
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!notification.isRead) ...[
            Container(
              width: 9.w,
              height: 9.w,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 6.h),
          ],
          Text(
            _timeAgo(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
