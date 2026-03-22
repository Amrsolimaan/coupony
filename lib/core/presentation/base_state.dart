import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Generic base state for all feature Cubits
/// Handles: Initial, Loading, Success, Error, Offline
abstract class BaseState<T> extends Equatable {
  const BaseState();
}

class InitialState<T> extends BaseState<T> {
  const InitialState();
  
  @override
  List<Object?> get props => [];
}

class LoadingState<T> extends BaseState<T> {
  const LoadingState();
  
  @override
  List<Object?> get props => [];
}

class SuccessState<T> extends BaseState<T> {
  final T data;
  final bool isFromCache;

  const SuccessState(this.data, {this.isFromCache = false});
  
  @override
  List<Object?> get props => [data, isFromCache];
}

class ErrorState<T> extends BaseState<T> {
  final Failure failure;
  final T? cachedData; // For graceful degradation

  const ErrorState(this.failure, {this.cachedData});
  
  @override
  List<Object?> get props => [failure, cachedData];
}

class OfflineState<T> extends BaseState<T> {
  final T? cachedData;

  const OfflineState({this.cachedData});
  
  @override
  List<Object?> get props => [cachedData];
}

/// For paginated lists
class PaginationState<T> extends BaseState<List<T>> {
  final List<T> items;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;

  const PaginationState({
    required this.items,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
  
  @override
  List<Object?> get props => [items, isLoadingMore, hasReachedMax, currentPage];
}
