import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow_flutter/core/services/otp_cooldown_service.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/otp_input.dart';
import 'package:taskflow_flutter/core/widgets/password_strength_meter.dart';

void main() {
  group('1. Country-Aware Phone Validation with phone_numbers_parser', () {
    test('Validates Indian phone numbers correctly', () {
      // Real 10 digits starting with 6-9 (not in sequential list)
      expect(Validators.validatePhoneNumber('9823456789', countryCode: '+91', isoCode: 'IN'), isNull);
      expect(Validators.validatePhoneNumber('5876543210', countryCode: '+91', isoCode: 'IN'),
          'Indian mobile numbers must start with 6, 7, 8, or 9.');
      expect(Validators.validatePhoneNumber('12345', countryCode: '+91', isoCode: 'IN'),
          'Please enter a valid 10-digit mobile number.');
      // Sequential numbers are rejected as test numbers (from TaskFlow-Mobile)
      expect(Validators.validatePhoneNumber('9876543210', countryCode: '+91', isoCode: 'IN'),
          'Please enter a valid mobile number.');
    });

    test('Validates US phone numbers correctly', () {
      // Valid US: 10 digits (e.g. 202-555-0143)
      expect(Validators.validatePhoneNumber('2025550143', countryCode: '+1', isoCode: 'US'), isNull);
      // Too short
      expect(Validators.validatePhoneNumber('12345', countryCode: '+1', isoCode: 'US'), isNotNull);
    });

    test('Validates international phone numbers correctly', () {
      // Valid Australian number (9 digits mobile: 412 345 678)
      expect(Validators.validatePhoneNumber('412345678', countryCode: '+61', isoCode: 'AU'), isNull);
      expect(Validators.validatePhoneNumber('123', countryCode: '+61', isoCode: 'AU'), isNotNull);
    });

    test('Handles optional phone number', () {
      expect(Validators.validatePhoneNumber('', isRequired: false), isNull);
      expect(Validators.validatePhoneNumber('', isRequired: true), 'Please enter your phone number.');
    });
  });

  group('2. Password Strength & Checklist Meter', () {
    test('Calculates score and checklist correctly', () {
      // Weak
      final weak = PasswordChecks.fromPassword('abc');
      expect(weak.score, 1);
      expect(weak.hasMinLength, false);
      expect(weak.hasUppercase, false);
      expect(weak.hasLowercase, true);

      // Strong: 8+ chars, upper, lower, number, special
      final strong = PasswordChecks.fromPassword('SuperP@ssw0rd!');
      expect(strong.score, 5);
      expect(strong.hasMinLength, true);
      expect(strong.hasUppercase, true);
      expect(strong.hasLowercase, true);
      expect(strong.hasNumber, true);
      expect(strong.hasSpecial, true);
      expect(strong.isAllMet, true);
    });

    testWidgets('PasswordStrengthMeter renders live checklist items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthMeter(password: 'Pass123!'),
          ),
        ),
      );

      expect(find.text('Strong'), findsOneWidget);
      expect(find.text('8+ characters'), findsOneWidget);
      expect(find.text('Uppercase letter'), findsOneWidget);
      expect(find.text('Lowercase letter'), findsOneWidget);
      expect(find.text('Number'), findsOneWidget);
      expect(find.text('Special character'), findsOneWidget);
    });
  });

  group('3. OTP Cooldown & Lockout Service', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Rehydrates initial clean state', () async {
      final notifier = OtpCooldownNotifier();
      await notifier.rehydrate('test@example.com');

      expect(notifier.state.attempts, 0);
      expect(notifier.state.countdown, 0);
      expect(notifier.state.isLockedOut, false);
      expect(notifier.state.remainingAttempts, 6);

      notifier.dispose();
    });

    test('Tracks failed attempts and locks out at 6 attempts for 600s', () async {
      final notifier = OtpCooldownNotifier();
      const target = 'lockout_test@example.com';
      await notifier.rehydrate(target);

      for (int i = 1; i <= 5; i++) {
        await notifier.recordFailedAttempt(target);
        expect(notifier.state.attempts, i);
        expect(notifier.state.isLockedOut, false);
        expect(notifier.state.remainingAttempts, 6 - i);
      }

      // 6th attempt triggers lockout
      await notifier.recordFailedAttempt(target);
      expect(notifier.state.attempts, 6);
      expect(notifier.state.isLockedOut, true);
      expect(notifier.state.lockoutRemaining, 600);
      expect(notifier.state.lockoutFormattedTime, '10:00');

      notifier.dispose();
    });

    test('Persists lockout and rehydrates across app sessions', () async {
      final notifier1 = OtpCooldownNotifier();
      const target = 'persistent@example.com';
      await notifier1.rehydrate(target);
      await notifier1.startLockout(durationSecs: 300, target: target);

      expect(notifier1.state.isLockedOut, true);
      notifier1.dispose();

      // Second instance simulating restart
      final notifier2 = OtpCooldownNotifier();
      await notifier2.rehydrate(target);
      expect(notifier2.state.isLockedOut, true);
      expect(notifier2.state.lockoutRemaining, greaterThan(290));
      notifier2.dispose();
    });

    test('Reset clears attempts and lockout on success', () async {
      final notifier = OtpCooldownNotifier();
      const target = 'success@example.com';
      await notifier.rehydrate(target);
      await notifier.recordFailedAttempt(target);
      await notifier.recordFailedAttempt(target);
      expect(notifier.state.attempts, 2);

      await notifier.resetAttempts(target);
      expect(notifier.state.attempts, 0);
      expect(notifier.state.isLockedOut, false);
      notifier.dispose();
    });
  });

  group('4. AppTextField Capitalization & Formatter Behavior', () {
    testWidgets('AppTextField defaults to TextCapitalization.none', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              maxLength: 30,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textCapitalization, TextCapitalization.none);
    });

    test('filterFirstName preserves typed casing without auto-capitalizing', () {
      // User typed 'mcDonald' or 'vanDerBilt' should not be forced uppercase
      expect(Validators.filterFirstName('mcDonald'), 'mcDonald');
      expect(Validators.filterFirstName('john'), 'john');
      expect(Validators.filterFirstName('JOHN'), 'JOHN');
      // Non-letters stripped
      expect(Validators.filterFirstName('John123!'), 'John');
    });
  });

  group('5. OtpInput Explicit Verification Behavior', () {
    testWidgets('Entering 6 digits triggers onCompleted without auto-submit', (tester) async {
      String completedOtp = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OtpInput(
              length: 6,
              onCompleted: (val) {
                completedOtp = val;
              },
            ),
          ),
        ),
      );

      // Verify 6 input boxes rendered
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(6));

      // Enter digits into each box
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '$i');
        await tester.pump();
      }

      expect(completedOtp, '012345');
    });
  });
}
