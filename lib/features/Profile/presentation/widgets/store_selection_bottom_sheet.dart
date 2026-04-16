import 'package:coupony/config/dependency_injection/injection_container.dart' as di;
import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/images/app_cached_image.dart';
import 'package:coupony/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:coupony/features/auth/data/models/user_store_model.dart';
import 'package:coupony/features/auth/presentation/cubit/persona_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STORE SELECTION BOTTOM SHEET
// 
// Modern bottom sheet for selecting a store from user's stores list.
// Shows all stores (active, pending, rejected) with appropriate badges.
// Only active stores are selectable.
// ─────────────────────────────────────────────────────────────────────────────

class StoreSelectionBottomSheet extends StatefulWidget {
  final List<UserStoreModel> stores;

  const StoreSelectionBottomSheet({
    super.key,
    required this.stores,
  });

  /// Show the bottom sheet
  static Future<void> show({
    required BuildContext context,
    required List<UserStoreModel> stores,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoreSelectionBottomSheet(stores: stores),
    );
  }

  @override
  State<StoreSelectionBottomSheet> createState() =>
      _StoreSelectionBottomSheetState();
}

class _StoreSelectionBottomSheetState
    extends State<StoreSelectionBottomSheet> {
  static const _navy = AppColors.primaryOfSeller;
  String? _selectingId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle ────────────────────────────────────────────────
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // ── Header ─────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: _navy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.store,
                          size: 18.w,
                          color: _navy,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.store_selection_sheet_title,
                            style: AppTextStyles.customStyle(
                              context,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            l10n.store_selection_sheet_subtitle,
                            style: AppTextStyles.customStyle(
                              context,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(color: AppColors.divider, height: 1),

          // ── Stores List ────────────────────────────────────────────────
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: widget.stores.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final store = widget.stores[index];
                return _StoreCard(
                  store: store,
                  isSelecting: _selectingId == store.id,
                  isDisabled: _selectingId != null && _selectingId != store.id,
                  onTap: () => _handleStoreTap(store),
                  l10n: l10n,
                  isArabic: isArabic,
                );
              },
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // ── Handle Store Tap ───────────────────────────────────────────────────────
  Future<void> _handleStoreTap(UserStoreModel store) async {
    if (_selectingId != null) return;

    // Check if store is active
    if (!store.isActive) {
      final l10n = AppLocalizations.of(context)!;
      final message = store.isPending
          ? l10n.store_not_active_pending_message
          : l10n.store_not_active_rejected_message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    // Store is active - proceed with selection
    setState(() => _selectingId = store.id);

    try {
      // Save selected store ID
      await di.sl<AuthLocalDataSource>().saveSelectedStoreId(store.id);

      // Switch persona FIRST and await it — the router guard reads
      // sl<PersonaCubit>().state synchronously, so the state must be
      // SellerPersona before push() triggers the redirect.
      // Use sl directly to avoid BuildContext-across-async-gap warning.
      await di.sl<PersonaCubit>().switchPersona();

      if (!mounted) return;

      // Capture the router reference BEFORE popping — context becomes
      // invalid after Navigator.pop() and cannot be used for push().
      final router = GoRouter.of(context);

      // Close bottom sheet
      Navigator.of(context).pop();

      // Navigate using the captured router (not the disposed context)
      router.push(
        AppRouter.sellerStore,
        extra: {'isGuest': false, 'isPending': false},
      );
    } catch (e) {
      if (mounted) {
        setState(() => _selectingId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _StoreCard extends StatelessWidget {
  final UserStoreModel store;
  final bool isSelecting;
  final bool isDisabled;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final bool isArabic;

  const _StoreCard({
    required this.store,
    required this.isSelecting,
    required this.isDisabled,
    required this.onTap,
    required this.l10n,
    required this.isArabic,
  });

  static const _navy = AppColors.primaryOfSeller;

  @override
  Widget build(BuildContext context) {
    final isActive = store.isActive;
    final isPending = store.isPending;
    final isRejected = store.isRejected;

    return AnimatedOpacity(
      opacity: isDisabled ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(16.r),
          splashColor: _navy.withValues(alpha: 0.05),
          highlightColor: _navy.withValues(alpha: 0.03),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelecting
                    ? _navy
                    : isActive
                        ? const Color(0xFFE8EDF5)
                        : AppColors.divider,
                width: isSelecting ? 1.5 : 1.0,
              ),
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
                // ── Logo ─────────────────────────────────────────────────
                _StoreLogo(
                  logoUrl: store.logoUrl,
                  name: store.name,
                  isActive: isActive,
                ),
                SizedBox(width: 14.w),

                // ── Name + Badge ─────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name.isEmpty ? '—' : store.name,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      _StatusBadge(
                        isActive: isActive,
                        isPending: isPending,
                        isRejected: isRejected,
                        l10n: l10n,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // ── Trailing Icon ────────────────────────────────────────
                if (isSelecting)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _navy,
                    ),
                  )
                else if (isActive)
                  FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 14.w,
                    color: const Color(0xFFC5CEDE),
                  )
                else
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 18.w,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORE LOGO
// ─────────────────────────────────────────────────────────────────────────────

class _StoreLogo extends StatelessWidget {
  final String? logoUrl;
  final String name;
  final bool isActive;

  const _StoreLogo({
    required this.logoUrl,
    required this.name,
    required this.isActive,
  });

  static const _navy = AppColors.primaryOfSeller;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;

    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFEEF2F9)
            : AppColors.divider.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isActive ? const Color(0xFFDCE4F0) : AppColors.divider,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLogo
          ? AppCachedImage(
              imageUrl: logoUrl!,
              width: 52.w,
              height: 52.w,
              borderRadius: BorderRadius.zero,
              backgroundColor: const Color(0xFFEEF2F9),
              errorWidget: _Initial(letter: initial, isActive: isActive),
              placeholder: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: _navy,
                ),
              ),
            )
          : _Initial(letter: initial, isActive: isActive),
    );
  }
}

class _Initial extends StatelessWidget {
  final String letter;
  final bool isActive;

  const _Initial({
    required this.letter,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        letter,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isActive
              ? AppColors.primaryOfSeller
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final bool isPending;
  final bool isRejected;
  final AppLocalizations l10n;

  const _StatusBadge({
    required this.isActive,
    required this.isPending,
    required this.isRejected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Color dotColor;
    final String label;

    if (isActive) {
      bgColor = const Color(0xFFEDFBF3);
      textColor = const Color(0xFF15803D);
      dotColor = const Color(0xFF16A34A);
      label = l10n.store_status_active;
    } else if (isPending) {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
      dotColor = const Color(0xFFF59E0B);
      label = l10n.store_status_pending;
    } else {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
      dotColor = const Color(0xFFEF4444);
      label = l10n.store_status_rejected;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
