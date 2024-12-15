// utils/validators.dart

class Validators {
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
    return null;
  }
}
