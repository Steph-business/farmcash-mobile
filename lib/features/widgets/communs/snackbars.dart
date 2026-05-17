import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Helpers de snackbar — sobres, sans icône colorée prononcée.
class Snackbars {
  Snackbars._();

  static void showSucces(BuildContext context, String message) {
    _show(context, message, AppColors.success);
  }

  static void showErreur(BuildContext context, String message) {
    _show(context, message, AppColors.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppColors.text);
  }

  static void _show(BuildContext context, String message, Color background) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
