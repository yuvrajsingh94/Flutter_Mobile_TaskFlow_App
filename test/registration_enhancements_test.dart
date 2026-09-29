import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_flutter/core/utils/name_input_formatter.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';

void main() {
  group('NameInputFormatter Tests', () {
    const lastNameFormatter = NameInputFormatter(allowSpaces: true);
    const firstNameFormatter = NameInputFormatter(allowSpaces: false);

    test('Auto-capitalizes first letter of single words (Title Case)', () {
      final res1 = firstNameFormatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: 'john',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      expect(res1.text, equals('John'));
      expect(res1.selection.baseOffset, equals(4));

      final res2 = lastNameFormatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: 'doe',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(res2.text, equals('Doe'));
      expect(res2.selection.baseOffset, equals(3));
    });

    test('Auto-capitalizes multiple words (Mary Jane, John Doe)', () {
      final res = lastNameFormatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: 'mary jane',
          selection: TextSelection.collapsed(offset: 9),
        ),
      );
      expect(res.text, equals('Mary Jane'));
      expect(res.selection.baseOffset, equals(9));
    });

    test('Auto-capitalizes compound and hyphenated names (Smith-Jones, O\'Connor)', () {
      final resHyphen = lastNameFormatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: 'smith-jones',
          selection: TextSelection.collapsed(offset: 11),
        ),
      );
      expect(resHyphen.text, equals('Smith-Jones'));
      expect(resHyphen.selection.baseOffset, equals(11));

      final resApos = lastNameFormatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: "o'connor",
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
      expect(resApos.text, equals("O'Connor"));
      expect(resApos.selection.baseOffset, equals(8));
    });

    test('Prevents leading spaces without erasing text', () {
      final res = lastNameFormatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '   smith',
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
      expect(res.text, equals('Smith'));
      expect(res.selection.baseOffset, equals(5));
    });

    test('Typing multiple spaces collapses to single space and NEVER deletes preceding characters', () {
      // Step 1: User types 'Smith'
      var value = lastNameFormatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'smith', selection: TextSelection.collapsed(offset: 5)),
      );
      expect(value.text, equals('Smith'));
      expect(value.selection.baseOffset, equals(5));

      // Step 2: User presses space once -> 'Smith '
      var oldValue = value;
      value = lastNameFormatter.formatEditUpdate(
        oldValue,
        const TextEditingValue(text: 'Smith ', selection: TextSelection.collapsed(offset: 6)),
      );
      expect(value.text, equals('Smith '));
      expect(value.selection.baseOffset, equals(6));

      // Step 3: User presses space a SECOND time -> 'Smith  '
      // This MUST NOT delete preceding characters or behave like backspace!
      oldValue = value;
      value = lastNameFormatter.formatEditUpdate(
        oldValue,
        const TextEditingValue(text: 'Smith  ', selection: TextSelection.collapsed(offset: 7)),
      );
      expect(value.text, equals('Smith '));
      expect(value.selection.baseOffset, equals(6)); // Still at offset 6!

      // Step 4: User presses space a THIRD time -> 'Smith   '
      oldValue = value;
      value = lastNameFormatter.formatEditUpdate(
        oldValue,
        const TextEditingValue(text: 'Smith   ', selection: TextSelection.collapsed(offset: 7)),
      );
      expect(value.text, equals('Smith '));
      expect(value.selection.baseOffset, equals(6));

      // Step 5: User types 'j' -> 'Smith j'
      oldValue = value;
      value = lastNameFormatter.formatEditUpdate(
        oldValue,
        const TextEditingValue(text: 'Smith j', selection: TextSelection.collapsed(offset: 7)),
      );
      expect(value.text, equals('Smith J'));
      expect(value.selection.baseOffset, equals(7));
    });

    test('Strips disallowed characters in First Name and Last Name', () {
      // First Name strips numbers, spaces, symbols
      final resFirst = firstNameFormatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'Jane 123 !@#', selection: TextSelection.collapsed(offset: 12)),
      );
      expect(resFirst.text, equals('Jane'));
      expect(resFirst.selection.baseOffset, equals(4));

      // Last Name allows hyphens, apostrophes, and spaces, strips numbers and symbols
      final resLast = lastNameFormatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: "O'Connor 123!", selection: TextSelection.collapsed(offset: 13)),
      );
      expect(resLast.text, equals("O'Connor "));
      expect(resLast.selection.baseOffset, equals(9));
    });
  });

  group('Dynamic Country-Aware Phone Validation & Lengths', () {
    test('Reads dynamic phone lengths from ITU metadata for any country', () {
      final inLengths = Validators.getCountryPhoneLengths('IN');
      expect(inLengths.min, equals(10));
      expect(inLengths.max, equals(10));

      final usLengths = Validators.getCountryPhoneLengths('US');
      expect(usLengths.min, equals(10));
      expect(usLengths.max, equals(10));

      final auLengths = Validators.getCountryPhoneLengths('AU');
      expect(auLengths.min, equals(9));
      expect(auLengths.max, equals(9));

      final gbLengths = Validators.getCountryPhoneLengths('GB');
      expect(gbLengths.min, equals(9));
      expect(gbLengths.max, equals(10));
    });

    test('Returns invalid phone message on malformed numbers', () {
      expect(Validators.validatePhoneNumber('12345', countryCode: '+1', isoCode: 'US'),
          equals('Please enter a valid phone number.'));
      expect(Validators.validatePhoneNumber('abc', countryCode: '+91', isoCode: 'IN'),
          equals('Please enter a valid phone number.'));
    });
  });
}
