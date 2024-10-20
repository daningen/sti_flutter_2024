// Function to generate a random SSN following the specified format from ssn_validator.dart
import 'dart:math';

import 'package:cli/utils/ssn_validator.dart';

String generateRandomSSN() {
  Random random = Random();

  // Generate a two-digit year (00-99)
  String year = random.nextInt(100).toString().padLeft(2, '0');

  // Generate a valid month (01-12)
  String month = (random.nextInt(12) + 1).toString().padLeft(2, '0');

  // Generate a valid day (01-31)
  String day = (random.nextInt(31) + 1).toString().padLeft(2, '0');

  // Combine to form SSN
  String ssn = '$year$month$day';

  // Ensure SSN matches the format defined in ssn_validator.dart
  if (ssnFormat.hasMatch(ssn)) {
    return ssn;
  } else {
    // Recursively generate a valid SSN if it doesn't match the format
    return generateRandomSSN();
  }
}
