import 'package:flutter/material.dart';
import '../widgets/feedback/app_snackbar.dart';

extension SnackBarExtension on BuildContext {
  void showSuccessSnackBar(String message, {Duration? duration}) {
    AppSnackBar.show(
      this,
      message: message,
      type: SnackBarType.success,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void showErrorSnackBar(String message, {Duration? duration}) {
    AppSnackBar.show(
      this,
      message: message,
      type: SnackBarType.error,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  void showWarningSnackBar(String message, {Duration? duration}) {
    AppSnackBar.show(
      this,
      message: message,
      type: SnackBarType.warning,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void showInfoSnackBar(String message, {Duration? duration}) {
    AppSnackBar.show(
      this,
      message: message,
      type: SnackBarType.info,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void showNetworkSlowSnackBar(String message, {Duration? duration}) {
    AppSnackBar.show(
      this,
      message: message,
      type: SnackBarType.networkSlow,
      duration: duration ?? const Duration(seconds: 5),
    );
  }
}
