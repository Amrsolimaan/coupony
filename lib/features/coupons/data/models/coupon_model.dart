import 'package:hive/hive.dart';
import '../../domain/entities/coupon_entity.dart';

part 'coupon_model.g.dart';

/// Coupon Model (Data Layer)
/// Hive-compatible model for local storage
/// 
/// ✅ CRITICAL: Only stores imageUrl as String, NOT binary data
/// Actual images are cached by CachedNetworkImage in file system
@HiveType(typeId: 3)
class CouponModel extends CouponEntity {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String title;

  @override
  @HiveField(2)
  final String description;

  @override
  @HiveField(3)
  final double discountPercentage;

  @override
  @HiveField(4)
  final double? originalPrice;

  @override
  @HiveField(5)
  final double? discountedPrice;

  @override
  @HiveField(6)
  final String storeName;

  @override
  @HiveField(7)
  final String storeId;

  @override
  @HiveField(8)
  final String categoryId;

  @override
  @HiveField(9)
  final String imageUrl; // ✅ String URL only, NOT Uint8List or List<int>

  @override
  @HiveField(10)
  final DateTime expiryDate;

  @override
  @HiveField(11)
  final bool isActive;

  @override
  @HiveField(12)
  final bool isFavorited;

  @override
  @HiveField(13)
  final int usageCount;

  @override
  @HiveField(14)
  final int? maxUsage;

  @override
  @HiveField(15)
  final String? couponCode;

  @override
  @HiveField(16)
  final String? termsAndConditions;

  @override
  @HiveField(17)
  final DateTime createdAt;

  const CouponModel({
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
  }) : super(
          id: id,
          title: title,
          description: description,
          discountPercentage: discountPercentage,
          originalPrice: originalPrice,
          discountedPrice: discountedPrice,
          storeName: storeName,
          storeId: storeId,
          categoryId: categoryId,
          imageUrl: imageUrl,
          expiryDate: expiryDate,
          isActive: isActive,
          isFavorited: isFavorited,
          usageCount: usageCount,
          maxUsage: maxUsage,
          couponCode: couponCode,
          termsAndConditions: termsAndConditions,
          createdAt: createdAt,
        );

  /// Convert Entity to Model
  factory CouponModel.fromEntity(CouponEntity entity) {
    return CouponModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      discountPercentage: entity.discountPercentage,
      originalPrice: entity.originalPrice,
      discountedPrice: entity.discountedPrice,
      storeName: entity.storeName,
      storeId: entity.storeId,
      categoryId: entity.categoryId,
      imageUrl: entity.imageUrl,
      expiryDate: entity.expiryDate,
      isActive: entity.isActive,
      isFavorited: entity.isFavorited,
      usageCount: entity.usageCount,
      maxUsage: entity.maxUsage,
      couponCode: entity.couponCode,
      termsAndConditions: entity.termsAndConditions,
      createdAt: entity.createdAt,
    );
  }

  /// Convert Model to Entity
  CouponEntity toEntity() {
    return CouponEntity(
      id: id,
      title: title,
      description: description,
      discountPercentage: discountPercentage,
      originalPrice: originalPrice,
      discountedPrice: discountedPrice,
      storeName: storeName,
      storeId: storeId,
      categoryId: categoryId,
      imageUrl: imageUrl,
      expiryDate: expiryDate,
      isActive: isActive,
      isFavorited: isFavorited,
      usageCount: usageCount,
      maxUsage: maxUsage,
      couponCode: couponCode,
      termsAndConditions: termsAndConditions,
      createdAt: createdAt,
    );
  }

  /// Factory constructor from JSON (API response)
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      discountedPrice: json['discounted_price'] != null
          ? (json['discounted_price'] as num).toDouble()
          : null,
      storeName: json['store_name'] as String,
      storeId: json['store_id'] as String,
      categoryId: json['category_id'] as String,
      imageUrl: json['image_url'] as String, // ✅ URL from API
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      isFavorited: json['is_favorited'] as bool? ?? false,
      usageCount: json['usage_count'] as int? ?? 0,
      maxUsage: json['max_usage'] as int?,
      couponCode: json['coupon_code'] as String?,
      termsAndConditions: json['terms_and_conditions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discount_percentage': discountPercentage,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'store_name': storeName,
      'store_id': storeId,
      'category_id': categoryId,
      'image_url': imageUrl, // ✅ URL sent to API
      'expiry_date': expiryDate.toIso8601String(),
      'is_active': isActive,
      'is_favorited': isFavorited,
      'usage_count': usageCount,
      'max_usage': maxUsage,
      'coupon_code': couponCode,
      'terms_and_conditions': termsAndConditions,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with method
  CouponModel copyWith({
    String? id,
    String? title,
    String? description,
    double? discountPercentage,
    double? originalPrice,
    double? discountedPrice,
    String? storeName,
    String? storeId,
    String? categoryId,
    String? imageUrl,
    DateTime? expiryDate,
    bool? isActive,
    bool? isFavorited,
    int? usageCount,
    int? maxUsage,
    String? couponCode,
    String? termsAndConditions,
    DateTime? createdAt,
  }) {
    return CouponModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      storeName: storeName ?? this.storeName,
      storeId: storeId ?? this.storeId,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      isFavorited: isFavorited ?? this.isFavorited,
      usageCount: usageCount ?? this.usageCount,
      maxUsage: maxUsage ?? this.maxUsage,
      couponCode: couponCode ?? this.couponCode,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
