import 'dart:convert';
import '../../domain/entities/public_product.dart';
import 'public_category_model.dart';

// ═══════════════════════════════════════════��════════════
// SUB-MODELS
// ════════════════════════════════════════════════════════

class PublicProductAttributeModel extends PublicProductAttribute {
  const PublicProductAttributeModel({
    required super.attributeName,
    required super.attributeValue,
    super.sortOrder,
  });

  factory PublicProductAttributeModel.fromJson(Map<String, dynamic> json) {
    return PublicProductAttributeModel(
      attributeName: json['attribute_name'] as String? ?? '',
      attributeValue: json['attribute_value'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'attribute_name': attributeName,
        'attribute_value': attributeValue,
        'sort_order': sortOrder,
      };
}

class PublicProductImageModel extends PublicProductImage {
  const PublicProductImageModel({
    required super.id,
    required super.url,
    super.sortOrder,
    super.isPrimary,
  });

  factory PublicProductImageModel.fromJson(Map<String, dynamic> json) {
    return PublicProductImageModel(
      id: json['id']?.toString() ?? '',
      url: json['url'] as String? ??
          json['file_url'] as String? ??
          json['path'] as String? ??
          '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isPrimary: _parseBool(json['is_primary']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'sort_order': sortOrder,
        'is_primary': isPrimary,
      };

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}

class PublicProductVariantModel extends PublicProductVariant {
  const PublicProductVariantModel({
    required super.id,
    required super.title,
    super.optionSummary,
    super.sku,
    required super.price,
    super.compareAtPrice,
    super.currency,
    super.sortOrder,
    super.isDefault,
    super.isActive,
    super.attributes,
  });

  factory PublicProductVariantModel.fromJson(Map<String, dynamic> json) {
    final rawAttrs = json['attributes'] as List<dynamic>? ?? [];
    final attributes = rawAttrs
        .map((a) =>
            PublicProductAttributeModel.fromJson(a as Map<String, dynamic>))
        .toList();

    return PublicProductVariantModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      optionSummary: json['option_summary'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      price: _parseDouble(json['price']),
      compareAtPrice: _parseDouble(json['compare_at_price']),
      currency: json['currency'] as String? ?? 'EGP',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isDefault: _parseBool(json['is_default']),
      isActive: _parseBool(json['is_active'] ?? true),
      attributes: attributes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'option_summary': optionSummary,
        'sku': sku,
        'price': price,
        'compare_at_price': compareAtPrice,
        'currency': currency,
        'sort_order': sortOrder,
        'is_default': isDefault,
        'is_active': isActive,
        'attributes': attributes
            .map((a) =>
                PublicProductAttributeModel(
                  attributeName: a.attributeName,
                  attributeValue: a.attributeValue,
                  sortOrder: a.sortOrder,
                ).toJson())
            .toList(),
      };

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}

// ════════════════════════════════════════════════════════
// MAIN MODEL
// ════════════════════════════════════════════════════════

class PublicProductModel extends PublicProduct {
  const PublicProductModel({
    required super.id,
    required super.title,
    super.slug,
    super.shortDescription,
    super.description,
    super.productType,
    required super.basePrice,
    super.compareAtPrice,
    super.currency,
    super.sku,
    super.status,
    super.isFeatured,
    super.categories,
    super.images,
    super.variants,
    super.createdAt,
    super.updatedAt,
  });

  factory PublicProductModel.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'] as List<dynamic>? ?? [];
    final categories = rawCategories
        .map((c) =>
            PublicCategoryModel.fromJson(c as Map<String, dynamic>))
        .toList();

    final rawImages = json['images'] as List<dynamic>? ?? [];
    final images = rawImages
        .map((i) =>
            PublicProductImageModel.fromJson(i as Map<String, dynamic>))
        .toList();

    final rawVariants = json['variants'] as List<dynamic>? ?? [];
    final variants = rawVariants
        .map((v) =>
            PublicProductVariantModel.fromJson(v as Map<String, dynamic>))
        .toList();

    return PublicProductModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      shortDescription: json['short_description'] as String? ?? '',
      description: json['description'] as String? ?? '',
      productType: json['product_type'] as String? ?? 'standard',
      basePrice: _parseDouble(json['base_price']),
      compareAtPrice: _parseDouble(json['compare_at_price']),
      currency: json['currency'] as String? ?? 'EGP',
      sku: json['sku'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      isFeatured: _parseBool(json['is_featured']),
      categories: categories,
      images: images,
      variants: variants,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slug': slug,
        'short_description': shortDescription,
        'description': description,
        'product_type': productType,
        'base_price': basePrice,
        'compare_at_price': compareAtPrice,
        'currency': currency,
        'sku': sku,
        'status': status,
        'is_featured': isFeatured,
        'categories': categories
            .map((c) => PublicCategoryModel.fromEntity(c).toJson())
            .toList(),
        'images': images
            .map((i) => PublicProductImageModel(
                  id: i.id, url: i.url,
                  sortOrder: i.sortOrder, isPrimary: i.isPrimary,
                ).toJson())
            .toList(),
        'variants': variants
            .map((v) => PublicProductVariantModel(
                  id: v.id, title: v.title,
                  optionSummary: v.optionSummary, sku: v.sku,
                  price: v.price, compareAtPrice: v.compareAtPrice,
                  currency: v.currency, sortOrder: v.sortOrder,
                  isDefault: v.isDefault, isActive: v.isActive,
                  attributes: v.attributes,
                ).toJson())
            .toList(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  /// Encode to JSON string for Hive storage.
  String encode() => jsonEncode(toJson());

  /// Decode from JSON string retrieved from Hive.
  static PublicProductModel decode(String raw) =>
      PublicProductModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}
