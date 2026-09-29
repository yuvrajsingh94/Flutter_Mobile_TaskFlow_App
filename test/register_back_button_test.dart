import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/features/auth/presentation/screens/register_screen.dart';

void main() {
  group('RegisterScreen Android Back Button & Keyboard Lifecycle Tests', () {
    testWidgets('1. Keyboard open: First Back press dismisses keyboard and retains all Signup form data',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('Go to Register'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to RegisterScreen
      await tester.tap(find.text('Go to Register'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Enter data into fields
      final firstNameField = find.widgetWithText(TextField, 'John');
      final lastNameField = find.widgetWithText(TextField, 'Doe');
      final emailField = find.widgetWithText(TextField, 'john.doe@company.com');

      await tester.enterText(firstNameField, 'Alice');
      await tester.enterText(lastNameField, 'Johnson');
      await tester.enterText(emailField, 'alice.johnson@company.com');
      await tester.pump();

      // Simulate keyboard open
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();

      // Verify PopScope has canPop == false when keyboard is visible
      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsOneWidget);
      final PopScope popScope = tester.widget(popScopeFinder);
      expect(popScope.canPop, isFalse);

      // Trigger first system back press (Android back button)
      final bool handled = await tester.binding.handlePopRoute();
      // Since canPop is false, handlePopRoute returns true (handled by PopScope)
      expect(handled, isTrue);
      await tester.pump();

      // Verify RegisterScreen remains open
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Verify form data remains completely intact
      final TextField fnWidget = tester.widget(firstNameField);
      final TextField lnWidget = tester.widget(lastNameField);
      final TextField emWidget = tester.widget(emailField);
      expect(fnWidget.controller?.text, equals('Alice'));
      expect(lnWidget.controller?.text, equals('Johnson'));
      expect(emWidget.controller?.text, equals('alice.johnson@company.com'));

      // Reset viewInsets to simulate keyboard dismissed
      tester.view.resetViewInsets();
      await tester.pump();
    });

    testWidgets('2. Keyboard open: First Back dismisses keyboard, Second Back navigates to previous screen',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('Login Screen Placeholder'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Go to register
      await tester.tap(find.text('Login Screen Placeholder'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Type data
      final firstNameField = find.widgetWithText(TextField, 'John');
      await tester.enterText(firstNameField, 'Bob');
      await tester.pump();

      // Keyboard opens
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();

      // 1st Back press -> dismisses keyboard, does NOT pop route
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Keyboard closes
      tester.view.resetViewInsets();
      await tester.pump();

      // Verify PopScope now allows pop
      final PopScope popScopeAfter = tester.widget(find.byWidgetPredicate((w) => w is PopScope));
      expect(popScopeAfter.canPop, isTrue);

      // 2nd Back press -> pops to Login
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsNothing);
      expect(find.text('Login Screen Placeholder'), findsOneWidget);
    });

    testWidgets('3. Keyboard closed: Single Back press navigates directly to previous screen',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('Login Screen Placeholder'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login Screen Placeholder'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Keyboard is closed (viewInsets.bottom is 0)
      final PopScope popScope = tester.widget(find.byWidgetPredicate((w) => w is PopScope));
      expect(popScope.canPop, isTrue);

      // Single back press pops immediately
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsNothing);
      expect(find.text('Login Screen Placeholder'), findsOneWidget);
    });

    testWidgets('4. Form data persists during keyboard show/hide animations without reset',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter data
      final firstNameField = find.widgetWithText(TextField, 'John');
      final lastNameField = find.widgetWithText(TextField, 'Doe');
      await tester.enterText(firstNameField, 'Charlie');
      await tester.enterText(lastNameField, 'Brown');
      await tester.pump();

      // Cycle keyboard visibility 3 times
      for (int i = 0; i < 3; i++) {
        tester.view.viewInsets = const FakeViewPadding(bottom: 320);
        await tester.pump();

        final TextField fnWidget1 = tester.widget(firstNameField);
        expect(fnWidget1.controller?.text, equals('Charlie'));

        tester.view.resetViewInsets();
        await tester.pump();

        final TextField fnWidget2 = tester.widget(firstNameField);
        expect(fnWidget2.controller?.text, equals('Charlie'));
      }

      final TextField finalLn = tester.widget(lastNameField);
      expect(finalLn.controller?.text, equals('Brown'));
    });
  });
}
