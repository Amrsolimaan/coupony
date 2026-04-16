class HomeBannerEntity {
  final String id;
  final String imageUrl; // swap to real URL when backend is ready
  final String discountLabel;   // e.g. "25%"
  final String minTransaction;  // e.g. "\$500"
  final String dateRange;       // e.g. "25 - 29 June 2025"
  final String ctaLabel;

  const HomeBannerEntity({
    required this.id,
    required this.imageUrl,
    required this.discountLabel,
    required this.minTransaction,
    required this.dateRange,
    required this.ctaLabel,
  });
}
