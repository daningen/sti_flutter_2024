// lib/utils/validator.dart

class Validator {
  // Checks if a string is non-empty and non-null.
  static bool isString(String? input) {
    return input != null && input.trim().isNotEmpty;
  }

  // Checks if the input can be parsed as an integer and is within the list range.
  static bool isIndex(String? input, List list) {
    if (input == null) return false;
    final int? index = int.tryParse(input);
    return index != null && index > 0 && index <= list.length;
  }

  // Checks if a string represents a valid SSN (basic example).
  static bool isValidSSN(String? ssn) {
    // Add your own logic for validating the SSN format.
    return ssn != null && ssn.length == 10; // Example: expecting a 10-digit SSN
  }
}
