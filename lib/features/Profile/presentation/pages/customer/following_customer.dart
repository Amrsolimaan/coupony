import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DOMAIN-LAYER STUB  (Clean Architecture boundary – replace with real entity)
// When backend is ready, move this to:
//   features/Profile/domain/entities/followed_store_entity.dart
// ─────────────────────────────────────────────────────────────────────────────

class FollowedStoreEntity {
  final String id;
  final String name;
  final String category;
  final String logoUrl;
  final double rating;
  final int followersCount;

  const FollowedStoreEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.logoUrl,
    required this.rating,
    required this.followersCount,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA  (Replace the list with a real UseCase / Cubit call later)
// ─────────────────────────────────────────────────────────────────────────────

const List<FollowedStoreEntity> _kMockStores = [
  FollowedStoreEntity(
    id: '1',
    name: 'Zara',
    category: 'Fashion',
    logoUrl: 'https://logo.clearbit.com/zara.com',
    rating: 4.7,
    followersCount: 12400,
  ),
  FollowedStoreEntity(
    id: '2',
    name: 'Noon',
    category: 'Electronics',
    logoUrl: 'https://logo.clearbit.com/noon.com',
    rating: 4.5,
    followersCount: 58700,
  ),
  FollowedStoreEntity(
    id: '3',
    name: 'H&M',
    category: 'Fashion',
    logoUrl: 'https://logo.clearbit.com/hm.com',
    rating: 4.3,
    followersCount: 9800,
  ),
  FollowedStoreEntity(
    id: '4',
    name: 'Carrefour',
    category: 'Supermarket',
    logoUrl: 'https://logo.clearbit.com/carrefour.com.eg',
    rating: 4.1,
    followersCount: 34200,
  ),
  FollowedStoreEntity(
    id: '5',
    name: 'Jumia',
    category: 'E-commerce',
    logoUrl: 'https://logo.clearbit.com/jumia.com.eg',
    rating: 4.0,
    followersCount: 72100,
  ),
  FollowedStoreEntity(
    id: '6',
    name: 'Adidas',
    category: 'Sports',
    logoUrl: 'https://logo.clearbit.com/adidas.com',
    rating: 4.6,
    followersCount: 21300,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────

class FollowingCustomerPage extends HookWidget {
  const FollowingCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ── Local state (HookWidget — no StatefulWidget needed) ────────────────
    final searchController = useTextEditingController();
    final searchQuery = useValueNotifier<String>('');
    final followedIds = useValueNotifier<Set<String>>(
      _kMockStores.map((s) => s.id).toSet(),
    );

    useEffect(() {
      void listener() =>
          searchQuery.value = searchController.text.trim().toLowerCase();
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _AppBar(l10n: l10n),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──────────────────────────────────────────────────
            _SearchBar(controller: searchController, l10n: l10n),

            // ── Store List ──────────────────────────────────────────────────
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: searchQuery,
                builder: (context, query, _) {
                  return ValueListenableBuilder<Set<String>>(
                    valueListenable: followedIds,
                    builder: (context, followed, _) {
                      final visible = _kMockStores
                          .where((s) => followed.contains(s.id))
                          .where(
                            (s) =>
                                query.isEmpty ||
                                s.name.toLowerCase().contains(query) ||
                                s.category.toLowerCase().contains(query),
                          )
                          .toList();

                      if (followed.isEmpty) {
                        return _EmptyState(l10n: l10n, showSearchEmpty: false);
                      }

                      if (visible.isEmpty) {
                        return _EmptyState(l10n: l10n, showSearchEmpty: true);
                      }

                      return ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        itemCount: visible.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          return _StoreCard(
                            store: visible[index],
                            l10n: l10n,
                            onUnfollowConfirmed: () {
                              followedIds.value = Set.from(followedIds.value)
                                ..remove(visible[index].id);
                            },
                            // TODO: When backend is ready, pass a real store ID
                            // and navigate:  context.push(AppRouter.shopDisplay, extra: store.id);
                            onTap: () {},
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// ── AppBar ─────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  const _AppBar({required this.l10n});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          size: 20.w,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        l10n.following_page_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l10n;
  const _SearchBar({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: TextField(
        controller: controller,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: l10n.following_page_search_hint,
          hintStyle: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 22.w,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18.w,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: controller.clear,
                  ),
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: AppColors.divider, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Store Card ──────────────────────────────────────────────────────────────

class _StoreCard extends StatelessWidget {
  final FollowedStoreEntity store;
  final AppLocalizations l10n;
  final VoidCallback onUnfollowConfirmed;
  final VoidCallback onTap;

  const _StoreCard({
    required this.store,
    required this.l10n,
    required this.onUnfollowConfirmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      child: InkWell(
        onTap: onTap, // TODO: Navigate to shop page when backend ready
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Logo ─────────────────────────────────────────────────────
              _StoreLogo(logoUrl: store.logoUrl, name: store.name),

              SizedBox(width: 14.w),

              // ── Info ──────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      store.category,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _RatingFollowers(store: store),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              // ── Unfollow Button ───────────────────────────────────────────
              _UnfollowButton(
                l10n: l10n,
                onPressed: () => _confirmUnfollow(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmUnfollow(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.following_page_unfollow_confirm_title,
          style: AppTextStyles.customStyle(
            ctx,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          l10n.following_page_unfollow_confirm_body,
          style: AppTextStyles.customStyle(
            ctx,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.following_page_unfollow_confirm_cancel,
              style: AppTextStyles.customStyle(
                ctx,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.following_page_unfollow_confirm_ok,
              style: AppTextStyles.customStyle(
                ctx,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onUnfollowConfirmed();
    }
  }
}

// ── Store Logo ──────────────────────────────────────────────────────────────

class _StoreLogo extends StatelessWidget {
  final String logoUrl;
  final String name;
  const _StoreLogo({required this.logoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        border: Border.all(color: AppColors.divider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          logoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Rating + Followers Row ──────────────────────────────────────────────────

class _RatingFollowers extends StatelessWidget {
  final FollowedStoreEntity store;
  const _RatingFollowers({required this.store});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star_rounded, size: 14.w, color: const Color(0xFFF59E0B)),
        SizedBox(width: 3.w),
        Text(
          store.rating.toStringAsFixed(1),
          style: AppTextStyles.customStyle(
            context,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 8.w),
        Icon(
          Icons.people_alt_outlined,
          size: 14.w,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 3.w),
        Text(
          _formatCount(store.followersCount),
          style: AppTextStyles.customStyle(
            context,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

// ── Unfollow Button ─────────────────────────────────────────────────────────

class _UnfollowButton extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onPressed;
  const _UnfollowButton({required this.l10n, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        alignment: Alignment.center,
        child: Text(
          l10n.following_page_unfollow_btn,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final bool showSearchEmpty;
  const _EmptyState({required this.l10n, required this.showSearchEmpty});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                showSearchEmpty
                    ? Icons.search_off_rounded
                    : Icons.storefront_outlined,
                size: 44.w,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              showSearchEmpty
                  ? l10n.following_page_no_results
                  : l10n.following_page_empty_title,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!showSearchEmpty) ...[
              SizedBox(height: 10.h),
              Text(
                l10n.following_page_empty_subtitle,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
