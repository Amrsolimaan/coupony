import 'package:coupony/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/offer_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MANAGEABLE OFFER CARD
// STRICTLY SQUARE IMAGE — NO TEXT.
// Two floating circular white buttons at bottom-left (delete + edit).
// ─────────────────────────────────────────────────────────────────────────────

class ManageableOfferCard extends StatelessWidget {
  final OfferEntity offer;
  final VoidCallback onDeleteRequest;
  final VoidCallback onEditRequest;

  const ManageableOfferCard({
    super.key,
    required this.offer,
    required this.onDeleteRequest,
    required this.onEditRequest,
  });

  // Gradient seeds per offer for consistent placeholder colours
  static const List<List<Color>> _gradients = [
    [Color(0xFF215194), Color(0xFF0D3470)],
    [Color(0xFF1565C0), Color(0xFF0D47A1)],
    [Color(0xFF37474F), Color(0xFF1C313A)],
    [Color(0xFF1B5E20), Color(0xFF004D40)],
    [Color(0xFF4A148C), Color(0xFF1A237E)],
    [Color(0xFFBF360C), Color(0xFF7F0000)],
  ];

  List<Color> get _gradient {
    final idx = offer.id.hashCode.abs() % _gradients.length;
    return _gradients[idx];
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Image / placeholder ──────────────────────────────────────────
            _buildImage(),

            // ── Gradient overlay (bottom fade for button visibility) ─────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Delete button (bottom-left) ──────────────────────────────────
            Positioned(
              bottom: 6.h,
              left: 6.w,
              child: _CircleActionButton(
                icon: Icons.delete_outline_rounded,
                iconColor: AppColors.error,
                onTap: onDeleteRequest,
              ),
            ),

            // ── Edit button (bottom-right) ───────────────────────────────────
            Positioned(
              bottom: 6.h,
              right: 6.w,
              child: _CircleActionButton(
                icon: Icons.edit_rounded,
                iconColor: AppColors.primaryOfSeller,
                onTap: onEditRequest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (offer.imageUrl != null) {
      return Image.network(
        offer.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildGradientPlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _buildGradientPlaceholder();
        },
      );
    }
    return _buildGradientPlaceholder();
  }

  Widget _buildGradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE — Circular floating action button
// ─────────────────────────────────────────────────────────────────────────────

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, size: 14.w, color: iconColor),
        ),
      ),
    );
  }
}
