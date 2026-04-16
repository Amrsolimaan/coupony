import 'package:flutter/material.dart';

import '../../domain/entities/home_banner_entity.dart';
import '../../domain/entities/home_category_entity.dart';
import '../../domain/entities/home_offer_entity.dart';
import '../../presentation/widgets/home_featured_offers_widget.dart';
import '../../presentation/widgets/home_stores_row_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME MOCK DATA SOURCE
// All image URLs live here — swap them easily when the real backend is ready.
// Using Unsplash CDN: free, high-quality, no auth required.
// ─────────────────────────────────────────────────────────────────────────────

// ── Image URLs (single source of truth) ────────────────────────────────────
class _Img {
  // Banners
  static const bannerCamera =
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600&q=80&fit=crop';
  static const bannerFashion =
      'https://images.unsplash.com/photo-1445205170230-053b83016050?w=600&q=80&fit=crop';
  static const bannerFood =
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&q=80&fit=crop';

  // Offers
  static const jacket =
      'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=400&q=80&fit=crop';
  static const headphones =
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&q=80&fit=crop';
  static const perfume =
      'https://images.unsplash.com/photo-1541643600914-78b084683702?w=400&q=80&fit=crop';
  static const shoes =
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80&fit=crop';
  static const hotel =
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80&fit=crop';
  static const flight =
      'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400&q=80&fit=crop';
  static const resort =
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&q=80&fit=crop';
  static const watch =
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&q=80&fit=crop';
  static const camera =
      'https://images.unsplash.com/photo-1516035642093-88c6f3b0e7f5?w=400&q=80&fit=crop';
}

class HomeMockDataSource {
  // ── Categories ──────────────────────────────────────────────────────────────

  static List<HomeCategoryEntity> get categories => const [
        HomeCategoryEntity(
          id: 'beauty',
          label: 'تجميل',
          icon: Icons.face_retouching_natural_outlined,
        ),
        HomeCategoryEntity(
          id: 'travel',
          label: 'سفر',
          icon: Icons.flight_outlined,
        ),
        HomeCategoryEntity(
          id: 'restaurants',
          label: 'مطاعم',
          icon: Icons.restaurant_outlined,
        ),
        HomeCategoryEntity(
          id: 'electronics',
          label: 'إلكترونيات',
          icon: Icons.devices_outlined,
        ),
        HomeCategoryEntity(
          id: 'fashion',
          label: 'أزياء',
          icon: Icons.checkroom_outlined,
        ),
        HomeCategoryEntity(
          id: 'supermarket',
          label: 'سوبر',
          icon: Icons.local_grocery_store_outlined,
        ),
      ];

  // ── Banners ─────────────────────────────────────────────────────────────────

  static List<HomeBannerEntity> get banners => const [
        HomeBannerEntity(
          id: 'b1',
          imageUrl: _Img.bannerCamera,
          discountLabel: '25%',
          minTransaction: '\$500',
          dateRange: '25 - 29 June 2025',
          ctaLabel: 'Shop now',
        ),
        HomeBannerEntity(
          id: 'b2',
          imageUrl: _Img.bannerFashion,
          discountLabel: '40%',
          minTransaction: '\$200',
          dateRange: '1 - 10 July 2025',
          ctaLabel: 'Shop now',
        ),
        HomeBannerEntity(
          id: 'b3',
          imageUrl: _Img.bannerFood,
          discountLabel: '15%',
          minTransaction: '\$50',
          dateRange: '20 - 25 June 2025',
          ctaLabel: 'Shop now',
        ),
      ];

  // ── Personalized Offers ─────────────────────────────────────────────────────

  static List<HomeOfferEntity> get personalizedOffers => const [
        HomeOfferEntity(
          id: 'p1',
          imageUrl: _Img.jacket,
          title: 'تخفيضات الجاكيت الشتوي',
          originalPrice: 350,
          discountedPrice: 210,
          savePercent: 40,
          category: 'fashion',
          storeName: 'Zara',
        ),
        HomeOfferEntity(
          id: 'p2',
          imageUrl: _Img.headphones,
          title: 'سماعات لاسلكية بصوت نقي',
          originalPrice: 799,
          discountedPrice: 559,
          savePercent: 30,
          category: 'electronics',
          storeName: 'Sony Store',
        ),
        HomeOfferEntity(
          id: 'p3',
          imageUrl: _Img.perfume,
          title: 'عطر أزهار الربيع الفاخر',
          originalPrice: 450,
          discountedPrice: 315,
          savePercent: 30,
          category: 'beauty',
          storeName: 'Parfum',
        ),
        HomeOfferEntity(
          id: 'p4',
          imageUrl: _Img.shoes,
          title: 'أحذية رياضية كلاسيكية',
          originalPrice: 600,
          discountedPrice: 360,
          savePercent: 40,
          category: 'fashion',
          storeName: 'Nike',
        ),
      ];

  // ── Travel Offers ────────────────────────────────────────────────────────────

