import 'package:test/test.dart';
import 'package:cli/utils/validator.dart';

void main() {
  group('Validator Tests', () {
    test('should validate non-empty strings', () {
      expect(Validator.isString('Anna Jansson'), isTrue);
      expect(Validator.isString(''), isFalse);
    });

    test('should validate correct SSN format', () {
      expect(Validator.isValidSSN('720606'), isTrue);
      expect(Validator.isValidSSN('727272'), isFalse);
    });

    test('should validate if value is a number', () {
      expect(Validator.isNumber('123'), isTrue);
      expect(Validator.isNumber('abc'), isFalse);
    });
  });
}
