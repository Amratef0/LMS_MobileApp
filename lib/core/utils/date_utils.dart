import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String date(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('d MMM yyyy').format(d.toLocal());
  }

  static String dateTime(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('d MMM yyyy • h:mm a').format(d.toLocal());
  }

  static String time(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('h:mm a').format(d.toLocal());
  }

  /// e.g. "3 days left" / "Past due"
  static String dueLabel(DateTime? due) {
    if (due == null) return '';
    final now = DateTime.now();
    final diff = due.toLocal().difference(now);
    if (diff.isNegative) return 'Past due';
    if (diff.inDays >= 1) return '${diff.inDays}d left';
    if (diff.inHours >= 1) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }

  static bool isPast(DateTime? d) =>
      d != null && d.toLocal().isBefore(DateTime.now());
}
