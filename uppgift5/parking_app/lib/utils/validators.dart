// utils/validators.dart

class Validators {

   static String? validateLicensePlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'License plate is required';
    }
    if (!RegExp(r'^[A-Za-z]{3}[0-9]{3}$').hasMatch(value)) {
      return 'Format: ABC123';
    }
    return null;
  }
  
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return 'Name cannot contain numbers';
    }
    return null;
  }

  static String? validateSSN(String? value) {
    if (value == null || value.isEmpty) {
      return 'SSN is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'SSN must be in YYMMDD format';
    }

    // Validate YYMMDD components
    final year = int.tryParse(value.substring(0, 2));
    final month = int.tryParse(value.substring(2, 4));
    final day = int.tryParse(value.substring(4, 6));

    if (year == null || month == null || day == null) {
      return 'Invalid SSN format';
    }
    if (month < 1 || month > 12) {
      return 'Month must be between 01 and 12';
    }
    if (day < 1 || day > 31) {
      return 'Day must be between 01 and 31';
    }

    return null;
  }
}
