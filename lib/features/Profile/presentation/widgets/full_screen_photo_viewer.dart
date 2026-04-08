import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FULL SCREEN PHOTO VIEWER WITH HERO ANIMATION
// ─────────────────────────────────────────────────────────────────────────────

class FullScreenPhotoViewer extends StatelessWidget {
  final String? imageUrl;
  final File? localImage;
  final String heroTag;

  const FullScreenPhotoViewer({
    super.key,
    this.imageUrl,
    this.localImage,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Photo with Hero Animation ──────────────────────────────────────
          Center(
            child: Hero(
              tag: heroTag,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 1.sw,
                      maxHeight: 1.sh,
                    ),
                    child: _buildImage(),
                  ),
                ),
              ),
            ),
          ),

          // ── Close Button ───────────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: _buildCloseButton(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (localImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.file(
          localImage!,
          fit: BoxFit.contain,
        ),
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.contain,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3.w,
            ),
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.error_outline_rounded,
            size: 64.w,
            color: Colors.white,
          ),
        ),
      );
    }

    return Icon(
      Icons.person_rounded,
      size: 120.w,
      color: Colors.white.withValues(alpha: 0.5),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.close_rounded,
          size: 24.w,
          color: Colors.white,
        ),
      ),
    );
  }
}
