import 'package:intl/intl.dart';

class Validator {
  // Checks if a nullable string can be parsed into a number.
  static bool isNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }
    return num.tryParse(value) != null;
  }

  // Checks if a nullable string is not null and not empty.
  static bool isString(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  // Checks if a given value can be used as an index for the provided list.
  // The value must be a number and within the bounds of the list (1-based).
  static bool isIndex(String? value, Iterable list) {
    if (!isNumber(value)) {
      return false;
    }
    final index = int.parse(value!.trim());
    return index >= 1 && index <= list.length;
  }

  // Checks if a string matches the SSN format "YYMMDD" with valid ranges.
  static bool isSSN(String? value) {
    final ssnFormat = RegExp(r'^\d{2}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$');
    return value != null && ssnFormat.hasMatch(value);
  }

  // Formats a DateTime to 'yyyy-MM-dd HH:mm'.
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }
}
