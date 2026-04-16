import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/entities/home_category_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME CATEGORIES WIDGET
// Section title + horizontal scroll of category pills.
// Each item: icon inside an orange-bordered circle + label below.
// ─────────────────────────────────────────────────────────────────────────────

class HomeCategoriesWidget extends StatelessWidget {
  final List<HomeCategoryEntity> categories;
  final ValueChanged<HomeCategoryEntity>? onCategoryTap;

  const HomeCategoriesWidget({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              AppLocalizations.of(context)!.home_categories_title,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Horizontal list
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              itemCount: categories.length,
              itemBuilder: (_, i) => _CategoryItem(
                category: categories[i],
                onTap: () => onCategoryTap?.call(categories[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final HomeCategoryEntity category;
  final VoidCallback onTap;

  const _CategoryItem({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Skeleton.unite(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64.w,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon circle
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  category.icon,
                  color: AppColors.primary,
                  size: 22.w,
                ),
              ),
              SizedBox(height: 6.h),

              // Label
              Text(
                category.label,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
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
