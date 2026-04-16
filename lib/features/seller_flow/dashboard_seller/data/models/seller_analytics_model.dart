import '../../domain/entities/seller_analytics_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER ANALYTICS — DATA MODELS
// Extend entities and provide the static mock factory.
// Swap mock() for a real fromJson() when the API is ready.
// ─────────────────────────────────────────────────────────────────────────────

class OfferTypeDistributionModel extends OfferTypeDistributionEntity {
  const OfferTypeDistributionModel({
    required super.label,
    required super.percentage,
    required super.colorValue,
  });
}

class TopOfferModel extends TopOfferEntity {
  const TopOfferModel({
    required super.title,
    required super.tag,
    required super.views,
    required super.usages,
  });
}

class SellerAnalyticsModel extends SellerAnalyticsEntity {
  const SellerAnalyticsModel({
    required super.storeName,
    required super.storeAvatar,
    required super.monthlyGoal,
    required super.monthlyAchieved,
    required super.goalGrowthPercent,
    required super.newFollowers,
    required super.followersGrowthPercent,
    required super.offerDistribution,
    required super.topOffers,
  });

  // ── Hard-coded mock (matches the UI design image) ──────────────────────────
  static SellerAnalyticsModel mock() {
    return const SellerAnalyticsModel(
      storeName: 'M Brand',
      storeAvatar: null,
      monthlyGoal: 5000,
      monthlyAchieved: 3450,
      goalGrowthPercent: 15.0,
      newFollowers: 250,
      followersGrowthPercent: 35.0,
      offerDistribution: [
        OfferTypeDistributionModel(
          label: 'خصومات نسبية',
          percentage: 45.0,
          colorValue: 0xFF215194, // Seller primary blue
        ),
        OfferTypeDistributionModel(
          label: 'عروض مجانية',
          percentage: 30.0,
          colorValue: 0xFF34C759, // Success green
        ),
        OfferTypeDistributionModel(
          label: 'شحن مجاني',
          percentage: 15.0,
          colorValue: 0xFFFF6B35, // Orange
        ),
        OfferTypeDistributionModel(
          label: 'أخرى',
          percentage: 10.0,
          colorValue: 0xFF1A1A1A, // Near-black
        ),
      ],
      topOffers: [
        TopOfferModel(
          title: 'خصم 20% على كل المنتجات',
          tag: 'نسبة مئوية',
          views: 234,
          usages: 12,
        ),
        TopOfferModel(
          title: 'خصم 20% على كل المنتجات',
          tag: 'نسبة مئوية',
          views: 234,
          usages: 12,
        ),
        TopOfferModel(
          title: 'خصم 20% على كل المنتجات',
          tag: 'نسبة مئوية',
          views: 234,
          usages: 12,
        ),
        TopOfferModel(
          title: 'خصم 20% على كل المنتجات',
          tag: 'نسبة مئوية',
          views: 234,
          usages: 12,
        ),
        TopOfferModel(
          title: 'خصم 20% على كل المنتجات',
          tag: 'نسبة مئوية',
          views: 234,
          usages: 12,
        ),
        TopOfferModel(
          title: 'خصم 20% على كل المنتجات',
          tag: 'نسبة مئوية',
          views: 234,
          usages: 12,
        ),
      ],
    );
  }
}
