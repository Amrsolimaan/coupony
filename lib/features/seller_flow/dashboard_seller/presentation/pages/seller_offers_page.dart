import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/custom_bottom_nav_bar/seller_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../../config/routes/app_router.dart';
import '../../../../auth/domain/entities/user_persona.dart';
import '../../../../auth/presentation/cubit/persona_cubit.dart';
import '../../domain/entities/offer_entity.dart';
import '../cubit/seller_offers_cubit.dart';
import '../cubit/seller_offers_state.dart';
import '../widgets/guest_seller_view.dart';
import '../widgets/pending_approval_view_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER OFFERS PAGE
// ─────────────────────────────────────────────────────────────────────────────

class SellerOffersPage extends StatelessWidget {
  const SellerOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerOffersCubit, SellerOffersState>(
      listener: (context, state) {
        if (state is SellerOffersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
          );
        }
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;

        // ✅ Check PersonaCubit for guest/pending status
        final persona = context.watch<PersonaCubit>().state;
        final isGuest = persona is GuestPersona || 
                        (persona is SellerPersona && persona.isGuest);
        final isPending = persona is SellerPersona && persona.isPending;

        // ── Guest / Pending — return early with minimal scaffold ───────────────
        if (isGuest) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: const GuestSellerViewWidget(icon: FontAwesomeIcons.tags),
            bottomNavigationBar: SellerBottomNavBar(
              currentIndex: 3,
              onTap: (i) => _handleNavigation(context, i, state),
            ),
          );
        }
        if (isPending) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: PendingApprovalViewWidget(
              icon: FontAwesomeIcons.tags,
              onContactUs: () {},
            ),
            bottomNavigationBar: SellerBottomNavBar(
              currentIndex: 3,
              onTap: (i) => _handleNavigation(context, i, state),
            ),
          );
        }

        // ── Main scaffold ──────────────────────────────────────────────────────
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(context, l10n),
          body: Column(
            children: [
              if (state is SellerOffersDataLoaded)
                _buildTabBar(context, l10n, state),
              Expanded(child: _buildBody(context, l10n, state)),
              _buildAddOfferButton(context, l10n),
            ],
          ),
          bottomNavigationBar: SellerBottomNavBar(
            currentIndex: 3,
            onTap: (i) => _handleNavigation(context, i, state),
          ),
        );
      },
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      surfaceTintColor: AppColors.primaryOfSeller,
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        l10n.seller_offers_page_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryOfSeller,
        ),
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar(BuildContext context, AppLocalizations l10n, SellerOffersDataLoaded state) {
    final tabs = [
      l10n.seller_offers_tab_all,
      l10n.seller_offers_tab_active,
      l10n.seller_offers_tab_expired,
      l10n.seller_offers_tab_scheduled,
    ];

    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: 7.w),
        itemBuilder: (context, i) {
          final active = state.activeTabIndex == i;
          return GestureDetector(
            onTap: () => context.read<SellerOffersCubit>().changeTab(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: active ? AppColors.primaryOfSeller : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: active
                      ? AppColors.primaryOfSeller
                      : AppColors.textSecondary.withValues(alpha: 0.25),
                ),
              ),
              child: Center(
                child: Text(
                  tabs[i],
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: active ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Body dispatcher ────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, AppLocalizations l10n, SellerOffersState state) {
    if (state is SellerOffersLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryOfSeller,
          strokeWidth: 3.w,
        ),
      );
    }
    if (state is SellerOffersError) {
      return _buildErrorState(context, l10n, state);
    }
    if (state is SellerOffersDataLoaded) {
      return _buildList(context, l10n, state);
    }
    // Initial / fallback
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryOfSeller,
        strokeWidth: 3.w,
      ),
    );
  }

  // ── Offers list ────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context, AppLocalizations l10n, SellerOffersDataLoaded state) {
    final items = state.filteredOffers;
    if (items.isEmpty) {
      return _buildEmpty(context, l10n, state.activeTabIndex);
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final offer = items[index];
        return _OfferListCard(
          offer: offer,
          onDetails: () =>
              context.push(AppRouter.sellerOfferDetails, extra: offer),
          onDelete: () => _showDeleteDialog(context, l10n, offer),
        );
      },
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n, int tabIndex) {
    final emptyLabels = [
      l10n.seller_offers_empty_all,
      l10n.seller_offers_empty_active,
      l10n.seller_offers_empty_expired,
      l10n.seller_offers_empty_scheduled,
    ];
    final label = emptyLabels[tabIndex.clamp(0, 3)];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.tags,
            size: 48.w,
            color: AppColors.textSecondary.withValues(alpha: 0.35),
          ),
          SizedBox(height: 16.h),
          Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n, SellerOffersError state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64.w, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              state.message,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<SellerOffersCubit>().loadOffers(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOfSeller,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text(
                l10n.retry,
                style: AppTextStyles.customStyle(
                    context, fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sticky "Add offer" button ──────────────────────────────────────────────

  Widget _buildAddOfferButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => context.push(AppRouter.sellerManageOffer),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOfSeller,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            elevation: 0,
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            l10n.seller_offers_add_new,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete confirmation dialog ─────────────────────────────────────────────

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n, OfferEntity offer) {
    final cubit = context.read<SellerOffersCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        contentPadding:
            EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
        actionsPadding: EdgeInsets.all(16.w),
        title: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20.w,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              l10n.seller_offer_delete_title,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Text(
            l10n.seller_offer_delete_message,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Text(
                    l10n.offer_delete_cancel,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    cubit.deleteOffer(offer.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.offer_delete_confirm_button,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom-nav handler ─────────────────────────────────────────────────────

  void _handleNavigation(
      BuildContext context, int index, SellerOffersState state) {
    // ✅ Get guest/pending status from PersonaCubit instead of state
    final persona = context.read<PersonaCubit>().state;
    final isGuest = persona is GuestPersona || 
                    (persona is SellerPersona && persona.isGuest);
    final isPending = persona is SellerPersona && persona.isPending;

    final args = {'isGuest': isGuest, 'isPending': isPending};

    switch (index) {
      case 0:
        context.go(AppRouter.customerProfile);
        break;
      case 1:
        context.go(AppRouter.sellerStore, extra: args);
        break;
      case 2:
        context.go(AppRouter.sellerAnalytics, extra: args);
        break;
      case 3:
        break;
      case 4:
        context.go(AppRouter.sellerHome, extra: args);
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OFFER LIST CARD  (private to this file)
// ─────────────────────────────────────────────────────────────────────────────

class _OfferListCard extends StatelessWidget {
  final OfferEntity offer;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  const _OfferListCard({
    required this.offer,
    required this.onDetails,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (offer.offerStatus) {
      case OfferStatus.active:
        return const Color(0xFF10B981);
      case OfferStatus.expired:
        return AppColors.error;
      case OfferStatus.scheduled:
        return const Color(0xFFF59E0B);
    }
  }

  Color get _chipColor {
    switch (offer.discountType) {
      case DiscountType.percentage:
        return AppColors.primaryOfSeller;
      case DiscountType.fixedAmount:
        return const Color(0xFF059669);
      case DiscountType.buyGet:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final statusLabel = switch (offer.offerStatus) {
      OfferStatus.active => l10n.seller_offer_status_active,
      OfferStatus.expired => l10n.seller_offer_status_expired,
      OfferStatus.scheduled => l10n.seller_offer_status_scheduled,
    };

    final chipLabel = switch (offer.discountType) {
      DiscountType.percentage => l10n.seller_offer_chip_percentage,
      DiscountType.fixedAmount => l10n.offer_discount_type_fixed,
      DiscountType.buyGet => l10n.offer_discount_type_buy_get,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail (start of Row = leading edge) ──────────────────────
          ClipRRect(
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(12.r),
              bottomStart: Radius.circular(12.r),
            ),
            child: _buildImage(),
          ),

          // ── Text content ─────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + status badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          offer.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5.w,
                              height: 5.w,
                              decoration: BoxDecoration(
                                color: _statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              statusLabel,
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Discount type chip
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _chipColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      '$chipLabel  •  ${offer.discountDisplay}',
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _chipColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),

                  // Stats + date row
                  Row(
                    children: [
                      _StatItem(
                        icon: Icons.visibility_outlined,
                        value: offer.viewCount.toString(),
                      ),
                      SizedBox(width: 8.w),
                      _StatItem(
                        icon: Icons.confirmation_number_outlined,
                        value: offer.usageCount.toString(),
                      ),
                      const Spacer(),
                      if (offer.endDate != null)
                        Text(
                          '${offer.endDate!.day}/${offer.endDate!.month}/${offer.endDate!.year}',
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: l10n.seller_offer_action_details,
                          background: AppColors.primaryOfSeller,
                          foreground: Colors.white,
                          onTap: onDetails,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: _ActionButton(
                          label: l10n.offer_delete_confirm_button,
                          background:
                              AppColors.textSecondary.withValues(alpha: 0.08),
                          foreground: AppColors.textSecondary,
                          onTap: onDelete,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    const double w = 88;
    const double h = 118;

    if (offer.imageUrl != null) {
      return Image.network(
        offer.imageUrl!,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(w, h),
        loadingBuilder: (ctx, child, progress) =>
            progress == null ? child : _placeholder(w, h),
      );
    }
    return _placeholder(w, h);
  }

  Widget _placeholder(double w, double h) {
    const gradients = [
      [Color(0xFF215194), Color(0xFF0D3470)],
      [Color(0xFF1565C0), Color(0xFF0D47A1)],
      [Color(0xFF37474F), Color(0xFF1C313A)],
      [Color(0xFF1B5E20), Color(0xFF004D40)],
    ];
    final g = gradients[offer.id.hashCode.abs() % gradients.length];
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: g,
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL HELPERS (private)
// ─────────────────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.w, color: AppColors.textSecondary),
        SizedBox(width: 3.w),
        Text(
          value,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34.h,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(7.r),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
