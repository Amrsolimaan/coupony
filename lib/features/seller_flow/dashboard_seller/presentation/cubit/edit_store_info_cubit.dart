import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/update_store_profile_use_case.dart';
import 'edit_store_info_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EDIT STORE INFO CUBIT
// Owns exactly one responsibility: call UpdateStoreProfileUseCase and emit
// the resulting state.  All form state (text controllers, time pickers) lives
// in the StatefulWidget — this cubit is purely for the network interaction.
// ─────────────────────────────────────────────────────────────────────────────

class EditStoreInfoCubit extends Cubit<EditStoreInfoState> {
  final UpdateStoreProfileUseCase _updateStoreProfile;

  EditStoreInfoCubit({required UpdateStoreProfileUseCase updateStoreProfile})
      : _updateStoreProfile = updateStoreProfile,
        super(const EditStoreInfoInitial());

  Future<void> save(UpdateStoreProfileParams params) async {
    emit(const EditStoreInfoLoading());

    final result = await _updateStoreProfile(params);

    result.fold(
      (failure) => emit(EditStoreInfoError(failure.message)),
      (updatedStore) => emit(
        EditStoreInfoSuccess(
          updatedStore: updatedStore,
          message: 'تم تحديث بيانات المتجر بنجاح',
        ),
      ),
    );
  }
}
