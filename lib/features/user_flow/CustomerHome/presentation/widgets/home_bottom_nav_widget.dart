import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME BOTTOM NAV WIDGET
// 5 items: الحساب | فئات | اكسبلور | كوبوناتي | الرئيسية (active by default)
// ─────────────────────────────────────────────────────────────────────────────

class HomeBottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = [
      _NavItem(icon: Icons.person_outline_rounded, label: l10n.nav_account),
      _NavItem(icon: Icons.grid_view_rounded, label: l10n.nav_categories),
      _NavItem(icon: Icons.bar_chart_rounded, label: l10n.nav_explore),
      _NavItem(icon: Icons.local_offer_outlined, label: l10n.nav_coupons),
      _NavItem(icon: Icons.home_rounded, label: l10n.nav_home),
    ];

    return Container(
      height: 62.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.grey200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[i].icon,
                    size: 22.w,
                    color: active ? AppColors.primary : AppColors.textSecondary,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    items[i].label,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 10,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w400,
                      color: active
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
