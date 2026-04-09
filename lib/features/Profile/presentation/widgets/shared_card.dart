import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Reusable profile card widget with unified design system
/// Maintains 100% visual consistency across all profile pages
/// 
/// Supports multiple layouts:
/// - Simple menu item (icon + title + arrow)
/// - Menu with subtitle (icon + title + subtitle + arrow)
/// - Custom content (leading widget + content + trailing widget)
/// - Non-interactive cards (onTap = null)
class SharedProfileCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final bool useFontAwesome;

  const SharedProfileCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
    this.child,
    this.useFontAwesome = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use custom child if provided
    if (child != null) {
      return Container(
        margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
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
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: child,
                  ),
                )
              : Padding(
                  padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: child,
                ),
        ),
      );
    }

    // Default layout
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
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
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12.r),
                child: _buildContent(context),
              )
            : _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // Leading widget or icon
          if (leading != null)
            leading!
          else if (icon != null)
            useFontAwesome
                ? FaIcon(
                    icon,
                    size: 19.w,
                    color: AppColors.primary,
                  )
                : Icon(
                    icon,
                    size: 24.w,
                    color: AppColors.primary,
                  ),
          
          if (leading != null || icon != null) SizedBox(width: 16.w),

          // Title and optional subtitle
          Expanded(
            child: subtitle != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle!,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : Text(
                    title,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),

          // Trailing widget or default arrow
          if (trailing != null)
            trailing!
          else if (onTap != null)
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.w,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}
