import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER BOTTOM NAVIGATION BAR
// ─────────────────────────────────────────────────────────────────────────────

class SellerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SellerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                index: 0,
                icon: FontAwesomeIcons.user,
                activeIcon: FontAwesomeIcons.solidUser,
                label: l10n.account,
                isActive: currentIndex == 0,
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                icon: FontAwesomeIcons.store,
                activeIcon: FontAwesomeIcons.store,
                label: l10n.store,
                isActive: currentIndex == 1,
                onTap: onTap,
              ),
              _NavItem(
                index: 2,
                icon: FontAwesomeIcons.chartColumn,
                activeIcon: FontAwesomeIcons.chartColumn,
                label: l10n.analytics,
                isActive: currentIndex == 2,
                onTap: onTap,
              ),
              _NavItem(
                index: 3,
                icon: FontAwesomeIcons.tag,
                activeIcon: FontAwesomeIcons.tag,
                label: l10n.offers,
                isActive: currentIndex == 3,
                onTap: onTap,
              ),
              _NavItem(
                index: 4,
                icon: FontAwesomeIcons.house,
                activeIcon: FontAwesomeIcons.house,
                label: l10n.home,
                isActive: currentIndex == 4,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV ITEM (StatelessWidget — zero business logic)
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: FaIcon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.primaryOfSeller : Colors.grey.shade400,
                  size: 22.w,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.primaryOfSeller : Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
