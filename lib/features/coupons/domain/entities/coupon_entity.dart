import 'package:equatable/equatable.dart';

/// Coupon Entity (Domain Layer)
/// Pure business logic representation of a coupon
/// Free from any infrastructure dependencies
class CouponEntity extends Equatable {
  /// Unique coupon ID
  final String id;

  /// Coupon title
  final String title;

  /// Coupon description
  final String description;

  /// Discount percentage (e.g., 20 for 20% off)
  final double discountPercentage;

  /// Original price (optional)
  final double? originalPrice;

  /// Discounted price (optional)
  final double? discountedPrice;

  /// Store/merchant name
  final String storeName;

  /// Store/merchant ID
  final String storeId;

  /// Category ID (e.g., 'restaurants', 'fashion')
  final String categoryId;

  /// Image URL (stored as String, NOT binary data)
  /// ✅ CRITICAL: Only URL stored in Hive, actual image cached by CachedNetworkImage
  final String imageUrl;

  /// Expiry date
  final DateTime expiryDate;

  /// Whether coupon is active
  final bool isActive;

  /// Whether user has favorited this coupon
  final bool isFavorited;

  /// Number of times this coupon has been used
  final int usageCount;

  /// Maximum number of uses allowed (null = unlimited)
  final int? maxUsage;

  /// Coupon code (if applicable)
  final String? couponCode;

  /// Terms and conditions
  final String? termsAndConditions;

  /// Created timestamp
  final DateTime createdAt;

  const CouponEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    this.originalPrice,
    this.discountedPrice,
    required this.storeName,
    required this.storeId,
    required this.categoryId,
    required this.imageUrl,
    required this.expiryDate,
    this.isActive = true,
    this.isFavorited = false,
    this.usageCount = 0,
    this.maxUsage,
    this.couponCode,
    this.termsAndConditions,
    required this.createdAt,
  });

  /// Check if coupon is expired
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// Check if coupon has reached max usage
  bool get hasReachedMaxUsage =>
      maxUsage != null && usageCount >= maxUsage!;

  /// Check if coupon is available for use
  bool get isAvailable => isActive && !isExpired && !hasReachedMaxUsage;

  /// Get days until expiry
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  /// Check if expiring soon (within 3 days)
  bool get isExpiringSoon => daysUntilExpiry <= 3 && daysUntilExpiry > 0;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        discountPercentage,
        originalPrice,
        discountedPrice,
        storeName,
        storeId,
        categoryId,
        imageUrl,
        expiryDate,
        isActive,
        isFavorited,
        usageCount,
        maxUsage,
        couponCode,
        termsAndConditions,
        createdAt,
      ];

  @override
  String toString() {
    return 'CouponEntity('
        'id: $id, '
        'title: $title, '
        'discount: $discountPercentage%, '
        'store: $storeName, '
        'isAvailable: $isAvailable'
        ')';
  }
}
