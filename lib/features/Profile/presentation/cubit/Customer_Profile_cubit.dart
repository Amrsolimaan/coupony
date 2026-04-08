import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:coupony/features/Profile/domain/use_cases/delete_account_use_case.dart';
import 'package:coupony/features/Profile/domain/use_cases/get_profile_use_case.dart';
import 'package:coupony/features/Profile/domain/use_cases/update_profile_params.dart';
import 'package:coupony/features/Profile/domain/use_cases/update_profile_use_case.dart';
import 'package:coupony/features/Profile/presentation/cubit/Customer_Profile_state.dart';


import '../../../../../core/errors/failures.dart';

// ════════════════════════════════════════════════════════
// PROFILE CUBIT
// ════════════════════════════════════════════════════════

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase    getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final Logger               logger;

  ProfileCubit({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.deleteAccountUseCase,
    required this.logger,
  }) : super(const ProfileInitial());

  void _safeEmit(ProfileState s) {
    if (!isClosed) emit(s);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FETCH PROFILE
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    logger.i('📥 ProfileCubit.loadProfile — fetching /auth/me');
    _safeEmit(const ProfileLoading());

    final result = await getProfileUseCase();

    result.fold(
      (failure) {
        logger.e('❌ loadProfile failed: ${failure.message}');
        _safeEmit(ProfileError(_mapFailure(failure)));
      },
      (user) {
        logger.i('✅ loadProfile success — ${user.email}');
        _safeEmit(ProfileLoaded(user));
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // UPDATE PROFILE
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> updateProfile(UpdateProfileParams params) async {
    logger.i('📤 ProfileCubit.updateProfile');
    _safeEmit(const ProfileUpdating());

    final result = await updateProfileUseCase(params);

    result.fold(
      (failure) {
        logger.e('❌ updateProfile failed: ${failure.message}');
        _safeEmit(ProfileError(_mapFailure(failure)));
      },
      (user) {
        logger.i('✅ updateProfile success — cache updated');
        _safeEmit(ProfileUpdateSuccess(user));
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DELETE ACCOUNT
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> deleteAccount(String password) async {
    logger.i('🗑️ ProfileCubit.deleteAccount');
    _safeEmit(const ProfileLoading());

    final result = await deleteAccountUseCase(password);

    result.fold(
      (failure) {
        logger.e('❌ deleteAccount failed: ${failure.message}');
        _safeEmit(ProfileError(_mapFailure(failure)));
      },
      (_) {
        logger.i('✅ deleteAccount success — local session cleared');
        _safeEmit(const ProfileDeleteSuccess());
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  String _mapFailure(Failure failure) {
    if (failure is NetworkFailure)     return 'error_no_internet';
    if (failure is UnauthorizedFailure) return 'error_unauthorized';
    if (failure is ValidationFailure)  return failure.message;
    if (failure is ServerFailure)      return failure.message;
    return 'error_unexpected';
  }
}
