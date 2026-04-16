import 'package:coupony/features/seller_flow/dashboard_seller/domain/entities/store_display_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHOP DISPLAY — DATA MODELS
// Extend domain entities. Swap mock() for fromJson() when the API is ready.
// ─────────────────────────────────────────────────────────────────────────────

class StoreHoursModel extends StoreHoursEntity {
  const StoreHoursModel({
    required super.dayOfWeek,
    required super.openTime,
    required super.closeTime,
    required super.isClosed,
  });

  factory StoreHoursModel.fromJson(Map<String, dynamic> json) {
    return StoreHoursModel(
      dayOfWeek: json['day_of_week'] as int,
      openTime: json['open_time'] as String,
      closeTime: json['close_time'] as String,
      isClosed: (json['is_closed'] as int) == 1,
    );
  }
}

class StoreCategoryModel extends StoreCategoryEntity {
  const StoreCategoryModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    super.iconUrl,
  });

  factory StoreCategoryModel.fromJson(Map<String, dynamic> json) {
    return StoreCategoryModel(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String? ?? json['name'] as String,
      nameEn: json['name_en'] as String? ?? json['name'] as String,
      iconUrl: json['icon_url'] as String?,
    );
  }
}

class UserReviewModel extends UserReviewEntity {
  const UserReviewModel({
    required super.id,
    required super.reviewerName,
    super.reviewerAvatar,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });
}

class RatingSummaryModel extends RatingSummaryEntity {
  const RatingSummaryModel({
    required super.averageRating,
    required super.totalCount,
    required super.distribution,
  });
}

class StoreDisplayModel extends StoreDisplayEntity {
  const StoreDisplayModel({
    required super.id,
    required super.name,
    super.description,
    super.logoUrl,
    super.bannerUrl,
    super.email,
    super.phone,
    required super.status,
    required super.isVerified,
    required super.subscriptionTier,
    required super.ratingAvg,
    required super.ratingCount,
    required super.followersCount,
    required super.couponsCount,
    required super.categories,
    required super.hours,
    required super.reviews,
    required super.ratingSummary,
  });

