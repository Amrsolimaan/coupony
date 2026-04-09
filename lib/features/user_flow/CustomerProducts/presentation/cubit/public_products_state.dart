import 'package:equatable/equatable.dart';
import '../../domain/entities/public_category.dart';
import '../../domain/entities/public_product.dart';

class PublicProductsState extends Equatable {
  // ── Product List ──────────────────────────────────────
  final bool isProductsLoading;    // First-page loading indicator
  final bool isLoadingMore;        // Subsequent-page indicator
  final List<PublicProduct> products;
  final int currentPage;
  final bool hasMorePages;
  final String? productsError;

  // ── Active Filters ────────────────────────────────────
  final String? activeSearch;
  final String? activeCategoryFilter; // category query param for main list

  // ── Product Detail ────────────────────────────────────
  final bool isDetailLoading;
  final PublicProduct? selectedProduct;
  final String? detailError;

  // ── Categories ────────────────────────────────────────
  final bool isCategoriesLoading;
  final List<PublicCategory> categories;
  final String? categoriesError;

  // ── Category Products ─────────────────────────────────
  final bool isCategoryProductsLoading;   // First-page
  final bool isCategoryLoadingMore;       // Subsequent pages
  final List<PublicProduct> categoryProducts;
  final int categoryCurrentPage;
  final bool categoryHasMorePages;
  final String? categoryProductsError;
  final String? activeCategoryId;         // Category being browsed

  const PublicProductsState({
    this.isProductsLoading = false,
    this.isLoadingMore = false,
    this.products = const [],
    this.currentPage = 1,
    this.hasMorePages = false,
    this.productsError,
    this.activeSearch,
    this.activeCategoryFilter,
    this.isDetailLoading = false,
    this.selectedProduct,
    this.detailError,
    this.isCategoriesLoading = false,
    this.categories = const [],
    this.categoriesError,
    this.isCategoryProductsLoading = false,
    this.isCategoryLoadingMore = false,
    this.categoryProducts = const [],
    this.categoryCurrentPage = 1,
    this.categoryHasMorePages = false,
    this.categoryProductsError,
    this.activeCategoryId,
  });

  PublicProductsState copyWith({
    bool? isProductsLoading,
    bool? isLoadingMore,
    List<PublicProduct>? products,
    int? currentPage,
    bool? hasMorePages,
    String? productsError,
    bool clearProductsError = false,
    String? activeSearch,
    bool clearActiveSearch = false,
    String? activeCategoryFilter,
    bool clearActiveCategoryFilter = false,
    bool? isDetailLoading,
    PublicProduct? selectedProduct,
    bool clearSelectedProduct = false,
    String? detailError,
    bool clearDetailError = false,
    bool? isCategoriesLoading,
    List<PublicCategory>? categories,
    String? categoriesError,
    bool clearCategoriesError = false,
    bool? isCategoryProductsLoading,
    bool? isCategoryLoadingMore,
    List<PublicProduct>? categoryProducts,
    int? categoryCurrentPage,
    bool? categoryHasMorePages,
    String? categoryProductsError,
    bool clearCategoryProductsError = false,
    String? activeCategoryId,
    bool clearActiveCategoryId = false,
  }) {
    return PublicProductsState(
      isProductsLoading: isProductsLoading ?? this.isProductsLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      productsError:
          clearProductsError ? null : productsError ?? this.productsError,
      activeSearch:
          clearActiveSearch ? null : activeSearch ?? this.activeSearch,
      activeCategoryFilter: clearActiveCategoryFilter
          ? null
          : activeCategoryFilter ?? this.activeCategoryFilter,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      selectedProduct: clearSelectedProduct
          ? null
          : selectedProduct ?? this.selectedProduct,
      detailError: clearDetailError ? null : detailError ?? this.detailError,
      isCategoriesLoading: isCategoriesLoading ?? this.isCategoriesLoading,
      categories: categories ?? this.categories,
      categoriesError:
          clearCategoriesError ? null : categoriesError ?? this.categoriesError,
      isCategoryProductsLoading:
          isCategoryProductsLoading ?? this.isCategoryProductsLoading,
      isCategoryLoadingMore:
          isCategoryLoadingMore ?? this.isCategoryLoadingMore,
      categoryProducts: categoryProducts ?? this.categoryProducts,
      categoryCurrentPage: categoryCurrentPage ?? this.categoryCurrentPage,
      categoryHasMorePages: categoryHasMorePages ?? this.categoryHasMorePages,
      categoryProductsError: clearCategoryProductsError
          ? null
          : categoryProductsError ?? this.categoryProductsError,
      activeCategoryId: clearActiveCategoryId
          ? null
          : activeCategoryId ?? this.activeCategoryId,
    );
  }

  @override
  List<Object?> get props => [
        isProductsLoading, isLoadingMore, products, currentPage, hasMorePages,
        productsError, activeSearch, activeCategoryFilter,
        isDetailLoading, selectedProduct, detailError,
        isCategoriesLoading, categories, categoriesError,
        isCategoryProductsLoading, isCategoryLoadingMore, categoryProducts,
        categoryCurrentPage, categoryHasMorePages, categoryProductsError,
        activeCategoryId,
      ];
}
