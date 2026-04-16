import 'package:coupony/config/dependency_injection/injection_container.dart';
import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/extensions/snackbar_extension.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/widgets/custom_bottom_nav_bar/customer_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../cubit/customer_home_cubit.dart';
import '../cubit/customer_home_state.dart';
import '../widgets/home_banner_carousel_widget.dart';
import '../widgets/home_categories_widget.dart';
import '../widgets/home_countdown_widget.dart';
import '../widgets/home_featured_banner_widget.dart';
import '../widgets/home_featured_offers_widget.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/home_offers_row_widget.dart';
import '../widgets/home_stores_row_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER HOME PAGE
// Clean orchestrator — no business logic here; only layout + BlocBuilder.
// ─────────────────────────────────────────────────────────────────────────────

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _navIndex = 4; // Home tab active

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomerHomeCubit>()..loadHomeData(),
      child: BlocConsumer<CustomerHomeCubit, CustomerHomeState>(
        listener: _handleStateListener,
        builder: (context, state) {
          // Always show skeleton immediately, even on initial state
          final data = state is CustomerHomeLoaded
              ? state
              : CustomerHomeLoaded.skeleton();

          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Skeletonizer(
              enabled: data.isLoading,
              effect: ShimmerEffect(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade50,
                duration: const Duration(milliseconds: 1400),
              ),
              child: _buildBody(context, data),
            ),
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: _navIndex,
              onTap: _onNavTap,
            ),
          );
        },
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, CustomerHomeLoaded data) {
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Orange Header (sticky) with search bar inside ───────────────────
        SliverToBoxAdapter(
          child: HomeHeaderWidget(
            userName: data.userName,
            userLocation: data.userLocation,
            onBellTap: () => context.showInfoSnackBar('لا توجد إشعارات جديدة'),
            onLocationTap: () {},
            onMicTap: () => context.showInfoSnackBar('البحث الصوتي قريباً'),
          ),
        ),

        // ── Categories ───────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: HomeCategoriesWidget(
            categories: data.categories,
            onCategoryTap: (cat) =>
                context.showInfoSnackBar('${cat.label} — قريباً'),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 4.h)),

        // ── Countdown ────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: HomeCountdownWidget(endTime: data.promoEndTime),
        ),

        // ── Banner Carousel ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: HomeBannerCarouselWidget(banners: data.banners),
        ),

        // ── Personalized Offers ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: HomeOffersRowWidget(
            title: l10n.home_personalized_title,
            offers: data.personalizedOffers,
            onSeeAll: () {},
            onFavoriteTap: (id) =>
                context.read<CustomerHomeCubit>().toggleFavorite(id),
          ),
        ),

        // ── Stores Row ───────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: HomeStoresRowWidget(
            stores: data.stores,
            onStoreTap: (store) =>
                context.showInfoSnackBar('${store.name} — قريباً'),
          ),
        ),

        // ── Featured Offers ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: HomeFeaturedOffersWidget(
            offers: data.featuredOffers,
            onOfferTap: (offer) =>
                context.showInfoSnackBar('${offer.title} — قريباً'),
            onFavoriteTap: (id) =>
                context.read<CustomerHomeCubit>().toggleFavorite(id),
          ),
        ),

        // ── Featured Banner (البحر الأحمر) ───────────────────────────────────
        SliverToBoxAdapter(
          child: HomeFeaturedBannerWidget(
            title: 'البحر الأحمر',
            subtitle: 'اكتشف أفضل عروض المنتجعات والغوص الرائعة',
            ctaLabel: 'اكتشف الآن',
            backgroundColor: const Color(0xFF0A4B6E),
          ),
        ),

        // ── Travel Offers ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: HomeOffersRowWidget(
            title: l10n.home_travel_offers_title,
            offers: data.travelOffers,
            onSeeAll: () {},
            onFavoriteTap: (id) =>
                context.read<CustomerHomeCubit>().toggleFavorite(id),
          ),
        ),

        // ── Egypt Offers ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: HomeOffersRowWidget(
            title: l10n.home_egypt_offers_title,
            offers: data.egyptOffers,
            onSeeAll: () {},
            onFavoriteTap: (id) =>
                context.read<CustomerHomeCubit>().toggleFavorite(id),
          ),
        ),

        // ── Favorites ────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: HomeOffersRowWidget(
            title: l10n.home_favorites_title,
            offers: data.favorites,
            onSeeAll: () {},
            onFavoriteTap: (id) =>
                context.read<CustomerHomeCubit>().toggleFavorite(id),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
      ],
    );
  }

  // ── BlocListener handler ──────────────────────────────────────────────────

  void _handleStateListener(BuildContext context, CustomerHomeState state) {
    if (state is CustomerHomeError) {
      context.showErrorSnackBar(state.message);
    }
  }

  // ── Bottom nav handler ────────────────────────────────────────────────────

  void _onNavTap(int index) {
    if (index == _navIndex) return;
    setState(() => _navIndex = index);

    switch (index) {
      case 0:
        context.push(AppRouter.customerProfile);
      case 1:
      case 2:
      case 3:
        context.showInfoSnackBar('قريباً...');
      default:
        break;
    }
  }
}
