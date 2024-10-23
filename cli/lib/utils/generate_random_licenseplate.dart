import 'dart:math';

String generateRandomLicensePlate() {
  const letters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; // Uppercase letters for license plate
  const numbers = '0123456789'; // Digits for license plate

  Random random = Random();

  // Generera 3 random boksäver
  String randomLetters =
      List.generate(3, (index) => letters[random.nextInt(letters.length)])
          .join('');

  // Generera 3 random siffror
  String randomDigits =
      List.generate(3, (index) => numbers[random.nextInt(numbers.length)])
          .join('');

  // konkatenera
  return '$randomLetters$randomDigits';
}
