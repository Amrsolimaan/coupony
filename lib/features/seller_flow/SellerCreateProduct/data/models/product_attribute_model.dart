import '../../domain/entities/product_attribute.dart';

class ProductAttributeModel extends ProductAttribute {
  const ProductAttributeModel({
    required super.attributeName,
    required super.attributeValue,
    super.sortOrder,
  });

  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeModel(
      attributeName: json['attribute_name'] as String? ?? '',
      attributeValue: json['attribute_value'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  factory ProductAttributeModel.fromEntity(ProductAttribute entity) {
    return ProductAttributeModel(
      attributeName: entity.attributeName,
      attributeValue: entity.attributeValue,
      sortOrder: entity.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => {
        'attribute_name': attributeName,
        'attribute_value': attributeValue,
        'sort_order': sortOrder,
      };
}
