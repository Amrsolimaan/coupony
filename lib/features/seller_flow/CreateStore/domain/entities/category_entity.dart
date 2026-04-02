import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final String? slug;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.slug,
  });

  @override
  List<Object?> get props => [id, name, slug];
}
