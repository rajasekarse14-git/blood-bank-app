import 'package:flutter_test/flutter_test.dart';
import 'package:hemolife/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateName accepts valid names and rejects invalid names', () {
      expect(Validators.validateName('John Doe'), isNull);
      expect(Validators.validateName('A'), isNotNull);
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName(null), isNotNull);
    });

    test('validateAge enforces WHO donor eligibility between 18 and 65', () {
      // Eligible ages
      expect(Validators.validateAge('18'), isNull);
      expect(Validators.validateAge('30'), isNull);
      expect(Validators.validateAge('65'), isNull);

      // Ineligible ages
      expect(Validators.validateAge('17'), 'Donors must be at least 18 years old.');
      expect(Validators.validateAge('10'), 'Donors must be at least 18 years old.');
      expect(Validators.validateAge('66'), 'Donors must be 65 years or younger.');
      expect(Validators.validateAge('80'), 'Donors must be 65 years or younger.');

      // Invalid input
      expect(Validators.validateAge(''), isNotNull);
      expect(Validators.validateAge('abc'), isNotNull);
      expect(Validators.validateAge(null), isNotNull);
    });

    test('validatePhone enforces exactly 10 digits', () {
      expect(Validators.validatePhone('9876543210'), isNull);
      expect(Validators.validatePhone('98765 43210'), isNull);
      expect(Validators.validatePhone('12345'), isNotNull);
      expect(Validators.validatePhone('9876543210123'), isNotNull);
      expect(Validators.validatePhone('abcdefghij'), isNotNull);
      expect(Validators.validatePhone(null), isNotNull);
    });

    test('validateHospital ensures minimum 3 characters', () {
      expect(Validators.validateHospital('Apollo Hospital'), isNull);
      expect(Validators.validateHospital('AI'), isNotNull);
      expect(Validators.validateHospital(''), isNotNull);
      expect(Validators.validateHospital(null), isNotNull);
    });

    test('validateBloodGroup checks valid blood types', () {
      expect(Validators.validateBloodGroup('A+'), isNull);
      expect(Validators.validateBloodGroup('O-'), isNull);
      expect(Validators.validateBloodGroup('AB+'), isNull);
      expect(Validators.validateBloodGroup('C+'), isNotNull);
      expect(Validators.validateBloodGroup(''), isNotNull);
      expect(Validators.validateBloodGroup(null), isNotNull);
    });

    test('validateQuantity checks range 1 to 20', () {
      expect(Validators.validateQuantity(1), isNull);
      expect(Validators.validateQuantity(5), isNull);
      expect(Validators.validateQuantity(20), isNull);
      expect(Validators.validateQuantity(0), isNotNull);
      expect(Validators.validateQuantity(-1), isNotNull);
      expect(Validators.validateQuantity(25), isNotNull);
    });
  });
}
