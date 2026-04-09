import 'package:equatable/equatable.dart';
import 'public_category.dart';

class PublicProductImage extends Equatable {
  final String id;
  final String url;
  final int sortOrder;
  final bool isPrimary;

  const PublicProductImage({
    required this.id,
    required this.url,
    this.sortOrder = 0,
    this.isPrimary = false,
  });

  @override
  List<Object?> get props => [id, url, sortOrder, isPrimary];
}

class PublicProductAttribute extends Equatable {
  final String attributeName;
  final String attributeValue;
  final int sortOrder;

  const PublicProductAttribute({
    required this.attributeName,
    required this.attributeValue,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [attributeName, attributeValue, sortOrder];
}

class PublicProductVariant extends Equatable {
  final String id;
  final String title;
  final String optionSummary;
  final String sku;
  final double price;
  final double compareAtPrice;
  final String currency;
  final int sortOrder;
  final bool isDefault;
  final bool isActive;
  final List<PublicProductAttribute> attributes;

  const PublicProductVariant({
    required this.id,
    required this.title,
    this.optionSummary = '',
    this.sku = '',
    required this.price,
    this.compareAtPrice = 0.0,
    this.currency = 'EGP',
    this.sortOrder = 0,
    this.isDefault = false,
    this.isActive = true,
    this.attributes = const [],
  });

  @override
  List<Object?> get props => [
        id, title, optionSummary, sku, price,
        compareAtPrice, currency, sortOrder, isDefault, isActive, attributes,
      ];
}

class PublicProduct extends Equatable {
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
  final List<PublicCategory> categories;
  final List<PublicProductImage> images;
  final List<PublicProductVariant> variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PublicProduct({
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
    this.status = 'active',
    this.isFeatured = false,
    this.categories = const [],
    this.images = const [],
    this.variants = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Returns the primary image URL, or the first image, or empty string.
  String get primaryImageUrl {
    if (images.isEmpty) return '';
    final primary = images.where((img) => img.isPrimary).firstOrNull;
    return (primary ?? images.first).url;
  }

  /// Returns the default variant, or the first one, or null.
  PublicProductVariant? get defaultVariant {
    if (variants.isEmpty) return null;
    return variants.where((v) => v.isDefault).firstOrNull ?? variants.first;
  }

  @override
  List<Object?> get props => [
        id, title, slug, shortDescription, description, productType,
        basePrice, compareAtPrice, currency, sku, status, isFeatured,
        categories, images, variants, createdAt, updatedAt,
      ];
}
