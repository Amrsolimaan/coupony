import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/offer_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MANAGE OFFER STATE
// ─────────────────────────────────────────────────────────────────────────────

class ManageOfferState {
  final DiscountType discountType;
  final String? category;
  final String? subCategory;
  final List<String> selectedSizes;
  final List<int> selectedColors;
  final bool publishNow;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? imagePath;
  final bool isSubmitting;
  final bool isSuccess;
  final String? submitError;

  /// Per-field validation messages. Key matches a field identifier constant.
  final Map<String, String> fieldErrors;

  const ManageOfferState({
    this.discountType = DiscountType.percentage,
    this.category,
    this.subCategory,
    this.selectedSizes = const [],
    this.selectedColors = const [],
    this.publishNow = false,
    this.startDate,
    this.endDate,
    this.imagePath,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.submitError,
    this.fieldErrors = const {},
  });

  ManageOfferState copyWith({
    DiscountType? discountType,
    Object? category = _sentinel,
    Object? subCategory = _sentinel,
    List<String>? selectedSizes,
    List<int>? selectedColors,
    bool? publishNow,
    Object? startDate = _sentinel,
    Object? endDate = _sentinel,
    Object? imagePath = _sentinel,
    bool? isSubmitting,
    bool? isSuccess,
    Object? submitError = _sentinel,
    Map<String, String>? fieldErrors,
  }) {
    return ManageOfferState(
      discountType: discountType ?? this.discountType,
      category: category == _sentinel ? this.category : category as String?,
      subCategory:
          subCategory == _sentinel ? this.subCategory : subCategory as String?,
      selectedSizes: selectedSizes ?? this.selectedSizes,
      selectedColors: selectedColors ?? this.selectedColors,
      publishNow: publishNow ?? this.publishNow,
      startDate: startDate == _sentinel ? this.startDate : startDate as DateTime?,
      endDate: endDate == _sentinel ? this.endDate : endDate as DateTime?,
      imagePath: imagePath == _sentinel ? this.imagePath : imagePath as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      submitError:
          submitError == _sentinel ? this.submitError : submitError as String?,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  static const _sentinel = Object();
}

// ── Field key constants ────────────────────────────────────────────────────
abstract class OfferField {
  static const title = 'title';
  static const description = 'description';
  static const originalPrice = 'originalPrice';
  static const discountedPrice = 'discountedPrice';
  static const category = 'category';
}

// ─────────────────────────────────────────────────────────────────────────────
// MANAGE OFFER CUBIT
// ─────────────────────────────────────────────────────────────────────────────

/// Handles all form state for create/edit offer.
/// Owns [TextEditingController] instances so the page stays StatelessWidget.
class ManageOfferCubit extends Cubit<ManageOfferState> {
  // ── Text controllers (owned here, disposed in close()) ─────────────────────
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController originalPriceController = TextEditingController();
  final TextEditingController discountedPriceController =
      TextEditingController();

  /// The offer being edited. Null = create mode.
  final OfferEntity? initialOffer;

  // ── Available options ──────────────────────────────────────────────────────
  static const List<int> availableColors = [
    0xFF8B5CF6, // purple
    0xFF3B82F6, // blue
    0xFF6B7280, // grey
    0xFF10B981, // green
    0xFF111827, // black
    0xFFEF4444, // red
    0xFFFFFFFF, // white
  ];

  static const List<String> availableSizes = [
    '4XL', '3XL', 'XXL', 'XL', 'L', 'M', 'S',
  ];

  static const List<String> categories = ['ملابس', 'أثاث', 'احذية'];
  static const List<String> subCategories = ['رجالي', 'حريمي', 'اطفالي'];

  // ── Constructor ────────────────────────────────────────────────────────────
  ManageOfferCubit({this.initialOffer})
      : super(ManageOfferState(
          discountType: initialOffer?.discountType ?? DiscountType.percentage,
          category: initialOffer?.category,
          subCategory: initialOffer?.subCategory,
          selectedSizes: List.from(initialOffer?.sizes ?? []),
          selectedColors: List.from(initialOffer?.colorValues ?? []),
          publishNow: initialOffer?.publishNow ?? false,
          startDate: initialOffer?.startDate,
          endDate: initialOffer?.endDate,
          imagePath: initialOffer?.imageUrl,
        )) {
    // Pre-fill text controllers for edit mode
    if (initialOffer != null) {
      titleController.text = initialOffer!.title;
      descriptionController.text = initialOffer!.description;
      originalPriceController.text =
          initialOffer!.originalPrice.toStringAsFixed(0);
      discountedPriceController.text =
          initialOffer!.discountedPrice.toStringAsFixed(0);
    }

    // Auto-update discount value when prices change
    originalPriceController.addListener(_onPriceChanged);
    discountedPriceController.addListener(_onPriceChanged);
  }

  // ── Price listener ─────────────────────────────────────────────────────────
  void _onPriceChanged() {
    // Trigger a state update so discount percent re-renders
    emit(state.copyWith());
  }

  // ── Computed ───────────────────────────────────────────────────────────────
  double get computedDiscountPercent {
    final orig = double.tryParse(originalPriceController.text) ?? 0;
    final disc = double.tryParse(discountedPriceController.text) ?? 0;
    if (orig <= 0) return 0;
    return ((orig - disc) / orig * 100).clamp(0, 100);
  }

  // ── Mutators ───────────────────────────────────────────────────────────────

  void setDiscountType(DiscountType type) =>
      emit(state.copyWith(discountType: type));

  void setCategory(String? value) =>
      emit(state.copyWith(category: value, subCategory: null));

  void setSubCategory(String? value) =>
      emit(state.copyWith(subCategory: value));

  void setPublishNow(bool value) => emit(state.copyWith(publishNow: value));

  void setStartDate(DateTime? date) => emit(state.copyWith(startDate: date));

  void setEndDate(DateTime? date) => emit(state.copyWith(endDate: date));

  void setImage(String? path) => emit(state.copyWith(imagePath: path));

  void toggleSize(String size) {
    final list = List<String>.from(state.selectedSizes);
    list.contains(size) ? list.remove(size) : list.add(size);
    emit(state.copyWith(selectedSizes: list));
  }

  void toggleColor(int colorValue) {
    final list = List<int>.from(state.selectedColors);
    list.contains(colorValue) ? list.remove(colorValue) : list.add(colorValue);
    emit(state.copyWith(selectedColors: list));
  }

  // ── Validation & Submit ────────────────────────────────────────────────────

  Future<void> submit() async {
    final errors = <String, String>{};

    if (titleController.text.trim().isEmpty) {
      errors[OfferField.title] = 'offer_title_required';
    }
    final orig = double.tryParse(originalPriceController.text);
    if (orig == null || orig <= 0) {
      errors[OfferField.originalPrice] = 'offer_price_invalid';
    }
    final disc = double.tryParse(discountedPriceController.text);
    if (disc == null || disc < 0) {
      errors[OfferField.discountedPrice] = 'offer_price_invalid';
    }
    if (state.category == null) {
      errors[OfferField.category] = 'offer_category_required';
    }

    if (errors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: errors, isSubmitting: false));
      return;
    }

    emit(state.copyWith(isSubmitting: true, fieldErrors: {}));
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    if (isClosed) return;

    emit(state.copyWith(isSubmitting: false, isSuccess: true));
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    originalPriceController.removeListener(_onPriceChanged);
    discountedPriceController.removeListener(_onPriceChanged);
    titleController.dispose();
    descriptionController.dispose();
    originalPriceController.dispose();
    discountedPriceController.dispose();
    return super.close();
  }
}
