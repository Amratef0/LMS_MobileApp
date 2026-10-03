import 'package:flutter/material.dart';

/// Ported 1:1 from `frontend/lms-frontend/src/styles.scss` (`:root { ... }`)
/// so the mobile app looks like the same product as the website.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primaryLight = Color(0xFFDBEAFE);

  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFDCFCE7);

  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFFEF3C7);

  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFFEE2E2);

  static const info = Color(0xFF0891B2);
  static const infoLight = Color(0xFFCFFAFE);

  static const bg = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const text = Color(0xFF1E293B);
  static const textMuted = Color(0xFF64748B);

  /// Maps session/ticket/quiz/assignment status strings from the API
  /// directly to a badge color, same logic as the Angular badge pipes.
  static Color forStatus(String status) {
    switch (status) {
      case 'finished':
      case 'resolved':
      case 'closed':
      case 'submitted':
      case 'graded':
        return success;
      case 'running':
      case 'in_progress':
      case 'pending':
        return warning;
      case 'cancelled':
      case 'missed':
      case 'reopened':
        return danger;
      default:
        return info;
    }
  }

  static Color lightForStatus(String status) {
    switch (status) {
      case 'finished':
      case 'resolved':
      case 'closed':
      case 'submitted':
      case 'graded':
        return successLight;
      case 'running':
      case 'in_progress':
      case 'pending':
        return warningLight;
      case 'cancelled':
      case 'missed':
      case 'reopened':
        return dangerLight;
      default:
        return infoLight;
    }
  }
}
