import 'package:intl/intl.dart';

class DateTimeFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  static String calculateDuration(DateTime startTime, DateTime? endTime) {
    final end = endTime ?? DateTime.now();
    final duration = end.difference(startTime);

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return '$hours hours, $minutes minutes';
  }
}
