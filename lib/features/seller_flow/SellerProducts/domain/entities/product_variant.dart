import 'product_attribute.dart';

class ProductVariant {
  final String id;
  final String title;
  final String optionSummary;
  final String sku;
  final String barcode;
  final double price;
  final double compareAtPrice;
  final String currency;
  final int sortOrder;
  final bool isDefault;
  final bool isActive;
  final List<ProductAttribute> attributes;

  const ProductVariant({
    required this.id,
    required this.title,
    this.optionSummary = '',
    this.sku = '',
    this.barcode = '',
    required this.price,
    this.compareAtPrice = 0.0,
    this.currency = 'EGP',
    this.sortOrder = 0,
    this.isDefault = false,
    this.isActive = true,
    this.attributes = const [],
  });

  ProductVariant copyWith({
    String? id,
    String? title,
    String? optionSummary,
    String? sku,
    String? barcode,
    double? price,
    double? compareAtPrice,
    String? currency,
    int? sortOrder,
    bool? isDefault,
    bool? isActive,
    List<ProductAttribute>? attributes,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      title: title ?? this.title,
      optionSummary: optionSummary ?? this.optionSummary,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      currency: currency ?? this.currency,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      attributes: attributes ?? this.attributes,
    );
  }
}
