// ─────────────────────────────────────────────────────────────────────────────
// STORE DISPLAY — DOMAIN ENTITIES
// Pure Dart, no Flutter imports, no data-source coupling.
// ─────────────────────────────────────────────────────────────────────────────

/// A single business-hours slot for one day of the week.
class StoreHoursEntity {
  final int dayOfWeek; // 0 = Sunday … 6 = Saturday
  final String openTime; // "HH:mm:ss"
  final String closeTime; // "HH:mm:ss"
  final bool isClosed;

  const StoreHoursEntity({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  /// Display-friendly time stripped of seconds: "09:00:00" → "09:00".
  String get openDisplay => openTime.substring(0, 5);
  String get closeDisplay => closeTime.substring(0, 5);
}

/// One store category (supports both AR and EN label).
class StoreCategoryEntity {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? iconUrl;

  const StoreCategoryEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.iconUrl,
  });
}

/// Single user review entry (mock field — not yet in the endpoint).
class UserReviewEntity {
  final String id;
  final String reviewerName;
  final String? reviewerAvatar; // nullable: falls back to initial letter
  final double rating; // 1.0 – 5.0
  final String comment;
  final DateTime createdAt;

  const UserReviewEntity({
    required this.id,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

/// Aggregate rating breakdown for the summary card.
class RatingSummaryEntity {
  final double averageRating;
  final int totalCount;

  /// key = star level (1–5), value = number of reviews at that level.
  final Map<int, int> distribution;

  const RatingSummaryEntity({
    required this.averageRating,
    required this.totalCount,
    required this.distribution,
  });

  /// Returns a 0.0–1.0 fill ratio for the given star bar.
  double ratioForStar(int star) {
    if (totalCount == 0) return 0.0;
    return ((distribution[star] ?? 0) / totalCount).clamp(0.0, 1.0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROOT ENTITY
// ─────────────────────────────────────────────────────────────────────────────

class StoreDisplayEntity {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? email;
  final String? phone;
  final String status;
  final bool isVerified;
  final String subscriptionTier;
  final double ratingAvg;
  final int ratingCount;

  // ── Mock-backed fields (to be replaced by real endpoints later) ───────────
  final int followersCount;
  final int couponsCount;

  // ── Relations ─────────────────────────────────────────────────────────────
  final List<StoreCategoryEntity> categories;
  final List<StoreHoursEntity> hours;
  final List<UserReviewEntity> reviews;
  final RatingSummaryEntity ratingSummary;

  const StoreDisplayEntity({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.email,
    this.phone,
    required this.status,
    required this.isVerified,
    required this.subscriptionTier,
    required this.ratingAvg,
    required this.ratingCount,
    required this.followersCount,
    required this.couponsCount,
    required this.categories,
    required this.hours,
    required this.reviews,
    required this.ratingSummary,
  });

  bool get isActive => status == 'active';

  /// Returns the display initial when no logo URL is available.
  String get initial =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';

  /// Formats follower count: 12500 → "12.5K".
  String get followersDisplay {
    if (followersCount >= 1000) {
      final k = followersCount / 1000;
      return k == k.truncateToDouble() ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    }
    return followersCount.toString();
  }
}
