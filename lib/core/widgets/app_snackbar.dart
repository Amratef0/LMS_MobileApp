import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.danger);
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                color == AppColors.success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color == AppColors.success
              ? AppColors.success
              : AppColors.danger,
        ),
      );
  }
}
