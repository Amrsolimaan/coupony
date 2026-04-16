// ─────────────────────────────────────────────────────────────────────────────
// SELLER ANALYTICS — DOMAIN ENTITIES
// Pure Dart classes, no Flutter imports, no data-source coupling.
// ─────────────────────────────────────────────────────────────────────────────

/// Single slice in the offer-type donut chart.
class OfferTypeDistributionEntity {
  final String label;
  final double percentage;

  /// ARGB color packed as int (e.g. 0xFF215194).
  /// Kept as an int so the domain layer stays Flutter-free.
  final int colorValue;

  const OfferTypeDistributionEntity({
    required this.label,
    required this.percentage,
    required this.colorValue,
  });
}

/// One entry in the "top performing offers" list.
class TopOfferEntity {
  final String title;
  final String tag;
  final int views;
  final int usages;

  const TopOfferEntity({
    required this.title,
    required this.tag,
    required this.views,
    required this.usages,
  });
}

/// Root analytics entity — the single source of truth for the analytics screen.
class SellerAnalyticsEntity {
  final String storeName;
  final String? storeAvatar;

  // ── Monthly Coupon Goal ──────────────────────────────────────────────────────
  final double monthlyGoal;
  final double monthlyAchieved;

  /// Positive number, e.g. 15 means +15 % vs. last period.
  final double goalGrowthPercent;

  // ── New Followers ────────────────────────────────────────────────────────────
  final int newFollowers;
  final double followersGrowthPercent;

  // ── Charts & Lists ───────────────────────────────────────────────────────────
  final List<OfferTypeDistributionEntity> offerDistribution;
  final List<TopOfferEntity> topOffers;

  const SellerAnalyticsEntity({
    required this.storeName,
    required this.storeAvatar,
    required this.monthlyGoal,
    required this.monthlyAchieved,
    required this.goalGrowthPercent,
    required this.newFollowers,
    required this.followersGrowthPercent,
    required this.offerDistribution,
    required this.topOffers,
  });

  /// 0.0 – 1.0 completion ratio, clamped for safety.
  double get goalCompletionRatio =>
      (monthlyAchieved / monthlyGoal).clamp(0.0, 1.0);

  /// Completion percentage, e.g. 69.
  int get goalCompletionPercent => (goalCompletionRatio * 100).round();
}
