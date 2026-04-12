import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.slug,
    super.iconUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (slug != null) 'slug': slug,
      if (iconUrl != null) 'icon_url': iconUrl,
    };
  }

  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        name: name,
        slug: slug,
        iconUrl: iconUrl,
      );
}
