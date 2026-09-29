import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/app_textarea.dart';

void main() {
  group('Profile Validators & Filter tests', () {
    test('filterFirstName strips non-alphabet characters', () {
      expect(Validators.filterFirstName('John123!'), 'John');
      expect(Validators.filterFirstName('Alice-Bob'), 'AliceBob');
      expect(Validators.filterFirstName('Sarah'), 'Sarah');
    });

    test('filterLastName allows letters, spaces, hyphens, and apostrophes', () {
      expect(Validators.filterLastName("O'Connor 123"), "O'Connor ");
      expect(Validators.filterLastName('Smith-Jones'), 'Smith-Jones');
    });

    test('validateFirstName checks minimum length and letter constraint', () {
      expect(Validators.validateFirstName(''), 'Please enter your first name.');
      expect(Validators.validateFirstName('A'), 'First name must be at least 2 characters.');
      expect(Validators.validateFirstName('Alice'), isNull);
    });

    test('validateLastName checks minimum length', () {
      expect(Validators.validateLastName(''), 'Please enter your last name.');
      expect(Validators.validateLastName('D'), 'Last name must be at least 2 characters.');
      expect(Validators.validateLastName('Doe'), isNull);
    });

    test('validatePhoneNumber validates Indian and international numbers', () {
      expect(Validators.validatePhoneNumber('', isRequired: true), 'Please enter your phone number.');
      expect(Validators.validatePhoneNumber('9823456789', countryCode: '+91'), isNull);
      expect(Validators.validatePhoneNumber('123', countryCode: '+91'), 'Please enter a valid 10-digit mobile number.');
      expect(Validators.validatePhoneNumber('1111111111', countryCode: '+91'), 'Please enter a valid mobile number.');
    });

    test('validateBio allows up to 500 characters', () {
      expect(Validators.validateBio('Software engineer with passion for UI'), isNull);
      final longBio = 'a' * 501;
      expect(Validators.validateBio(longBio), 'Bio cannot exceed 500 characters.');
    });
  });

  group('Field onBlur callback tests', () {
    testWidgets('AppTextField triggers onBlur callback on focus loss', (WidgetTester tester) async {
      bool blurred = false;
      final focusNode1 = FocusNode();
      final focusNode2 = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppTextField(
                  label: 'Field 1',
                  focusNode: focusNode1,
                  onBlur: () {
                    blurred = true;
                  },
                ),
                AppTextField(
                  label: 'Field 2',
                  focusNode: focusNode2,
                ),
              ],
            ),
          ),
        ),
      );

      focusNode1.requestFocus();
      await tester.pump();
      expect(blurred, isFalse);

      focusNode2.requestFocus();
      await tester.pump();
      expect(blurred, isTrue);
    });

    testWidgets('AppTextarea triggers onBlur callback on focus loss', (WidgetTester tester) async {
      bool blurred = false;
      final focusNode2 = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppTextarea(
                  label: 'Bio',
                  onBlur: () {
                    blurred = true;
                  },
                ),
                TextField(
                  focusNode: focusNode2,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      expect(blurred, isFalse);

      focusNode2.requestFocus();
      await tester.pump();
      expect(blurred, isTrue);
    });
  });
}
