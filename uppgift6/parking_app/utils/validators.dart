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

    // Validate YYMMDD
    try {
      // ignore: unused_local_variable
      final year = int.parse('20${value.substring(0, 2)}');
      final month = int.parse(value.substring(2, 4));
      final day = int.parse(value.substring(4, 6));

      if (month < 1 || month > 12) return 'Invalid month';

      if (day < 1 || day > 31) {
        return 'Day must be between 01 and 31';
      }
    } catch (e) {
      return 'Invalid SSN format';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
      return 'Address must start with a letter';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = int.tryParse(value);
    if (price == null) {
      return 'Invalid price';
    }
    if (price < 10 || price > 100) {
      return 'Price must be between 10 and 100';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }
}
