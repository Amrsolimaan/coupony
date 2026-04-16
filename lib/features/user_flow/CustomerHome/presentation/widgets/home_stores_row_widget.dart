import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME STORES ROW
// Horizontal scrollable row of circular store avatars with names.
// ─────────────────────────────────────────────────────────────────────────────

class HomeStoresRowWidget extends StatelessWidget {
  final List<StoreItem> stores;
  final ValueChanged<StoreItem>? onStoreTap;

  const HomeStoresRowWidget({
    super.key,
    required this.stores,
    this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Text(
            AppLocalizations.of(context)!.home_stores_title,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // Stores list
        SizedBox(
          height: 95.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: stores.length,
            itemBuilder: (_, i) => _StoreCircleItem(
              store: stores[i],
              onTap: () => onStoreTap?.call(stores[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORE CIRCLE ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _StoreCircleItem extends StatelessWidget {
  final StoreItem store;
  final VoidCallback? onTap;

  const _StoreCircleItem({required this.store, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 80.w,
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            children: [
              // Circle avatar
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: store.imageUrl != null
                      ? Image.network(
                          store.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),

              SizedBox(height: 4.h),

              // Store name
              Text(
                store.name,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Icon(
        Icons.store_outlined,
        color: Colors.grey.shade500,
        size: 30,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORE ITEM MODEL
// ─────────────────────────────────────────────────────────────────────────────

class StoreItem {
  final String id;
  final String name;
  final String? imageUrl;

  const StoreItem({
    required this.id,
    required this.name,
    this.imageUrl,
  });
}
