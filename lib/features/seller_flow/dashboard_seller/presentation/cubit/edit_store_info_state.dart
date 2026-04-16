import 'package:equatable/equatable.dart';

import '../../domain/entities/store_display_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EDIT STORE INFO — STATES
// ─────────────────────────────────────────────────────────────────────────────

abstract class EditStoreInfoState extends Equatable {
  const EditStoreInfoState();

  @override
  List<Object?> get props => [];
}

class EditStoreInfoInitial extends EditStoreInfoState {
  const EditStoreInfoInitial();
}

class EditStoreInfoLoading extends EditStoreInfoState {
  const EditStoreInfoLoading();
}

class EditStoreInfoSuccess extends EditStoreInfoState {
  final StoreDisplayEntity updatedStore;
  final String message;

  const EditStoreInfoSuccess({
    required this.updatedStore,
    required this.message,
  });

  @override
  List<Object?> get props => [updatedStore, message];
}

class EditStoreInfoError extends EditStoreInfoState {
  final String message;
  const EditStoreInfoError(this.message);

  @override
  List<Object?> get props => [message];
}
