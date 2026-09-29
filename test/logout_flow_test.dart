import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:taskflow_flutter/core/storage/storage_service.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/navigation/presentation/root_navigation.dart';

class LogoutTestAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  LogoutTestAuthNotifier(UserProfile user)
      : super(AuthState(user: user, token: 'mock-token', isInitialized: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> logout() async {
    state = AuthState(isInitialized: true);
  }
}

class FakeStorageService implements StorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  bool getRememberMe() => false;

  @override
  String? getRememberedEmail() => null;
}

void main() {
  testWidgets('RootNavigation pops all pushed screens and renders LoginScreen on logout',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final testUser = UserProfile(
      id: 'admin-1',
      firstName: 'Admin',
      lastName: 'User',
      email: 'admin@taskflow.com',
      phoneNumber: '9823456789',
      role: UserRole.admin,
    );

    late LogoutTestAuthNotifier notifier;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(FakeStorageService()),
          authNotifierProvider.overrideWith((ref) {
            notifier = LogoutTestAuthNotifier(testUser);
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

    // Push a dummy detail route onto the navigator
    rootNavigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Pushed Screen On Top')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pushed Screen On Top'), findsOneWidget);

    // Now trigger logout
    await notifier.logout();
    await tester.pumpAndSettle();

    // Pushed screen should be automatically popped and LoginScreen should be displayed!
    expect(find.text('Pushed Screen On Top'), findsNothing);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in to your TaskFlow account'), findsOneWidget);
  });

  testWidgets('Login triggers horizontal PUSH transition (RIGHT -> LEFT)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final testUser = UserProfile(
      id: 'admin-1',
      firstName: 'Admin',
      lastName: 'User',
      email: 'admin@taskflow.com',
      phoneNumber: '9823456789',
      role: UserRole.admin,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(FakeStorageService()),
          authNotifierProvider.overrideWith((ref) {
            final notifier = LogoutTestAuthNotifier(testUser);
            // Start unauthenticated
            notifier.state = AuthState(isInitialized: true);
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

    // Currently showing LoginScreen
    expect(find.text('Welcome back'), findsOneWidget);

    // Now trigger login
    final container = ProviderScope.containerOf(tester.element(find.byType(RootNavigation)));
    container.read(authNotifierProvider.notifier).state =
        AuthState(user: testUser, token: 'mock-token', isInitialized: true);

    // Advance 100ms into the 300ms transition
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify SlideTransition exists with positive dx (entering from the right)
    final slideFinder = find.byKey(const ValueKey('auth_shell_slide_transition'));
    expect(slideFinder, findsOneWidget);
    final slideWidget = tester.widget<SlideTransition>(slideFinder);
    expect(slideWidget.position.value.dx, greaterThan(0.0));
    expect(slideWidget.position.value.dx, lessThan(1.0));

    // Finish animation
    await tester.pumpAndSettle();
    expect(find.byType(AdminShell), findsOneWidget);
  });

  testWidgets('Logout triggers horizontal POP transition (LEFT -> RIGHT)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final testUser = UserProfile(
      id: 'admin-1',
      firstName: 'Admin',
      lastName: 'User',
      email: 'admin@taskflow.com',
      phoneNumber: '9823456789',
      role: UserRole.admin,
    );

    late LogoutTestAuthNotifier notifier;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(FakeStorageService()),
          authNotifierProvider.overrideWith((ref) {
            notifier = LogoutTestAuthNotifier(testUser);
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

    // Authenticated AdminShell is visible
    expect(find.byType(AdminShell), findsOneWidget);

    // Trigger logout
    await notifier.logout();

    // Advance 100ms into the 300ms transition
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify SlideTransition exists with positive dx (moving toward the right)
    final slideFinder = find.byKey(const ValueKey('auth_shell_slide_transition'));
    expect(slideFinder, findsOneWidget);
    final slideWidget = tester.widget<SlideTransition>(slideFinder);
    expect(slideWidget.position.value.dx, greaterThan(0.0));
    expect(slideWidget.position.value.dx, lessThan(1.0));

    // Finish animation
    await tester.pumpAndSettle();
    expect(find.byType(AdminShell), findsNothing);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Logout from More tab preserves More tab (does not reset to Dashboard index 0)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final testUser = UserProfile(
      id: 'admin-1',
      firstName: 'Admin',
      lastName: 'User',
      email: 'admin@taskflow.com',
      phoneNumber: '9823456789',
      role: UserRole.admin,
    );

    late LogoutTestAuthNotifier notifier;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(FakeStorageService()),
          authNotifierProvider.overrideWith((ref) {
            notifier = LogoutTestAuthNotifier(testUser);
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

    // Switch to More tab (index 4)
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    final indexedStackFinder = find.byType(IndexedStack);
    expect(indexedStackFinder, findsOneWidget);
    expect(tester.widget<IndexedStack>(indexedStackFinder).index, equals(4));

    // Trigger logout
    await notifier.logout();

    // Advance 100ms into the 300ms transition
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // During the animation, IndexedStack MUST STILL be at index 4 (More), NOT 0 (Dashboard)!
    expect(tester.widget<IndexedStack>(indexedStackFinder).index, equals(4));

    // Finish animation
    await tester.pumpAndSettle();
    expect(find.byType(AdminShell), findsNothing);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}

