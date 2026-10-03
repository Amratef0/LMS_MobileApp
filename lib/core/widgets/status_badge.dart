import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Mirrors `.badge.badge-success/warning/danger/info` in styles.scss:
/// light tinted background + solid-colored text, pill shaped.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.forStatus(status);
    final bg = AppColors.lightForStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
