import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/features/auth/domain/entities/user_persona.dart';
import 'package:coupony/features/auth/presentation/cubit/persona_cubit.dart';
import 'package:coupony/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION DETAILS PAGE
// ─────────────────────────────────────────────────────────────────────────────

class NotificationDetailsPage extends StatelessWidget {
  final NotificationEntity notification;

  const NotificationDetailsPage({
    super.key,
    required this.notification,
  });

  // ── Type helpers ───────────────────────────────────────────────────────────

  Color _typeColor(bool isSeller) {
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

  String _formattedDate(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';
    final dt = notification.createdAt;

    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    return isArabic
        ? '$day/$month/$year — $hour:$minute'
        : '$month/$day/$year — $hour:$minute';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // ✅ Read PersonaCubit to determine user role
    final persona = context.watch<PersonaCubit>().state;
    final isSeller = persona is SellerPersona;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(context, l10n),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, l10n, isSeller),
            SizedBox(height: 12.h),
            _buildBodyCard(context, l10n),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        l10n.notifications_details_page_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HEADER CARD — icon, type badge, title, timestamp
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildHeaderCard(BuildContext context, AppLocalizations l10n, bool isSeller) {
    final typeColor = _typeColor(isSeller);
    final primaryColor = isSeller ? AppColors.primaryOfSeller : AppColors.primary;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + badge + timestamp row ──────────────────────────────────
          Row(
            children: [
              // ✅ Image or Icon
              _buildImageOrIcon(typeColor),
              SizedBox(width: 12.w),
              // Type badge + timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Badge (status or type)
                    _buildBadge(context, l10n, typeColor),
                    SizedBox(height: 6.h),
                    // Timestamp
                    Text(
                      _formattedDate(context),
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Read indicator dot (grey if read)
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? AppColors.textDisabled
                      : primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),
          const Divider(color: AppColors.divider, height: 1),
          SizedBox(height: 16.h),

          // ── Title ─────────────────────────────────────────────────────────
          Text(
            notification.title,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BODY CARD — full notification message
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildBodyCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notifications_details_message_label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            notification.body,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════

  // ✅ Build image (for store/order/employee) or icon (for others)
  Widget _buildImageOrIcon(Color typeColor) {
    // Show image for store, order, employee notifications
    if (notification.imageUrl != null && 
        (notification.type == NotificationType.store ||
         notification.type == NotificationType.order ||
         notification.type == NotificationType.employee)) {
      return Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 2),
        ),
        child: ClipOval(
          child: Image.network(
            notification.imageUrl!,
            width: 48.w,
            height: 48.w,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: typeColor.withValues(alpha: 0.1),
              child: Icon(_typeIcon, size: 24.w, color: typeColor),
            ),
          ),
        ),
      );
    }
    
    // Default: show icon
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(_typeIcon, size: 24.w, color: typeColor),
    );
  }

  // ✅ Build badge with status or type
  Widget _buildBadge(BuildContext context, AppLocalizations l10n, Color typeColor) {
    final persona = context.read<PersonaCubit>().state;
    final isSeller = persona is SellerPersona;
    final badgeInfo = _getBadgeInfo(l10n, typeColor, isSeller);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: badgeInfo.$2.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        badgeInfo.$1,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: badgeInfo.$2,
        ),
      ),
    );
  }

  // ✅ Get badge label and color based on status or type
  (String, Color) _getBadgeInfo(AppLocalizations l10n, Color typeColor, bool isSeller) {
    final primaryColor = isSeller ? AppColors.primaryOfSeller : AppColors.primary;
    
    // Priority: badge status first
    switch (notification.badgeStatus) {
      case NotificationBadgeStatus.approved:
        return (l10n.notification_badge_approved, const Color(0xFF4CAF50));
      case NotificationBadgeStatus.rejected:
        return (l10n.notification_badge_rejected, const Color(0xFFF44336));
      case NotificationBadgeStatus.pending:
        return (l10n.notification_badge_pending, const Color(0xFFFF9800));
      case NotificationBadgeStatus.used:
        return (l10n.notification_badge_used, primaryColor);
      case NotificationBadgeStatus.none:
        // Fallback to type label
        return (_typeLabel(l10n), typeColor);
    }
  }
}

