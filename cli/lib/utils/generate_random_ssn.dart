// Function to generate a random SSN following the specified format from ssn_validator.dart
import 'dart:math';

import 'package:cli/utils/ssn_validator.dart';

String generateRandomSSN() {
  Random random = Random();

  // År (00-99)
  String year = random.nextInt(100).toString().padLeft(2, '0');

  // Månad (01-12)
  String month = (random.nextInt(12) + 1).toString().padLeft(2, '0');

  // Dag (01-31)
  String day = (random.nextInt(31) + 1).toString().padLeft(2, '0');

  // konkatinera
  String ssn = '$year$month$day';

  // validera format
  if (ssnFormat.hasMatch(ssn)) {
    return ssn;
  } else {
    return generateRandomSSN();
  }
}
