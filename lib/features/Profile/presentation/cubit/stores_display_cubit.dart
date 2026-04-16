import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../seller_flow/CreateStore/domain/use_cases/get_stores_use_case.dart';
import '../../../auth/data/models/user_store_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STORES DISPLAY CUBIT
//
// Manages the display of seller stores in the profile page with smart caching.
// Cache expires after 5 minutes to balance freshness and performance.
// Also tracks the currently selected store ID for the smart store cards.
// ─────────────────────────────────────────────────────────────────────────────

class StoresDisplayCubit extends Cubit<StoresDisplayState> {
  final GetStoresUseCase _getStoresUseCase;
  final AuthLocalDataSource _authLocalDs;

  // Cache management
  List<UserStoreModel>? _cachedStores;
  DateTime? _cacheTimestamp;
  static const _cacheDuration = Duration(minutes: 5);

  StoresDisplayCubit(this._getStoresUseCase, this._authLocalDs)
      : super(StoresDisplayInitial());

  // ── Load Stores with Smart Caching ────────────────────────────────────────
  Future<void> loadStores({bool forceRefresh = false}) async {
    final selectedStoreId = await _authLocalDs.getSelectedStoreId();

    // Check if cache is valid
    if (!forceRefresh && _isCacheValid()) {
      emit(StoresDisplayLoaded(_cachedStores!, selectedStoreId: selectedStoreId));
      return;
    }

    emit(StoresDisplayLoading());

    final result = await _getStoresUseCase();

    result.fold(
      (failure) => emit(StoresDisplayError(failure.message)),
      (stores) {
        _cachedStores = stores;
        _cacheTimestamp = DateTime.now();
        emit(StoresDisplayLoaded(stores, selectedStoreId: selectedStoreId));
      },
    );
  }

  // ── Select a Store ────────────────────────────────────────────────────────
  // Persists the selection and re-emits state so cards update immediately.
  Future<void> selectStore(String storeId) async {
    await _authLocalDs.saveSelectedStoreId(storeId);
    if (state is StoresDisplayLoaded) {
      final current = state as StoresDisplayLoaded;
      emit(StoresDisplayLoaded(current.stores, selectedStoreId: storeId));
    }
  }

  // ── Check Cache Validity ───────────────────────────────────────────────────
  bool _isCacheValid() {
    if (_cachedStores == null || _cacheTimestamp == null) {
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(_cacheTimestamp!);
    return difference < _cacheDuration;
  }

  // ── Clear Cache ────────────────────────────────────────────────────────────
  void clearCache() {
    _cachedStores = null;
    _cacheTimestamp = null;
  }

  // ── Refresh Stores (Force) ─────────────────────────────────────────────────
  Future<void> refreshStores() async {
    await loadStores(forceRefresh: true);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORES DISPLAY STATE
// ─────────────────────────────────────────────────────────────────────────────

abstract class StoresDisplayState {}

class StoresDisplayInitial extends StoresDisplayState {}

class StoresDisplayLoading extends StoresDisplayState {}

class StoresDisplayLoaded extends StoresDisplayState {
  final List<UserStoreModel> stores;
  final String? selectedStoreId;

  StoresDisplayLoaded(this.stores, {this.selectedStoreId});
}

class StoresDisplayError extends StoresDisplayState {
  final String message;

  StoresDisplayError(this.message);
}
