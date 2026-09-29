import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/profile/presentation/screens/profile_screen.dart';

class FakeAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  FakeAuthNotifier(UserProfile user)
      : super(AuthState(user: user, token: 'mock-token', isInitialized: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> refreshUser() async {}

  @override
  void updateUser(UserProfile updated) {
    state = state.copyWith(user: updated);
  }
}

void main() {
  final testUser = UserProfile(
    id: 'user-123',
    firstName: 'Alex',
    lastName: 'Morgan',
    email: 'alex@example.com',
    phoneNumber: '9823456789',
    countryCode: '+91',
    role: UserRole.employee,
    qualification: 'B.Tech / B.E. - Computer Science',
    bio: 'Software engineer with passion for clean UI.',
    emailVerified: true,
    phoneVerified: true,
  );

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => FakeAuthNotifier(testUser)),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  testWidgets('ProfileScreen renders user details and handles edit / validation / save button state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify user info is displayed
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);

    // Tap "Edit Profile"
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    // "Cancel" and "Save Changes" should now be visible
    expect(find.text('Cancel'), findsNWidgets(2));
    expect(find.text('Save Changes'), findsOneWidget);

    // Initially, Save Changes button should be disabled because there are no unsaved changes
    final saveButtonFinder = find.widgetWithText(AppButton, 'Save Changes');
    expect(saveButtonFinder, findsOneWidget);
    final initialButton = tester.widget<AppButton>(saveButtonFinder);
    expect(initialButton.disabled, isTrue);

    // First Name field is the first TextField in Personal Details
    final firstNameFinder = find.byType(TextField).first;
    expect(firstNameFinder, findsOneWidget);

    await tester.enterText(firstNameFinder, 'Alexander');
    await tester.pumpAndSettle();

    // Now Save Changes button should be enabled!
    final enabledButton = tester.widget<AppButton>(saveButtonFinder);
    expect(enabledButton.disabled, isFalse);

    // Now clear First Name to trigger validation onBlur
    await tester.enterText(firstNameFinder, '');
    await tester.pumpAndSettle();

    // Move focus to Last Name field (second TextField) to trigger onBlur on First Name
    final lastNameFinder = find.byType(TextField).at(1);
    await tester.tap(lastNameFinder);
    await tester.pumpAndSettle();

    // Validation error message should appear
    expect(find.text('Please enter your first name.'), findsOneWidget);

    // Tap Cancel to revert
    await tester.tap(find.text('Cancel').first);
    await tester.pumpAndSettle();

    // After cancel, Edit Profile should be visible again
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Please enter your first name.'), findsNothing);
  });

  testWidgets('Edit Profile button has high contrast in Dark Mode', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => FakeAuthNotifier(testUser)),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final editProfileFinder = find.text('Edit Profile');
    expect(editProfileFinder, findsOneWidget);
    final textWidget = tester.widget<Text>(editProfileFinder);
    // In Dark Mode, text color must not be black (0xFF18181B); it must be high-contrast light accent
    expect(textWidget.style?.color, isNot(equals(const Color(0xFF18181B))));
  });
}
