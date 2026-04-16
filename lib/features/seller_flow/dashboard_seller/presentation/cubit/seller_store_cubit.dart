import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_store_display_use_case.dart';
import 'seller_store_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER STORE CUBIT
// ─────────────────────────────────────────────────────────────────────────────

class SellerStoreCubit extends Cubit<SellerStoreState> {
  final GetStoreDisplayUseCase getStoreDisplayUseCase;

  SellerStoreCubit({
    required this.getStoreDisplayUseCase,
    bool isGuest = false,
    bool isPending = false,
  }) : super(SellerStoreInitial(
          isGuest: isGuest,
          isPending: isPending,
        )) {
    if (isGuest) {
      emit(const SellerStoreGuest());
    } else if (isPending) {
      emit(const SellerStorePending());
    } else {
      loadStoreDisplay();
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches store display data from API via use case.
  /// Emits [SellerStoreLoading] → [SellerStoreDataLoaded] or [SellerStoreError]
  Future<void> loadStoreDisplay() async {
    // ✅ Guard: Skip API call if in guest/pending mode
    if (state is SellerStoreGuest || state is SellerStorePending) {
      return;
    }
    
    emit(const SellerStoreLoading());

    final result = await getStoreDisplayUseCase();

    if (isClosed) return;

    result.fold(
      (failure) => emit(SellerStoreError(_mapFailureToMessage(failure))),
      (store) => emit(SellerStoreDataLoaded(store)),
    );
  }

  /// Switches the active tab. Only valid when state is [SellerStoreDataLoaded].
  void changeTab(int index) {
    if (state is SellerStoreDataLoaded) {
      final current = state as SellerStoreDataLoaded;
      emit(SellerStoreDataLoaded(current.store, activeTabIndex: index));
    }
  }

  // ── Helper Methods ─────────────────────────────────────────────────────────

  /// Maps failure types to user-friendly error messages.
  /// TODO: Add localization support
  String _mapFailureToMessage(dynamic failure) {
    final failureStr = failure.toString().toLowerCase();

    if (failureStr.contains('network') || failureStr.contains('internet')) {
      return 'لا يوجد اتصال بالإنترنت. تحقق من الاتصال وحاول مرة أخرى.';
    } else if (failureStr.contains('no stores found')) {
      return 'لم يتم العثور على متجر مرتبط بحسابك.';
    } else if (failureStr.contains('unauthorized')) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    }

    return 'حدث خطأ أثناء تحميل بيانات المتجر. حاول مرة أخرى.';
  }
}
