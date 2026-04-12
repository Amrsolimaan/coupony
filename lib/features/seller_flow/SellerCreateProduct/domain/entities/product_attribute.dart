class ProductAttribute {
  final String attributeName;
  final String attributeValue;
  final int sortOrder;

  const ProductAttribute({
    required this.attributeName,
    required this.attributeValue,
    this.sortOrder = 0,
  });

  ProductAttribute copyWith({
    String? attributeName,
    String? attributeValue,
    int? sortOrder,
  }) {
    return ProductAttribute(
      attributeName: attributeName ?? this.attributeName,
      attributeValue: attributeValue ?? this.attributeValue,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
