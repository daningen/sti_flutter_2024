// validator.dart
class Validator {
  // Verifies that SSN is in format YYMMDD
  static final RegExp ssnFormat =
      RegExp(r'^\d{2}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$');

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

  // Checks if a given SSN matches the required format.
  static bool isValidSSN(String? ssn) {
    return ssn != null && ssnFormat.hasMatch(ssn);
  }
}
