// ─────────────────────────────────────────────────────────────────────────────
// STORE STATS ENTITY — DOMAIN LAYER
// Pure Dart.  Holds the 4 KPI numbers shown on the seller home dashboard.
// ─────────────────────────────────────────────────────────────────────────────

class StoreStatsEntity {
  final int activeOffers;   // العروض النشطة
  final int usedCoupons;    // الكوبونات المستخدمة
  final int views;          // المشاهدات
  final int shares;         // المشاركات

  const StoreStatsEntity({
    required this.activeOffers,
    required this.usedCoupons,
    required this.views,
    required this.shares,
  });

  factory StoreStatsEntity.mock() => const StoreStatsEntity(
        activeOffers: 10,
        usedCoupons: 30,
        views: 1000,
        shares: 200,
      );

  /// Compact display: 1200 → "1.2K", 1000000 → "1M"
  static String compact(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) {
      final k = n / 1000;
      return k == k.truncateToDouble() ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    }
    return n.toString();
  }
}
