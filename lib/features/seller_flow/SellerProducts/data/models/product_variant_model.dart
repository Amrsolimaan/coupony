import '../../domain/entities/product_variant.dart';
import 'product_attribute_model.dart';

class ProductVariantModel extends ProductVariant {
  const ProductVariantModel({
    required super.id,
    required super.title,
    super.optionSummary,
    super.sku,
    super.barcode,
    required super.price,
    super.compareAtPrice,
    super.currency,
    super.sortOrder,
    super.isDefault,
    super.isActive,
    super.attributes,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final rawAttributes = json['attributes'] as List<dynamic>? ?? [];
    final attributes = rawAttributes
        .map((a) => ProductAttributeModel.fromJson(a as Map<String, dynamic>))
        .toList();

    return ProductVariantModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      optionSummary: json['option_summary'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      price: _parseDouble(json['price']),
      compareAtPrice: _parseDouble(json['compare_at_price']),
      currency: json['currency'] as String? ?? 'EGP',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isDefault: _parseBool(json['is_default']),
      isActive: _parseBool(json['is_active'] ?? true),
      attributes: attributes,
    );
  }

  factory ProductVariantModel.fromEntity(ProductVariant entity) {
    return ProductVariantModel(
      id: entity.id,
      title: entity.title,
      optionSummary: entity.optionSummary,
      sku: entity.sku,
      barcode: entity.barcode,
      price: entity.price,
      compareAtPrice: entity.compareAtPrice,
      currency: entity.currency,
      sortOrder: entity.sortOrder,
      isDefault: entity.isDefault,
      isActive: entity.isActive,
      attributes: entity.attributes,
    );
  }

  /// JSON body used for PUT update (full replacement).
  Map<String, dynamic> toJson() => {
        'title': title,
        'option_summary': optionSummary,
        'sku': sku,
        'barcode': barcode,
        'price': price,
        'compare_at_price': compareAtPrice,
        'currency': currency,
        'sort_order': sortOrder,
        'is_default': isDefault,
        'is_active': isActive,
        'attributes': attributes
            .map((a) => ProductAttributeModel.fromEntity(a).toJson())
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
