import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

// ════════════════════════════════════════════════════════
// NAVIGATION SIGNAL
// ════════════════════════════════════════════════════════

enum SellerProductsNav { none, productCreated, productUpdated, productDeleted }

// ════════════════════════════════════════════════════════
// STATE
// ════════════════════════════════════════════════════════

class SellerProductsState extends Equatable {
  // ── List ──────────────────────────────────────────────
  final bool isListLoading;
  final List<Product> products;
  final String? listError;

  // ── Single Product ─────────────────────────────────────
  final bool isDetailLoading;
  final Product? selectedProduct;
  final String? detailError;

  // ── Create / Update / Delete ──────────────────────────
  final bool isSubmitting;
  final String? successKey;
  final String? submitError;

  // ── Navigation Signal ─────────────────────────────────
  final SellerProductsNav navigationSignal;

  const SellerProductsState({
    this.isListLoading = false,
    this.products = const [],
    this.listError,
    this.isDetailLoading = false,
    this.selectedProduct,
    this.detailError,
    this.isSubmitting = false,
    this.successKey,
    this.submitError,
    this.navigationSignal = SellerProductsNav.none,
  });

  SellerProductsState copyWith({
    bool? isListLoading,
    List<Product>? products,
    String? listError,
    bool? isDetailLoading,
    Product? selectedProduct,
    bool clearSelectedProduct = false,
    String? detailError,
    bool? isSubmitting,
    String? successKey,
    bool clearSuccessKey = false,
    String? submitError,
    bool clearSubmitError = false,
    SellerProductsNav? navigationSignal,
  }) {
    return SellerProductsState(
      isListLoading: isListLoading ?? this.isListLoading,
      products: products ?? this.products,
      listError: listError ?? this.listError,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      selectedProduct: clearSelectedProduct
          ? null
          : selectedProduct ?? this.selectedProduct,
      detailError: detailError ?? this.detailError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      successKey:
          clearSuccessKey ? null : successKey ?? this.successKey,
      submitError:
          clearSubmitError ? null : submitError ?? this.submitError,
      navigationSignal: navigationSignal ?? this.navigationSignal,
    );
  }

  @override
  List<Object?> get props => [
        isListLoading,
        products,
        listError,
        isDetailLoading,
        selectedProduct,
        detailError,
        isSubmitting,
        successKey,
        submitError,
        navigationSignal,
      ];
}
