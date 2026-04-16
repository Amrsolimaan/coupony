import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/saved_address.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../auth/presentation/widgets/role_animation_wrapper.dart';

/// Address Card Widget
/// Displays a saved address with actions
class AddressCardWidget extends StatelessWidget {
  final SavedAddress address;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const AddressCardWidget({
    super.key,
    required this.address,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedPrimaryColor(
      builder: (context, primaryColor) {
        return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: address.isDefault
            ? Border.all(
                color: primaryColor.withValues(alpha: 0.3),
                width: 1.5.w,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icon ───────────────────────────────────────────────────
                AnimatedPrimaryColor(
                  builder: (context, primaryColor) {
                    return Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: FaIcon(
                        _getIconForLabel(address.label),
                        color: primaryColor,
                        size: 18.w,
                      ),
                    );
                  },
                ),
                SizedBox(width: 12.w),

                // ── Address Info ───────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Label with Default Badge ───────────────────────────
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.label,
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (address.isDefault) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                l10n.address_default_badge,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 6.h),

                      // ── Address Text ───────────────────────────────────────
                      Text(
                        address.address,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // ── More Menu (hidden when all callbacks are null — read-only card) ──
                if (onEdit != null || onDelete != null || onSetDefault != null)
                  PopupMenuButton<String>(
                    icon: FaIcon(
                      FontAwesomeIcons.ellipsisVertical,
                      color: AppColors.textSecondary,
                      size: 18.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'set_default':
                          onSetDefault?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      // ── Edit ─────────────────────────────────────────────
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.penToSquare,
                                size: 16.w,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                l10n.address_edit,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Set as Default ───────────────────────────────────
                      if (onSetDefault != null && !address.isDefault)
                        PopupMenuItem(
                          value: 'set_default',
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.circleCheck,
                                size: 16.w,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                l10n.address_set_default,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Delete ───────────────────────────────────────────
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.trashCan,
                                size: 16.w,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                l10n.address_delete,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 14,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      );
      },
    );
  }

  IconData _getIconForLabel(String label) {
    final lowerLabel = label.toLowerCase();
    
    if (lowerLabel.contains('home') || 
        lowerLabel.contains('منزل') || 
        lowerLabel.contains('بيت')) {
      return FontAwesomeIcons.house;
    } else if (lowerLabel.contains('work') || 
               lowerLabel.contains('عمل') || 
               lowerLabel.contains('شغل')) {
      return FontAwesomeIcons.briefcase;
    } else {
      return FontAwesomeIcons.locationDot;
    }
  }
}