  static List<HomeOfferEntity> get travelOffers => const [
        HomeOfferEntity(
          id: 't1',
          imageUrl: _Img.hotel,
          title: 'إقامة فندقية 5 نجوم في دبي',
          originalPrice: 1999,
          discountedPrice: 1399,
          savePercent: 30,
          category: 'travel',
          storeName: 'Booking.com',
        ),
        HomeOfferEntity(
          id: 't2',
          imageUrl: _Img.flight,
          title: 'تذاكر طيران للقاهرة',
          originalPrice: 850,
          discountedPrice: 595,
          savePercent: 30,
          category: 'travel',
          storeName: 'EgyptAir',
        ),
        HomeOfferEntity(
          id: 't3',
          imageUrl: _Img.resort,
          title: 'منتجع شاطئي شرم الشيخ',
          originalPrice: 2500,
          discountedPrice: 1500,
          savePercent: 40,
          category: 'travel',
          storeName: 'Marriott',
        ),
      ];

  // ── Egypt Offers ─────────────────────────────────────────────────────────────

  static List<HomeOfferEntity> get egyptOffers => const [
        HomeOfferEntity(
          id: 'e1',
          imageUrl: _Img.headphones,
          title: 'سماعات JBL بخصم رائع',
          originalPrice: 1999,
          discountedPrice: 1399,
          savePercent: 30,
          category: 'electronics',
          storeName: 'Virgin Megastore',
        ),
        HomeOfferEntity(
          id: 'e2',
          imageUrl: _Img.jacket,
          title: 'عروض موسم الصيف',
          originalPrice: 599,
          discountedPrice: 419,
          savePercent: 30,
          category: 'fashion',
          storeName: 'H&M Egypt',
        ),
        HomeOfferEntity(
          id: 'e3',
          imageUrl: _Img.perfume,
          title: 'كوبون خصم عطور فاخرة',
          originalPrice: 1200,
          discountedPrice: 720,
          savePercent: 40,
          category: 'beauty',
          storeName: 'Faces',
        ),
      ];

  // ── Favorites ────────────────────────────────────────────────────────────────

  static List<HomeOfferEntity> get favorites => const [
        HomeOfferEntity(
          id: 'f1',
          imageUrl: _Img.shoes,
          title: 'نايكي إير ماكس المحدودة',
          originalPrice: 1200,
          discountedPrice: 840,
          savePercent: 30,
          isFavorite: true,
          category: 'fashion',
          storeName: 'Nike',
        ),
        HomeOfferEntity(
          id: 'f2',
          imageUrl: _Img.camera,
          title: 'كاميرا ميرورليس احترافية',
          originalPrice: 8500,
          discountedPrice: 5950,
          savePercent: 30,
          isFavorite: true,
          category: 'electronics',
          storeName: 'Canon',
        ),
        HomeOfferEntity(
          id: 'f3',
          imageUrl: _Img.watch,
          title: 'ساعة فاخرة بسعر مميز',
          originalPrice: 3200,
          discountedPrice: 2240,
          savePercent: 30,
          isFavorite: true,
          category: 'fashion',
          storeName: 'Watch House',
        ),
      ];

  // ── Promo end time ───────────────────────────────────────────────────────────

  static DateTime get promoEndTime => DateTime(2025, 6, 29, 23, 59, 59);

  // ── User info ────────────────────────────────────────────────────────────────

  static String get userName => 'مريم عبد العزيز';
  static String get userLocation => '2464 Royal Ln. Mesa, New Jersey';

  // ── Stores ───────────────────────────────────────────────────────────────────

  static List<StoreItem> get stores => const [
        StoreItem(
          id: 's1',
          name: 'B-you',
          imageUrl:
              'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=200&q=80&fit=crop',
        ),
        StoreItem(
          id: 's2',
          name: 'Aldo',
          imageUrl:
              'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=200&q=80&fit=crop',
        ),
        StoreItem(
          id: 's3',
          name: 'Kids store',
          imageUrl:
              'https://images.unsplash.com/photo-1503944583220-79d8926ad5e2?w=200&q=80&fit=crop',
        ),
        StoreItem(
          id: 's4',
          name: 'Ravin',
          imageUrl:
              'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=200&q=80&fit=crop',
        ),
        StoreItem(
          id: 's5',
          name: 'T-Brand',
          imageUrl:
              'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=200&q=80&fit=crop',
        ),
      ];

  // ── Featured Offers ──────────────────────────────────────────────────────────

  static List<FeaturedOfferItem> get featuredOffers => const [
        FeaturedOfferItem(
          id: 'fo1',
          title: 'تخفيضات كبيرة على المعاطف',
          storeName: 'محل Jolie-الفيوم',
          originalPrice: 450,
          discountedPrice: 350,
          discountPercent: 40,
          imageUrl: _Img.jacket,
        ),
        FeaturedOfferItem(
          id: 'fo2',
          title: 'تخفيضات كبيرة على المعاطف',
          storeName: 'محل Jolie-الفيوم',
          originalPrice: 450,
          discountedPrice: 350,
          discountPercent: 40,
          imageUrl: _Img.perfume,
        ),
        FeaturedOfferItem(
          id: 'fo3',
          title: 'تخفيضات كبيرة على المعاطف',
          storeName: 'محل Jolie-الفيوم',
          originalPrice: 450,
          discountedPrice: 350,
          discountPercent: 40,
          imageUrl: _Img.shoes,
        ),
      ];
}
