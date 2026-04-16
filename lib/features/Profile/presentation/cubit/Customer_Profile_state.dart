import 'package:coupony/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';


// ════════════════════════════════════════════════════════
// PROFILE STATE
// ════════════════════════════════════════════════════════

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// No operation has started yet.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Fetching the profile from the remote source.
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile successfully loaded.
class ProfileLoaded extends ProfileState {
  final UserEntity user;
  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// An update request is in progress.
class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

/// Profile update completed successfully.
class ProfileUpdateSuccess extends ProfileState {
  final UserEntity user;
  const ProfileUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Account deletion completed — UI should navigate to login.
class ProfileDeleteSuccess extends ProfileState {
  const ProfileDeleteSuccess();
}

/// Logout completed successfully — UI should navigate to login.
class ProfileLogoutSuccess extends ProfileState {
  const ProfileLogoutSuccess();
}

/// An operation failed.
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
