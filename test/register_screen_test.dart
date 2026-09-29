import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/storage/storage_service.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/auth/presentation/screens/register_screen.dart';
import 'package:taskflow_flutter/features/auth/presentation/screens/login_screen.dart';

class _FakeStorageService implements StorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  bool getRememberMe() => false;

  @override
  String? getRememberedEmail() => null;
}

void main() {
  group('Register Form Validations & Real-Time Filtering', () {
    test('filterFirstName strips non-letters, spaces, and symbols', () {
      expect(Validators.filterFirstName('John123!'), equals('John'));
      expect(Validators.filterFirstName('kdmfc ksmdksdma n'), equals('kdmfcksmdksdman'));
      expect(Validators.filterFirstName('Jane-Doe'), equals('JaneDoe'));
    });

    test('filterLastName strips disallowed characters, leading spaces, double spaces', () {
      expect(Validators.filterLastName('  Smith--'), equals('Smith--'));
      expect(Validators.filterLastName('van   der  Bilt'), equals('van der Bilt'));
      expect(Validators.filterLastName("O'Connor123"), equals("O'Connor"));
    });

    test('validateDob enforces minimum age of 13 years (COPPA)', () {
      // Future date
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final futureStr = '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
      expect(Validators.validateDob(futureStr), equals('Date of birth cannot be in the future.'));

      // Under 13 years old
      final childDate = DateTime.now().subtract(const Duration(days: 365 * 10));
      final childStr = '${childDate.year}-${childDate.month.toString().padLeft(2, '0')}-${childDate.day.toString().padLeft(2, '0')}';
      expect(Validators.validateDob(childStr), equals('You must be at least 13 years old to register.'));

      // Valid adult date (25 years ago)
      final adultDate = DateTime.now().subtract(const Duration(days: 365 * 25));
      final adultStr = '${adultDate.year}-${adultDate.month.toString().padLeft(2, '0')}-${adultDate.day.toString().padLeft(2, '0')}';
      expect(Validators.validateDob(adultStr), isNull);
    });

    test('validateEmail validates email format strictly matching React Native', () {
      expect(Validators.validateEmail(''), equals('Please enter your email address.'));
      expect(Validators.validateEmail('nsdad sjndba834e'), isNotNull);
      expect(Validators.validateEmail('john..doe@example.com'), contains('consecutive dots'));
      expect(Validators.validateEmail('john@example..com'), equals('Please enter a valid email address (e.g. name@example.com)'));
      expect(Validators.validateEmail('user@gmail.co'), contains('Please use @gmail.com'));
      expect(Validators.validateEmail('valid.user@company.com'), isNull);
    });

    test('validateRegisterPassword requires 8+ chars, upper, lower, digit, special, no spaces', () {
      expect(Validators.validateRegisterPassword(''), contains('at least 8 characters'));
      expect(Validators.validateRegisterPassword('short1!A'), isNull);
      expect(Validators.validateRegisterPassword('lowercase1!'), contains('uppercase'));
      expect(Validators.validateRegisterPassword('UPPERCASE1!'), contains('lowercase'));
      expect(Validators.validateRegisterPassword('NoDigitsHere!'), contains('number'));
      expect(Validators.validateRegisterPassword('NoSpecial1234'), contains('special character'));
      expect(Validators.validateRegisterPassword('Pass 1234!'), contains('does not contain spaces'));
      expect(Validators.validateRegisterPassword('JaneSecret123!', firstName: 'Jane'), contains('should not contain your first name'));
    });
  });

  group('RegisterScreen Widget Tests', () {
    testWidgets('renders all registration fields and applies real-time filtering on First Name', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsNWidgets(2));
      bool hasLabel(String text) => find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains(text),
      ).evaluate().isNotEmpty;

      expect(hasLabel('First Name'), isTrue);
      expect(hasLabel('Last Name'), isTrue);
      expect(hasLabel('Work Email Address'), isTrue);
      expect(hasLabel('Phone Number'), isTrue);
      expect(hasLabel('Date of Birth'), isTrue);
      expect(hasLabel('Password'), isTrue);
      expect(hasLabel('Confirm Password'), isTrue);

      // Enter invalid characters into First Name (spaces and numbers)
      final firstNameField = find.widgetWithText(TextField, 'John');
      expect(firstNameField, findsOneWidget);

      await tester.enterText(firstNameField, 'Jane 123 !');
      await tester.pump();

      // Real-time filtering should immediately strip spaces, numbers, and symbols
      final TextField firstNameWidget = tester.widget(firstNameField);
      expect(firstNameWidget.controller?.text, equals('Jane'));
    });

    testWidgets('onBlur triggers validation errors when leaving fields empty or invalid', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter a single letter into First Name then blur by tapping Email
      final firstNameField = find.widgetWithText(TextField, 'John');
      await tester.enterText(firstNameField, 'J');
      await tester.pump();

      final emailField = find.widgetWithText(TextField, 'john.doe@company.com');
      await tester.tap(emailField);
      await tester.pumpAndSettle();

      expect(find.text('First name must be at least 2 characters.'), findsOneWidget);
    });

    testWidgets('RegisterScreen: tapping First Name and leaving empty triggers polite error on blur', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Focus First Name
      final firstNameField = find.widgetWithText(TextField, 'John');
      await tester.tap(firstNameField);
      await tester.pump();

      // Blur by tapping Work Email
      final emailField = find.widgetWithText(TextField, 'john.doe@company.com');
      await tester.tap(emailField);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your first name.'), findsOneWidget);
    });

    testWidgets('LoginScreen: tapping Email and leaving empty triggers polite error on blur', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(_FakeStorageService()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Email (first TextField)
      final emailField = find.byType(TextField).at(0);
      await tester.tap(emailField);
      await tester.pump();

      // Tap Password (second TextField) to blur Email
      final passwordField = find.byType(TextField).at(1);
      await tester.tap(passwordField);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address.'), findsOneWidget);
    });

    testWidgets('LoginScreen: tapping Password and leaving empty triggers polite error on blur', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(_FakeStorageService()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Password (second TextField)
      final passwordField = find.byType(TextField).at(1);
      await tester.tap(passwordField);
      await tester.pump();

      // Tap Email to blur Password
      final emailField = find.byType(TextField).at(0);
      await tester.tap(emailField);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password.'), findsOneWidget);
    });
  });
}
