import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME HEADER WIDGET
// Orange gradient area with convex bottom curve (ClipPath).
// Includes search bar inside the orange area.
// ─────────────────────────────────────────────────────────────────────────────

class HomeHeaderWidget extends StatelessWidget {
  final String userName;
  final String userLocation;
  final VoidCallback? onBellTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onMicTap;

  const HomeHeaderWidget({
    super.key,
    required this.userName,
    required this.userLocation,
    this.onBellTap,
    this.onLocationTap,
    this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BottomCurveClipper(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B1A), Color(0xFFFF5500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
            child: Column(
              children: [
                _buildTopRow(context),
                SizedBox(height: 16.h),
                _buildLocationRow(context),
                SizedBox(height: 16.h),
                _buildSearchBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Top row ───────────────────────────────────────────────────────────────

  Widget _buildTopRow(BuildContext context) {
    final initial = userName.isNotEmpty
        ? userName.characters.first.toUpperCase()
        : 'م';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── physical RIGHT ── Avatar + Name ─────────────────────────────────
        Row(
          children: [
            Skeleton.replace(
              width: 46.w,
              height: 46.w,
              replacement: Container(
                width: 46.w,
                height: 46.w,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
              ),
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.25),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.60),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Skeleton.unite(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.home_greeting,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    userName,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── physical LEFT ── Bell ───────────────────────────────────────────
        Skeleton.replace(
          width: 46.w,
          height: 46.w,
          replacement: Container(
            width: 46.w,
            height: 46.w,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
          ),
          child: GestureDetector(
            onTap: onBellTap,
            child: Container(
              width: 46.w,
              height: 46.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: const Color(0xFFFF6B1A),
                size: 24.w,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Location row ──────────────────────────────────────────────────────────

  Widget _buildLocationRow(BuildContext context) {
    return Skeleton.unite(
      child: GestureDetector(
        onTap: onLocationTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Location icon
              Icon(
                Icons.location_on,
                color: Colors.white,
                size: 22.w,
              ),

              // Center: Delivery text
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    'Delivery to: $userLocation',
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Right side: Forward arrow
              Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 24.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    return Skeleton.leaf(
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),

            // Search icon (LEFT side)
            Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 24.w,
            ),

            SizedBox(width: 12.w),

            // Hint text
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.home_search_hint,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                textAlign: TextAlign.right,
              ),
            ),

            SizedBox(width: 12.w),

            // Mic button (RIGHT side)
            GestureDetector(
              onTap: onMicTap,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.mic_rounded,
                  color: AppColors.primary,
                  size: 22.w,
                ),
              ),
            ),

            SizedBox(width: 16.w),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM CURVE CLIPPER — subtle rounded corners at edges
// ─────────────────────────────────────────────────────────────────────────────

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 40.0;
    
    // Start from top-left
    path.lineTo(0, size.height - radius);
    
    // Bottom-left rounded corner
    path.quadraticBezierTo(
      0,
      size.height,
      radius,
      size.height,
    );
    
    // Straight line across the bottom
    path.lineTo(size.width - radius, size.height);
    
    // Bottom-right rounded corner
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - radius,
    );
    
    // Right side up
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BottomCurveClipper old) => false;
}
