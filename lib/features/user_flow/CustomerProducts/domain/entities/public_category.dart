import 'package:equatable/equatable.dart';

class PublicCategory extends Equatable {
  final int id;
  final String name;
  final String? slug;
  final String? iconUrl;
  final int? productCount;

  const PublicCategory({
    required this.id,
    required this.name,
    this.slug,
    this.iconUrl,
    this.productCount,
  });

  PublicCategory copyWith({
    int? id,
    String? name,
    String? slug,
    String? iconUrl,
    int? productCount,
  }) {
    return PublicCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      iconUrl: iconUrl ?? this.iconUrl,
      productCount: productCount ?? this.productCount,
    );
  }

  @override
  List<Object?> get props => [id, name, slug, iconUrl, productCount];
}