  // ── fromJson — maps GET /api/v1/stores response ───────────────────────────
  // ✅ Uses real API data for: id, name, description, logo, banner, phone,
  //    status, isVerified, subscriptionTier, ratings, categories, hours
  // 🎭 Uses mock data for: followersCount, couponsCount, reviews, ratingSummary
  factory StoreDisplayModel.fromJson(Map<String, dynamic> json) {
    final categoriesJson = (json['categories'] as List<dynamic>?) ?? [];
    final hoursJson = (json['hours'] as List<dynamic>?) ?? [];

    return StoreDisplayModel(
      // ✅ Real API data
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      subscriptionTier: json['subscription_tier'] as String? ?? 'free',
      ratingAvg: double.tryParse(json['rating_avg'].toString()) ?? 0.0,
      ratingCount: json['rating_count'] as int? ?? 0,
      
      // ✅ Real API data - Categories
      categories: categoriesJson
          .map((c) => StoreCategoryModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      
      // ✅ Real API data - Hours
      hours: hoursJson
          .map((h) => StoreHoursModel.fromJson(h as Map<String, dynamic>))
          .toList(),
      
      // 🎭 Mock data - will be replaced when endpoints are available
      followersCount: 12500,
      couponsCount: 24,
      reviews: _getMockReviews(),
      ratingSummary: _getMockRatingSummary(),
    );
  }

  // ── Mock data helpers ──────────────────────────────────────────────────────
  
  static List<UserReviewModel> _getMockReviews() {
    return [
      UserReviewModel(
        id: 'r1',
        reviewerName: 'أحمد محمد',
        reviewerAvatar: null,
        rating: 5.0,
        comment: 'تجربة رائعة! المنتجات عالية الجودة وخدمة ممتازة.',
        createdAt: DateTime(2026, 4, 10),
      ),
      UserReviewModel(
        id: 'r2',
        reviewerName: 'سارة علي',
        reviewerAvatar: null,
        rating: 5.0,
        comment: 'أفضل متجر ملابس في المنطقة، سأشتري منهم مرة أخرى بالتأكيد.',
        createdAt: DateTime(2026, 4, 8),
      ),
      UserReviewModel(
        id: 'r3',
        reviewerName: 'محمد عبدالله',
        reviewerAvatar: null,
        rating: 4.0,
        comment: 'جودة جيدة وأسعار مناسبة. التوصيل كان أسرع مما توقعت.',
        createdAt: DateTime(2026, 4, 5),
      ),
      UserReviewModel(
        id: 'r4',
        reviewerName: 'نور حسن',
        reviewerAvatar: null,
        rating: 5.0,
        comment: 'الكوبونات رائعة وفرت عليّ الكثير. متجر موثوق جداً.',
        createdAt: DateTime(2026, 4, 3),
      ),
      UserReviewModel(
        id: 'r5',
        reviewerName: 'علي يوسف',
        reviewerAvatar: null,
        rating: 4.0,
        comment: 'مجموعة متنوعة من الملابس بأسعار مقبولة.',
        createdAt: DateTime(2026, 3, 28),
      ),
    ];
  }

  static RatingSummaryModel _getMockRatingSummary() {
    return const RatingSummaryModel(
      averageRating: 4.8,
      totalCount: 342,
      distribution: {5: 240, 4: 70, 3: 20, 2: 8, 1: 4},
    );
  }

  // ── Hard-coded mock matching the UI design image ───────────────────────────
  static StoreDisplayModel mock() {
    return StoreDisplayModel(
      id: 'db44b0b7-f39d-4f00-9632-3805c6c164f0',
      name: 'T Brand',
      description:
          'متجر T Brand متخصص في أزياء الرجال والسيدات بأحدث التصاميم العالمية. '
          'نوفر تجربة تسوق فريدة تجمع بين الجودة العالية والأسعار المناسبة لجميع الأذواق.',
      logoUrl: null,
      bannerUrl: null,
      email: 'info@tbrand.com',
      phone: '+20 100 123 4567',
      status: 'active',
      isVerified: false,
      subscriptionTier: 'free',
      ratingAvg: 4.8,
      ratingCount: 342,
      followersCount: 12500,
      couponsCount: 24,
      categories: const [
        StoreCategoryModel(
          id: 2,
          nameAr: 'أزياء وملابس',
          nameEn: 'Fashion & Clothing',
          iconUrl: null,
        ),
      ],
      // Hours reflect the real endpoint data (Sun & Sat closed)
      hours: const [
        StoreHoursModel(
          dayOfWeek: 0,
          openTime: '09:00:00',
          closeTime: '17:00:00',
          isClosed: true,
        ),
        StoreHoursModel(
          dayOfWeek: 1,
          openTime: '09:00:00',
          closeTime: '17:00:00',
          isClosed: false,
        ),
        StoreHoursModel(
          dayOfWeek: 2,
          openTime: '09:00:00',
          closeTime: '17:00:00',
          isClosed: false,
        ),
        StoreHoursModel(
          dayOfWeek: 3,
          openTime: '09:00:00',
          closeTime: '17:00:00',
          isClosed: false,
        ),
        StoreHoursModel(
          dayOfWeek: 4,
          openTime: '09:00:00',
          closeTime: '17:00:00',
          isClosed: false,
        ),
        StoreHoursModel(
          dayOfWeek: 5,
          openTime: '09:00:00',
          closeTime: '17:00:00',
          isClosed: false,
        ),
        StoreHoursModel(
          dayOfWeek: 6,
          openTime: '09:00:00',
          closeTime: '17:00:00',
          isClosed: true,
        ),
      ],
      reviews: [
        UserReviewModel(
          id: 'r1',
          reviewerName: 'أحمد محمد',
          reviewerAvatar: null,
          rating: 5.0,
          comment: 'تجربة رائعة! المنتجات عالية الجودة وخدمة ممتازة.',
          createdAt: DateTime(2026, 4, 10),
        ),
        UserReviewModel(
          id: 'r2',
          reviewerName: 'سارة علي',
          reviewerAvatar: null,
          rating: 5.0,
          comment: 'أفضل متجر ملابس في المنطقة، سأشتري منهم مرة أخرى بالتأكيد.',
          createdAt: DateTime(2026, 4, 8),
        ),
        UserReviewModel(
          id: 'r3',
          reviewerName: 'محمد عبدالله',
          reviewerAvatar: null,
          rating: 4.0,
          comment: 'جودة جيدة وأسعار مناسبة. التوصيل كان أسرع مما توقعت.',
          createdAt: DateTime(2026, 4, 5),
        ),
        UserReviewModel(
          id: 'r4',
          reviewerName: 'نور حسن',
          reviewerAvatar: null,
          rating: 5.0,
          comment: 'الكوبونات رائعة وفرت عليّ الكثير. متجر موثوق جداً.',
          createdAt: DateTime(2026, 4, 3),
        ),
        UserReviewModel(
          id: 'r5',
          reviewerName: 'علي يوسف',
          reviewerAvatar: null,
          rating: 4.0,
          comment: 'مجموعة متنوعة من الملابس بأسعار مقبولة.',
          createdAt: DateTime(2026, 3, 28),
        ),
      ],
      ratingSummary: const RatingSummaryModel(
        averageRating: 4.8,
        totalCount: 342,
        distribution: {5: 240, 4: 70, 3: 20, 2: 8, 1: 4},
      ),
    );
  }
}
