// ─────────────────────────────────────────────────────────────────────────────
// OFFER ENTITY — DOMAIN LAYER
// Pure Dart, no Flutter imports.
// ─────────────────────────────────────────────────────────────────────────────

/// How the discount is applied to the offer.
enum DiscountType { percentage, buyGet, fixedAmount }

/// Lifecycle status of an offer — computed from its dates.
enum OfferStatus { active, expired, scheduled }

/// A single seller offer / product coupon entry.
class OfferEntity {
  final String id;
  final String title;
  final String description;
  final DiscountType discountType;
  final String? category;
  final String? subCategory;

  /// Available size labels, e.g. ['S', 'M', 'L', 'XL'].
  final List<String> sizes;

  /// Selected ARGB color values, e.g. [0xFF3B82F6, 0xFF10B981].
  final List<int> colorValues;

  final double originalPrice;
  final double discountedPrice;

  /// true  → publish immediately
  /// false → scheduled (use startDate / endDate)
  final bool publishNow;

  final DateTime? startDate;
  final DateTime? endDate;

  /// Remote or local image URL/path. Null falls back to a gradient placeholder.
  final String? imageUrl;

  // ── Store info ─────────────────────────────────────────────────────────────
  final String storeName;
  final String? storeLogoUrl;
  final double storeRating;

  // ── Stats ──────────────────────────────────────────────────────────────────
  final int viewCount;
  final int usageCount;

