import 'package:coupony/core/constants/api_constants.dart';
import 'package:coupony/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

part 'change_password_state.dart';

// ════════════════════════════════════════════════════════
// CHANGE PASSWORD CUBIT
// ════════════════════════════════════════════════════════

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final DioClient client;
  final Logger logger;

  ChangePasswordCubit({
    required this.client,
    required this.logger,
  }) : super(ChangePasswordInitial());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(ChangePasswordLoading());
    try {
      logger.i('🔑 POST CHANGE PASSWORD — ${ApiConstants.changePassword}');

      await client.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      logger.i('✅ CHANGE PASSWORD SUCCESS');
      emit(ChangePasswordSuccess());
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      logger.e('❌ CHANGE PASSWORD ERROR: $statusCode — ${e.response?.data}');

      if (statusCode == 422 || statusCode == 401 || statusCode == 400) {
        emit(ChangePasswordError(
          message: 'change_password_current_error',
          isCurrentPasswordWrong: true,
        ));
      } else {
        emit(ChangePasswordError(message: 'error_unexpected'));
      }
    } catch (e) {
      logger.e('❌ CHANGE PASSWORD UNEXPECTED: $e');
      emit(ChangePasswordError(message: 'error_unexpected'));
    }
  }
}
