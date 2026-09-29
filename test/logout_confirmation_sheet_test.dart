import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:taskflow_flutter/core/storage/storage_service.dart';
import 'package:taskflow_flutter/core/theme/app_theme.dart';
import 'package:taskflow_flutter/core/widgets/logout_confirmation_sheet.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/navigation/presentation/admin_more_screen.dart';
import 'package:taskflow_flutter/features/navigation/presentation/root_navigation.dart';
import 'package:taskflow_flutter/features/profile/presentation/screens/profile_screen.dart';

class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  bool logoutCalled = false;

  MockAuthNotifier(UserProfile? user)
      : super(AuthState(
          user: user,
          token: user != null ? 'test-token' : null,
          isInitialized: true,
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> logout() async {
    logoutCalled = true;
    state = AuthState(isInitialized: true);
  }

  @override
  Future<void> refreshUser() async {}
}

class MockStorageService implements StorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  bool getRememberMe() => false;

  @override
  String? getRememberedEmail() => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('UserRoleLabel Single Source of Truth Tests', () {
    test('Admin role provides correct portal label, subtitle, and logout copy', () {
      const role = UserRole.admin;
      expect(role.displayName, equals('Admin'));
      expect(role.portalLabel, equals('Admin Portal'));
      expect(role.preferencesSubtitle, equals('Admin preferences & tools'));
      expect(
        role.logoutConfirmationMessage,
        equals('Are you sure you want to log out of the Admin Portal?'),
      );
    });

    test('Employee role provides correct portal label, subtitle, and logout copy', () {
      const role = UserRole.employee;
      expect(role.displayName, equals('Employee'));
      expect(role.portalLabel, equals('Employee Portal'));
      expect(role.preferencesSubtitle, equals('Employee preferences & tools'));
      expect(
        role.logoutConfirmationMessage,
        equals('Are you sure you want to log out of the Employee Portal?'),
      );
    });

    test('Null / Unknown role gracefully falls back without null or crash', () {
      const UserRole? nullRole = null;
      expect(nullRole.portalLabel, isNull);
      expect(nullRole.preferencesSubtitle, equals('Preferences & tools'));
      expect(
        nullRole.logoutConfirmationMessage,
        equals('Are you sure you want to log out?'),
      );
      expect(nullRole.logoutConfirmationMessage.contains('null'), isFalse);
      expect(nullRole.logoutConfirmationMessage.contains('Unknown'), isFalse);
    });
  });

  group('LogoutConfirmationSheet Widget & UI Layout Tests', () {
    testWidgets('Renders complete Material 3 layout with Admin copy', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: LogoutConfirmationSheet(
              role: UserRole.admin,
              onConfirm: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // 1. Drag handle
      final dragHandleFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.constraints != null) {
          final decoration = widget.decoration;
          if (decoration is BoxDecoration && decoration.borderRadius != null) {
            return true;
          }
        }
        return false;
      });
      expect(dragHandleFinder, findsWidgets);

      // 2. Logout Icon
      expect(find.byIcon(Icons.logout), findsOneWidget);

      // 3. Static Title 'Log Out'
      expect(find.text('Log Out'), findsNWidgets(2)); // Title text & button text

      // 4. Role-aware body copy for Admin
      expect(
        find.text('Are you sure you want to log out of the Admin Portal?'),
        findsOneWidget,
      );

      // 5. Buttons
      final logoutBtnFinder = find.widgetWithText(FilledButton, 'Log Out');
      final cancelBtnFinder = find.widgetWithText(OutlinedButton, 'Cancel');
      expect(logoutBtnFinder, findsOneWidget);
      expect(cancelBtnFinder, findsOneWidget);

      // 6. Vertical stacking: Log Out above Cancel
      final logoutTop = tester.getTopLeft(logoutBtnFinder).dy;
      final cancelTop = tester.getTopLeft(cancelBtnFinder).dy;
      expect(logoutTop, lessThan(cancelTop));

      // 7. Minimum touch target >= 48dp
      final logoutSize = tester.getSize(logoutBtnFinder);
      final cancelSize = tester.getSize(cancelBtnFinder);
      expect(logoutSize.height, greaterThanOrEqualTo(48.0));
      expect(cancelSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Renders Employee confirmation copy when role is employee', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: LogoutConfirmationSheet(
              role: UserRole.employee,
              onConfirm: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('Are you sure you want to log out of the Employee Portal?'),
        findsOneWidget,
      );
    });

    testWidgets('Renders generic fallback copy when role is null / unknown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: LogoutConfirmationSheet(
              role: null,
              onConfirm: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Are you sure you want to log out?'), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);
      expect(find.textContaining('Unknown'), findsNothing);
    });

    testWidgets('Dark theme renders properly with appropriate contrast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: LogoutConfirmationSheet(
              role: UserRole.admin,
              onConfirm: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(
        find.text('Are you sure you want to log out of the Admin Portal?'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Log Out'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    });
  });

  group('Modal Bottom Sheet Dismissal & Interaction Tests', () {
    testWidgets('Tapping Cancel dismisses sheet with ZERO logout side effects', (tester) async {
      bool logoutInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showLogoutConfirmationSheet(
                  context: context,
                  role: UserRole.admin,
                  onConfirmLogout: () {
                    logoutInvoked = true;
                  },
                ),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out of the Admin Portal?'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.text('Are you sure you want to log out of the Admin Portal?'), findsNothing);
      // Callback was NOT invoked
      expect(logoutInvoked, isFalse);
    });

    testWidgets('Tapping modal barrier (scrim) dismisses sheet with ZERO side effects', (tester) async {
      bool logoutInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showLogoutConfirmationSheet(
                  context: context,
                  role: UserRole.admin,
                  onConfirmLogout: () {
                    logoutInvoked = true;
                  },
                ),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out of the Admin Portal?'), findsOneWidget);

      // Tap above the bottom sheet (scrim)
      await tester.tapAt(const Offset(200, 50));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out of the Admin Portal?'), findsNothing);
      expect(logoutInvoked, isFalse);
    });

    testWidgets('Tapping Log Out triggers haptic feedback and invokes logout callback', (tester) async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });

      bool logoutInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showLogoutConfirmationSheet(
                  context: context,
                  role: UserRole.admin,
                  onConfirmLogout: () {
                    logoutInvoked = true;
                  },
                ),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Tap Log Out button
      await tester.tap(find.widgetWithText(FilledButton, 'Log Out'));
      await tester.pumpAndSettle();

      // Verify haptic feedback was called
      expect(
        log.any((call) =>
            call.method == 'HapticFeedback.vibrate' &&
            call.arguments == 'HapticFeedbackType.mediumImpact'),
        isTrue,
      );

      // Verify callback executed
      expect(logoutInvoked, isTrue);
    });

    testWidgets('Rapidly tapping Log Out only executes callback once (Duplicate Navigation Protection)',
        (tester) async {
      int executionCount = 0;
      final completer = Completer<void>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogoutConfirmationSheet(
              role: UserRole.admin,
              onConfirm: () async {
                executionCount++;
                await completer.future;
              },
              onCancel: () {},
            ),
          ),
        ),
      );

      // First tap dispatches
      await tester.tap(find.widgetWithText(FilledButton, 'Log Out'));
      await tester.pump();

      // Subsequent rapid taps while _isLoggingOut is true
      await tester.tap(find.widgetWithText(FilledButton, 'Log Out'), warnIfMissed: false);
      await tester.pump();

      completer.complete();
      await tester.pumpAndSettle();

      expect(executionCount, equals(1));
    });
  });

  group('Integration with AdminMoreScreen & ProfileScreen Tests', () {
    testWidgets('AdminMoreScreen displays role-aware subtitle and button, and opens bottom sheet',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final adminUser = UserProfile(
        id: 'admin-1',
        firstName: 'Sarah',
        lastName: 'Connor',
        email: 'sarah@taskflow.com',
        phoneNumber: '9876543210',
        role: UserRole.admin,
      );

      late MockAuthNotifier notifier;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(MockStorageService()),
            authNotifierProvider.overrideWith((ref) {
              notifier = MockAuthNotifier(adminUser);
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: AdminMoreScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Subtitle uses single source of truth
      expect(find.text('Admin preferences & tools'), findsOneWidget);

      // Logout button uses single source of truth
      expect(find.text('Log Out of Admin Portal'), findsOneWidget);

      // Tap logout button
      final logoutBtn = find.text('Log Out of Admin Portal');
      await tester.scrollUntilVisible(
        logoutBtn,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Bottom sheet appears with role-aware copy
      expect(
        find.text('Are you sure you want to log out of the Admin Portal?'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing); // Old AlertDialog is gone!

      // Confirm logout
      await tester.tap(find.widgetWithText(FilledButton, 'Log Out'));
      await tester.pumpAndSettle();

      expect(notifier.logoutCalled, isTrue);
    });

    testWidgets('ProfileScreen _handleLogout opens bottom sheet with role-aware copy',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final employeeUser = UserProfile(
        id: 'emp-1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@taskflow.com',
        phoneNumber: '9123456780',
        role: UserRole.employee,
      );

      late MockAuthNotifier notifier;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(MockStorageService()),
            authNotifierProvider.overrideWith((ref) {
              notifier = MockAuthNotifier(employeeUser);
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down to Log Out button in ProfileScreen
      final logoutBtn = find.byIcon(Icons.logout_rounded);
      await tester.scrollUntilVisible(
        logoutBtn,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(logoutBtn, findsOneWidget);

      // Tap Log Out
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Bottom sheet appears with Employee role copy
      expect(
        find.text('Are you sure you want to log out of the Employee Portal?'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      // Confirm logout
      await tester.tap(find.widgetWithText(FilledButton, 'Log Out'));
      await tester.pumpAndSettle();

      expect(notifier.logoutCalled, isTrue);
    });

    testWidgets('Full logout navigation stack clearing and back protection', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final adminUser = UserProfile(
        id: 'admin-1',
        firstName: 'Admin',
        lastName: 'User',
        email: 'admin@taskflow.com',
        phoneNumber: '9823456789',
        role: UserRole.admin,
      );

      late MockAuthNotifier notifier;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(MockStorageService()),
            authNotifierProvider.overrideWith((ref) {
              notifier = MockAuthNotifier(adminUser);
              return notifier;
            }),
          ],
          child: MaterialApp(
            navigatorKey: rootNavigatorKey,
            home: const RootNavigation(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to More tab (index 4) using BottomNavigationBar item icon
      await tester.tap(find.byIcon(Icons.more_horiz_outlined));
      await tester.pumpAndSettle();

      // Tap Log Out of Admin Portal button
      final logoutBtn = find.text('Log Out of Admin Portal');
      await tester.scrollUntilVisible(
        logoutBtn,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Bottom sheet is visible
      expect(find.text('Are you sure you want to log out of the Admin Portal?'), findsOneWidget);

      // Confirm logout
      await tester.tap(find.widgetWithText(FilledButton, 'Log Out'));
      await tester.pumpAndSettle();

      // Stack is cleared and LoginScreen is displayed
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to your TaskFlow account'), findsOneWidget);

      // Android Back press: ensure cannot return to Dashboard or More
      final didPop = await rootNavigatorKey.currentState!.maybePop();
      await tester.pumpAndSettle();

      expect(didPop, isFalse);
      expect(find.text('Welcome back'), findsOneWidget);
    });
  });
}
