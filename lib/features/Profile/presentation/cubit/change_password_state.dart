part of 'change_password_cubit.dart';

// ════════════════════════════════════════════════════════
// CHANGE PASSWORD STATES
// ════════════════════════════════════════════════════════

abstract class ChangePasswordState {}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordLoading extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {}

class ChangePasswordError extends ChangePasswordState {
  final String message;
  final bool isCurrentPasswordWrong;

  ChangePasswordError({
    required this.message,
    this.isCurrentPasswordWrong = false,
  });
}
