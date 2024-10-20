import 'dart:math';

String generateRandomLicensePlate() {
  const letters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; // Uppercase letters for license plate
  const numbers = '0123456789'; // Digits for license plate

  Random random = Random();

  // Generate 3 random letters
  String randomLetters =
      List.generate(3, (index) => letters[random.nextInt(letters.length)])
          .join('');

  // Generate 3 random digits
  String randomDigits =
      List.generate(3, (index) => numbers[random.nextInt(numbers.length)])
          .join('');

  // Concatenate letters and digits to form a license plate
  return '$randomLetters$randomDigits';
}
