import 'dart:convert';
import '../../domain/entities/public_category.dart';

class PublicCategoryModel extends PublicCategory {
  const PublicCategoryModel({
    required super.id,
    required super.name,
    super.slug,
    super.iconUrl,
    super.productCount,
  });

  factory PublicCategoryModel.fromJson(Map<String, dynamic> json) {
    return PublicCategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      iconUrl: json['icon_url'] as String? ?? json['icon'] as String?,
      productCount: (json['products_count'] as num?)?.toInt() ??
          (json['product_count'] as num?)?.toInt(),
    );
  }

  factory PublicCategoryModel.fromEntity(PublicCategory entity) {
    return PublicCategoryModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      iconUrl: entity.iconUrl,
      productCount: entity.productCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (slug != null) 'slug': slug,
        if (iconUrl != null) 'icon_url': iconUrl,
        if (productCount != null) 'products_count': productCount,
      };

  /// Encode to a JSON string for Hive storage.
  String encode() => jsonEncode(toJson());

  /// Decode from a JSON string retrieved from Hive.
  static PublicCategoryModel decode(String raw) =>
      PublicCategoryModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
}
