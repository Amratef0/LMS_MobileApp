import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Matches the site's `.spinner` — a simple centered circular indicator.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}
