import '../../domain/entities/product_image.dart';

class ProductImageModel extends ProductImage {
  const ProductImageModel({
    required super.id,
    required super.url,
    super.sortOrder,
    super.isPrimary,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id']?.toString() ?? '',
      url: json['url'] as String? ??
          json['file_url'] as String? ??
          json['path'] as String? ??
          '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isPrimary: _parseBool(json['is_primary']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'sort_order': sortOrder,
        'is_primary': isPrimary,
      };
}
