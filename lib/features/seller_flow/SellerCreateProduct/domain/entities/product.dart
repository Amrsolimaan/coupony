import 'product_image.dart';
import 'product_variant.dart';

class Product {
  final String id;
  final String title;
  final String slug;
  final String shortDescription;
  final String description;
  final String productType;
  final double basePrice;
  final double compareAtPrice;
  final String currency;
  final String sku;
  final String status;
  final bool isFeatured;
  final List<int> categoryIds;
  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.title,
    this.slug = '',
    this.shortDescription = '',
    this.description = '',
    this.productType = 'standard',
    required this.basePrice,
    this.compareAtPrice = 0.0,
    this.currency = 'EGP',
    this.sku = '',
    this.status = 'draft',
    this.isFeatured = false,
    this.categoryIds = const [],
    this.images = const [],
    this.variants = const [],
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? title,
    String? slug,
    String? shortDescription,
    String? description,
    String? productType,
    double? basePrice,
    double? compareAtPrice,
    String? currency,
    String? sku,
    String? status,
    bool? isFeatured,
    List<int>? categoryIds,
    List<ProductImage>? images,
    List<ProductVariant>? variants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      productType: productType ?? this.productType,
      basePrice: basePrice ?? this.basePrice,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      currency: currency ?? this.currency,
      sku: sku ?? this.sku,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      categoryIds: categoryIds ?? this.categoryIds,
      images: images ?? this.images,
      variants: variants ?? this.variants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
