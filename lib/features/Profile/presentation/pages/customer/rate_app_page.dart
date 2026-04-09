import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RATE APP PAGE
// ─────────────────────────────────────────────────────────────────────────────

class RateAppPage extends StatefulWidget {
  const RateAppPage({super.key});

  @override
  State<RateAppPage> createState() => _RateAppPageState();
}

class _RateAppPageState extends State<RateAppPage> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context, l10n),
      body: SafeArea(bottom: true, child: _buildBody(context, l10n)),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        l10n.help_rate_app_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 20.w,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            SizedBox(height: 32.h),

            // ── Rating Icon ──────────────────────────────────────────────────
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_rounded,
                size: 40.w,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),

            // ── Title ────────────────────────────────────────────────────────
            Text(
              l10n.rate_app_heading,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.rate_app_subtitle,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // ── Star Rating ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starIndex),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Icon(
                      starIndex <= _selectedRating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 40.w,
                      color: starIndex <= _selectedRating
                          ? AppColors.warning
                          : AppColors.textDisabled,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 32.h),

            // ── Comment Field ────────────────────────────────────────────────
            TextField(
              controller: _commentController,
              maxLines: 4,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: l10n.rate_app_comment_hint,
                hintStyle: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDisabled,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide:
                      BorderSide(color: AppColors.divider, width: 1.5.w),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide:
                      BorderSide(color: AppColors.divider, width: 1.5.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide:
                      BorderSide(color: AppColors.primary, width: 1.5.w),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // ── Submit Button ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleSubmit(context, l10n),
                  borderRadius: BorderRadius.circular(14.r),
                  child: Center(
                    child: Text(
                      l10n.rate_app_submit,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ── Handle Submit ──────────────────────────────────────────────────────────
  void _handleSubmit(BuildContext context, AppLocalizations l10n) {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.rate_app_select_rating,
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
      return;
    }

    // TODO: Send rating to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.rate_app_success,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
    context.pop();
  }
}