  const OfferEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.discountType,
    this.category,
    this.subCategory,
    this.sizes = const [],
    this.colorValues = const [],
    required this.originalPrice,
    required this.discountedPrice,
    this.publishNow = false,
    this.startDate,
    this.endDate,
    this.imageUrl,
    this.storeName = 'متجري',
    this.storeLogoUrl,
    this.storeRating = 4.0,
    this.viewCount = 0,
    this.usageCount = 0,
  });

  /// Discount percentage (only meaningful when discountType is [DiscountType.percentage]).
  double get discountPercent {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100);
  }

  /// Formatted discount string shown in UI (e.g. "18 %").
  String get discountDisplay {
    switch (discountType) {
      case DiscountType.percentage:
        return '${discountPercent.toStringAsFixed(0)} %';
      case DiscountType.fixedAmount:
        return '${(originalPrice - discountedPrice).toStringAsFixed(0)} ر.س';
      case DiscountType.buyGet:
        return 'اشتري و احصل على';
    }
  }

  /// Computed status based on current date-time and the offer's date range.
  OfferStatus get offerStatus {
    final now = DateTime.now();
    if (endDate != null && endDate!.isBefore(now)) {
      return OfferStatus.expired;
    }
    if (startDate != null && startDate!.isAfter(now)) {
      return OfferStatus.scheduled;
    }
    return OfferStatus.active;
  }

  // ── Mock factory ────────────────────────────────────────────────────────────

  static List<OfferEntity> mockList() {
    final now = DateTime.now();
    return [
      // ── Active (start in past, end in future) ──────────────────────────────
      OfferEntity(
        id: 'o1',
        title: 'خصم 30% على جميع الملابس',
        description:
            'احصل على خصم حصري على جميع قطع الملابس في المتجر. العرض محدود المدة فلا تفوّت الفرصة.',
        discountType: DiscountType.percentage,
        category: 'ملابس',
        subCategory: 'رجالي',
        sizes: ['S', 'M', 'L', 'XL'],
        colorValues: [0xFF3B82F6, 0xFF111827],
        originalPrice: 550,
        discountedPrice: 385,
        publishNow: false,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 7)),
        imageUrl: 'https://picsum.photos/seed/offer1/400/400',
        storeName: 'متجر الأناقة',
        storeLogoUrl: 'https://picsum.photos/seed/store1/100/100',
        storeRating: 4.5,
        viewCount: 1240,
        usageCount: 87,
      ),
      OfferEntity(
        id: 'o2',
        title: 'تخفيض الجواكيت الشتوية',
        description: 'عروض حصرية على جاكيتات الشتاء بخامات عالية الجودة تناسب جميع الأذواق.',
        discountType: DiscountType.percentage,
        category: 'ملابس',
        subCategory: 'رجالي',
        sizes: ['M', 'L', 'XL', 'XXL'],
        colorValues: [0xFF6B7280, 0xFF111827],
        originalPrice: 800,
        discountedPrice: 600,
        publishNow: true,
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 14)),
        imageUrl: 'https://picsum.photos/seed/offer2/400/400',
        storeName: 'متجر الأناقة',
        storeLogoUrl: 'https://picsum.photos/seed/store1/100/100',
        storeRating: 4.5,
        viewCount: 890,
        usageCount: 53,
      ),
      // ── Expired (endDate in past) ──────────────────────────────────────────
      OfferEntity(
        id: 'o3',
        title: 'عرض الأحذية الرياضية',
        description: 'خصم رائع على أفضل الأحذية الرياضية لموسم الصيف الماضي.',
        discountType: DiscountType.fixedAmount,
        category: 'أحذية',
        subCategory: 'رجالي',
        sizes: ['40', '41', '42', '43', '44'],
        colorValues: [0xFFFFFFFF, 0xFF3B82F6],
        originalPrice: 450,
        discountedPrice: 350,
        publishNow: false,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.subtract(const Duration(days: 5)),
        imageUrl: 'https://picsum.photos/seed/offer3/400/400',
        storeName: 'متجر الأناقة',
        storeLogoUrl: 'https://picsum.photos/seed/store1/100/100',
        storeRating: 4.5,
        viewCount: 2100,
        usageCount: 145,
      ),
      OfferEntity(
        id: 'o4',
        title: 'خصم 25% على البلوزات',
        description: 'تشكيلة واسعة من البلوزات العصرية لجميع المقاسات والألوان.',
        discountType: DiscountType.percentage,
        category: 'ملابس',
        subCategory: 'حريمي',
        sizes: ['XS', 'S', 'M', 'L'],
        colorValues: [0xFF8B5CF6, 0xFFEC4899],
        originalPrice: 320,
        discountedPrice: 240,
        publishNow: false,
        startDate: now.subtract(const Duration(days: 20)),
        endDate: now.subtract(const Duration(days: 2)),
        imageUrl: 'https://picsum.photos/seed/offer4/400/400',
        storeName: 'متجر الأناقة',
        storeLogoUrl: 'https://picsum.photos/seed/store1/100/100',
        storeRating: 4.5,
        viewCount: 670,
        usageCount: 41,
      ),
      // ── Scheduled (startDate in future) ───────────────────────────────────
      OfferEntity(
        id: 'o5',
        title: 'بنطلونات كاجوال - عرض قادم',
        description: 'بنطلونات كاجوال أنيقة للعمل والنزهات. سيكون متاحاً قريباً في متجرنا!',
        discountType: DiscountType.percentage,
        category: 'ملابس',
        subCategory: 'رجالي',
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colorValues: [0xFF111827, 0xFF6B7280],
        originalPrice: 290,
        discountedPrice: 220,
        publishNow: false,
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 20)),
        imageUrl: 'https://picsum.photos/seed/offer5/400/400',
        storeName: 'متجر الأناقة',
        storeLogoUrl: 'https://picsum.photos/seed/store1/100/100',
        storeRating: 4.5,
        viewCount: 0,
        usageCount: 0,
      ),
      OfferEntity(
        id: 'o6',
        title: 'اشتري قطعتين واحصل على الثالثة',
        description: 'عرض خاص على تشكيلة التيشيرتات للأطفال. عرض مجدول لموسم العودة للمدارس.',
        discountType: DiscountType.buyGet,
        category: 'ملابس',
        subCategory: 'اطفالي',
        sizes: ['2Y', '4Y', '6Y', '8Y'],
        colorValues: [0xFF10B981, 0xFFEF4444, 0xFF3B82F6],
        originalPrice: 150,
        discountedPrice: 100,
        publishNow: false,
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 30)),
        imageUrl: 'https://picsum.photos/seed/offer6/400/400',
        storeName: 'متجر الأناقة',
        storeLogoUrl: 'https://picsum.photos/seed/store1/100/100',
        storeRating: 4.5,
        viewCount: 0,
        usageCount: 0,
      ),
    ];
  }
}
