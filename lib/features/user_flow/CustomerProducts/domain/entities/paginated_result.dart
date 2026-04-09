import 'package:equatable/equatable.dart';

class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  bool get hasNextPage => currentPage < lastPage;
  bool get isFirstPage => currentPage == 1;

  @override
  List<Object?> get props => [items, currentPage, lastPage, perPage, total];
}
