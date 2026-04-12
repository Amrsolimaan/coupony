import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/use_cases/create_product_use_case.dart';
import '../../domain/use_cases/delete_product_use_case.dart';
import '../../domain/use_cases/get_product_use_case.dart';
import '../../domain/use_cases/list_products_use_case.dart';
import '../../domain/use_cases/update_product_status_use_case.dart';
import '../../domain/use_cases/update_product_use_case.dart';
import 'seller_products_state.dart';

class SellerProductsCubit extends Cubit<SellerProductsState> {
  final ListProductsUseCase listProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final GetProductUseCase getProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final UpdateProductStatusUseCase updateProductStatusUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final Logger logger;

  SellerProductsCubit({
    required this.listProductsUseCase,
    required this.createProductUseCase,
    required this.getProductUseCase,
    required this.updateProductUseCase,
    required this.updateProductStatusUseCase,
    required this.deleteProductUseCase,
    required this.logger,
  }) : super(const SellerProductsState());

  void _safeEmit(SellerProductsState s) {
    if (!isClosed) emit(s);
  }

  // ════════════════════════════════════════════════════════
  // LIST PRODUCTS
  // ════════════════════════════════════════════════════════

  Future<void> loadProducts(ListProductsParams params) async {
    _safeEmit(state.copyWith(
      isListLoading: true,
      listError: null,
    ));

    final result = await listProductsUseCase(params);

    result.fold(
      (failure) {
        logger.w('LoadProducts failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isListLoading: false,
          listError: failure.message,
        ));
      },
      (products) {
        logger.i('LoadProducts success: ${products.length} products');
        _safeEmit(state.copyWith(
          isListLoading: false,
          products: products,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // GET PRODUCT DETAILS
  // ════════════════════════════════════════════════════════

  Future<void> loadProductDetails({
    required String storeId,
    required String productId,
  }) async {
    _safeEmit(state.copyWith(
      isDetailLoading: true,
      detailError: null,
      clearSelectedProduct: true,
    ));

    final result = await getProductUseCase(
      storeId: storeId,
      productId: productId,
    );

    result.fold(
      (failure) {
        logger.w('LoadProductDetails failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isDetailLoading: false,
          detailError: failure.message,
        ));
      },
      (product) {
        logger.i('LoadProductDetails success: id=${product.id}');
        _safeEmit(state.copyWith(
          isDetailLoading: false,
          selectedProduct: product,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // CREATE PRODUCT
  // ════════════════════════════════════════════════════════

  Future<void> createProduct(CreateProductParams params) async {
    if (params.title.trim().isEmpty) {
      _safeEmit(state.copyWith(
        submitError: 'error_seller_product_title_required',
      ));
      return;
    }

    logger.i('Creating product "${params.title}" for store ${params.storeId}');
    _safeEmit(state.copyWith(
      isSubmitting: true,
      clearSubmitError: true,
      clearSuccessKey: true,
    ));

    final result = await createProductUseCase(params);

    result.fold(
      (failure) {
        logger.e('CreateProduct failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isSubmitting: false,
          submitError: failure.message,
        ));
      },
      (product) {
        logger.i('CreateProduct success: id=${product.id}');

        // Prepend new product to list without a full reload
        final updated = [product, ...state.products];
        _safeEmit(state.copyWith(
          isSubmitting: false,
          products: updated,
          selectedProduct: product,
          successKey: 'success_seller_product_created',
          navigationSignal: SellerProductsNav.productCreated,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // UPDATE PRODUCT
  // ════════════════════════════════════════════════════════

  Future<void> updateProduct(UpdateProductParams params) async {
    logger.i('Updating product ${params.productId}');
    _safeEmit(state.copyWith(
      isSubmitting: true,
      clearSubmitError: true,
      clearSuccessKey: true,
    ));

    final result = await updateProductUseCase(params);

    result.fold(
      (failure) {
        logger.e('UpdateProduct failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isSubmitting: false,
          submitError: failure.message,
        ));
      },
      (product) {
        logger.i('UpdateProduct success: id=${product.id}');

        // Replace the product in the list
        final updated = state.products.map((p) {
          return p.id == product.id ? product : p;
        }).toList();

        _safeEmit(state.copyWith(
          isSubmitting: false,
          products: updated,
          selectedProduct: product,
          successKey: 'success_seller_product_updated',
          navigationSignal: SellerProductsNav.productUpdated,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // UPDATE PRODUCT STATUS
  // ════════════════════════════════════════════════════════

  Future<void> updateProductStatus({
    required String storeId,
    required String productId,
    required String status,
  }) async {
    logger.i('Updating status of product $productId to "$status"');
    _safeEmit(state.copyWith(
      isSubmitting: true,
      clearSubmitError: true,
      clearSuccessKey: true,
    ));

    final result = await updateProductStatusUseCase(
      storeId: storeId,
      productId: productId,
      status: status,
    );

    result.fold(
      (failure) {
        logger.e('UpdateProductStatus failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isSubmitting: false,
          submitError: failure.message,
        ));
      },
      (product) {
        logger.i('UpdateProductStatus success: id=${product.id} '
            'status=${product.status}');

        final updated = state.products.map((p) {
          return p.id == product.id ? product : p;
        }).toList();

        _safeEmit(state.copyWith(
          isSubmitting: false,
          products: updated,
          selectedProduct: product,
          successKey: 'success_seller_product_status_updated',
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // DELETE PRODUCT
  // ════════════════════════════════════════════════════════

  Future<void> deleteProduct({
    required String storeId,
    required String productId,
  }) async {
    logger.i('Deleting product $productId from store $storeId');
    _safeEmit(state.copyWith(
      isSubmitting: true,
      clearSubmitError: true,
      clearSuccessKey: true,
    ));

    final result = await deleteProductUseCase(
      storeId: storeId,
      productId: productId,
    );

    result.fold(
      (failure) {
        logger.e('DeleteProduct failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isSubmitting: false,
          submitError: failure.message,
        ));
      },
      (_) {
        logger.i('DeleteProduct success: id=$productId');

        final updated =
            state.products.where((p) => p.id != productId).toList();

        _safeEmit(state.copyWith(
          isSubmitting: false,
          products: updated,
          clearSelectedProduct: true,
          successKey: 'success_seller_product_deleted',
          navigationSignal: SellerProductsNav.productDeleted,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════

  void clearNavigationSignal() {
    _safeEmit(state.copyWith(
      navigationSignal: SellerProductsNav.none,
    ));
  }

  void clearMessages() {
    _safeEmit(state.copyWith(
      clearSuccessKey: true,
      clearSubmitError: true,
    ));
  }
}
