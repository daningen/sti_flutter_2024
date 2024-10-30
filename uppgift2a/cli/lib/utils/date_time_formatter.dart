// lib/utils/date_time_formatter.dart

import 'package:intl/intl.dart';

class DateTimeFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}
