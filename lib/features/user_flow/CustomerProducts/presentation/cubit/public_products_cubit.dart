import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/use_cases/get_categories_use_case.dart';
import '../../domain/use_cases/get_category_products_use_case.dart';
import '../../domain/use_cases/get_product_details_use_case.dart';
import '../../domain/use_cases/get_public_products_use_case.dart';
import 'public_products_state.dart';

class PublicProductsCubit extends Cubit<PublicProductsState> {
  final GetPublicProductsUseCase getPublicProductsUseCase;
  final GetProductDetailsUseCase getProductDetailsUseCase;
  final GetPublicCategoriesUseCase getPublicCategoriesUseCase;
  final GetCategoryProductsUseCase getCategoryProductsUseCase;
  final Logger logger;

  PublicProductsCubit({
    required this.getPublicProductsUseCase,
    required this.getProductDetailsUseCase,
    required this.getPublicCategoriesUseCase,
    required this.getCategoryProductsUseCase,
    required this.logger,
  }) : super(const PublicProductsState());

  void _safeEmit(PublicProductsState s) {
    if (!isClosed) emit(s);
  }

  // ════════════════════════════════════════════════════════
  // LOAD PRODUCTS  (first page / refresh)
  // ════════════════════════════════════════════════════════

  Future<void> loadProducts({
    String? categoryId,
    String? search,
    bool? featured,
    int perPage = 15,
  }) async {
    _safeEmit(state.copyWith(
      isProductsLoading: true,
      clearProductsError: true,
      products: const [],
      currentPage: 1,
      hasMorePages: false,
      activeSearch: search,
      clearActiveSearch: search == null,
      activeCategoryFilter: categoryId,
      clearActiveCategoryFilter: categoryId == null,
    ));

    final params = GetPublicProductsParams(
      page: 1,
      perPage: perPage,
      categoryId: categoryId,
      search: search,
      featured: featured,
    );

    final result = await getPublicProductsUseCase(params);

    result.fold(
      (failure) {
        logger.w('loadProducts failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isProductsLoading: false,
          productsError: failure.message,
        ));
      },
      (paginated) {
        logger.i('loadProducts success: ${paginated.items.length} items '
            '(page 1/${paginated.lastPage}, total=${paginated.total})');
        _safeEmit(state.copyWith(
          isProductsLoading: false,
          products: paginated.items,
          currentPage: 1,
          hasMorePages: paginated.hasNextPage,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // LOAD MORE PRODUCTS  (next page, same filters)
  // ════════════════════════════════════════════════════════

  Future<void> loadMoreProducts({int perPage = 15}) async {
    if (!state.hasMorePages || state.isLoadingMore) return;

    final nextPage = state.currentPage + 1;
    _safeEmit(state.copyWith(isLoadingMore: true));

    final params = GetPublicProductsParams(
      page: nextPage,
      perPage: perPage,
      categoryId: state.activeCategoryFilter,
      search: state.activeSearch,
    );

    final result = await getPublicProductsUseCase(params);

    result.fold(
      (failure) {
        logger.w('loadMoreProducts failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isLoadingMore: false,
          productsError: failure.message,
        ));
      },
      (paginated) {
        logger.i('loadMoreProducts success: +${paginated.items.length} items '
            '(page $nextPage/${paginated.lastPage})');
        _safeEmit(state.copyWith(
          isLoadingMore: false,
          products: [...state.products, ...paginated.items],
          currentPage: nextPage,
          hasMorePages: paginated.hasNextPage,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // SEARCH  (resets to page 1 with search term)
  // ════════════════════════════════════════════════════════

  Future<void> searchProducts(String query, {int perPage = 15}) async {
    await loadProducts(
      search: query.trim().isEmpty ? null : query.trim(),
      categoryId: state.activeCategoryFilter,
      perPage: perPage,
    );
  }

  // ════════════════════════════════════════════════════════
  // PRODUCT DETAILS
  // ════════════════════════════════════════════════════════

  Future<void> loadProductDetails(String productId) async {
    _safeEmit(state.copyWith(
      isDetailLoading: true,
      clearDetailError: true,
      clearSelectedProduct: true,
    ));

    final result = await getProductDetailsUseCase(productId);

    result.fold(
      (failure) {
        logger.w('loadProductDetails failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isDetailLoading: false,
          detailError: failure.message,
        ));
      },
      (product) {
        logger.i('loadProductDetails success: id=${product.id}');
        _safeEmit(state.copyWith(
          isDetailLoading: false,
          selectedProduct: product,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // CATEGORIES
  // ════════════════════════════════════════════════════════

  Future<void> loadCategories() async {
    _safeEmit(state.copyWith(
      isCategoriesLoading: true,
      clearCategoriesError: true,
    ));

    final result = await getPublicCategoriesUseCase();

    result.fold(
      (failure) {
        logger.w('loadCategories failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isCategoriesLoading: false,
          categoriesError: failure.message,
        ));
      },
      (categories) {
        logger.i('loadCategories success: ${categories.length} categories');
        _safeEmit(state.copyWith(
          isCategoriesLoading: false,
          categories: categories,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // CATEGORY PRODUCTS  (first page / switch category)
  // ════════════════════════════════════════════════════════

  Future<void> loadCategoryProducts(
    String categoryId, {
    int perPage = 15,
  }) async {
    _safeEmit(state.copyWith(
      isCategoryProductsLoading: true,
      clearCategoryProductsError: true,
      categoryProducts: const [],
      categoryCurrentPage: 1,
      categoryHasMorePages: false,
      activeCategoryId: categoryId,
    ));

    final params = GetCategoryProductsParams(
      categoryId: categoryId,
      page: 1,
      perPage: perPage,
    );

    final result = await getCategoryProductsUseCase(params);

    result.fold(
      (failure) {
        logger.w('loadCategoryProducts failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isCategoryProductsLoading: false,
          categoryProductsError: failure.message,
        ));
      },
      (paginated) {
        logger.i('loadCategoryProducts success: '
            '${paginated.items.length} items (page 1/${paginated.lastPage})');
        _safeEmit(state.copyWith(
          isCategoryProductsLoading: false,
          categoryProducts: paginated.items,
          categoryCurrentPage: 1,
          categoryHasMorePages: paginated.hasNextPage,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // LOAD MORE CATEGORY PRODUCTS
  // ════════════════════════════════════════════════════════

  Future<void> loadMoreCategoryProducts({int perPage = 15}) async {
    if (!state.categoryHasMorePages || state.isCategoryLoadingMore) return;
    final categoryId = state.activeCategoryId;
    if (categoryId == null) return;

    final nextPage = state.categoryCurrentPage + 1;
    _safeEmit(state.copyWith(isCategoryLoadingMore: true));

    final params = GetCategoryProductsParams(
      categoryId: categoryId,
      page: nextPage,
      perPage: perPage,
    );

    final result = await getCategoryProductsUseCase(params);

    result.fold(
      (failure) {
        logger.w('loadMoreCategoryProducts failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isCategoryLoadingMore: false,
          categoryProductsError: failure.message,
        ));
      },
      (paginated) {
        logger.i('loadMoreCategoryProducts success: '
            '+${paginated.items.length} items '
            '(page $nextPage/${paginated.lastPage})');
        _safeEmit(state.copyWith(
          isCategoryLoadingMore: false,
          categoryProducts: [
            ...state.categoryProducts,
            ...paginated.items,
          ],
          categoryCurrentPage: nextPage,
          categoryHasMorePages: paginated.hasNextPage,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════

  void clearErrors() {
    _safeEmit(state.copyWith(
      clearProductsError: true,
      clearDetailError: true,
      clearCategoriesError: true,
      clearCategoryProductsError: true,
    ));
  }

  void clearSelectedProduct() {
    _safeEmit(state.copyWith(clearSelectedProduct: true));
  }
}
