import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Empty Address Widget
/// Displayed when user has no saved addresses
class EmptyAddressWidget extends StatelessWidget {
  const EmptyAddressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Title ──────────────────────────────────────────────────────
            Text(
              l10n.address_empty_title,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // ── Subtitle ───────────────────────────────────────────────────
            Text(
              l10n.address_empty_subtitle,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            SizedBox(height: 32.h),

            // ── Empty Location Image ───────────────────────────────────────
            Image.asset(
              'assets/images/EmtyLocation.jpg',
              width: 400.w,
              height: 400.w,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
