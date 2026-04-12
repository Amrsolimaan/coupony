class ProductImage {
  final String id;
  final String url;
  final int sortOrder;
  final bool isPrimary;

  const ProductImage({
    required this.id,
    required this.url,
    this.sortOrder = 0,
    this.isPrimary = false,
  });

  ProductImage copyWith({
    String? id,
    String? url,
    int? sortOrder,
    bool? isPrimary,
  }) {
    return ProductImage(
      id: id ?? this.id,
      url: url ?? this.url,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
