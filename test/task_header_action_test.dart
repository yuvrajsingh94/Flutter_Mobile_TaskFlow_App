import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/data/repositories/task_repository.dart';
import 'package:taskflow_flutter/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/admin_task_management_screen.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/create_task_screen.dart';

class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier(UserProfile user)
      : super(AuthState(user: user, token: 'mock-jwt-token', isInitialized: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTaskRepository implements TaskRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<TaskModel>> getTasks() async => [];
}

void main() {
  final adminUser = UserProfile(
    id: 'admin-1',
    firstName: 'Admin',
    lastName: 'Boss',
    email: 'admin@taskflow.com',
    phoneNumber: '9876543210',
    role: UserRole.admin,
  );

  group('New Task Header Action Design Tests', () {
    testWidgets('Header button renders with New Task text, plus icon, and compact primary styling',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(adminUser)),
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
          ],
          child: const MaterialApp(
            home: AdminTaskManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify "New Task" text and plus icon exist in AppBar
      final buttonFinder = find.widgetWithText(AppButton, 'New Task');
      expect(buttonFinder, findsOneWidget);

      final iconFinder = find.descendant(
        of: buttonFinder,
        matching: find.byIcon(Icons.add_rounded),
      );
      expect(iconFinder, findsOneWidget);

      // 2. Verify button dimensions: height is 44px
      final appButton = tester.widget<AppButton>(buttonFinder);
      expect(appButton.height, equals(44.0));
      expect(appButton.borderRadius, equals(12.0));
      expect(appButton.text, equals('New Task'));

      // 3. Verify plus icon size is ~19px
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, equals(19.0));

      // 4. Verify text style is semibold 15px
      expect(appButton.textStyle?.fontSize, equals(15.0));
      expect(appButton.textStyle?.fontWeight, equals(FontWeight.w600));

      // 5. Verify tapping navigates to CreateTaskScreen
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(CreateTaskScreen), findsOneWidget);
    });

    testWidgets('Header layout remains responsive on narrow screen (360px width)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(adminUser)),
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
          ],
          child: const MaterialApp(
            home: AdminTaskManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure no overflow exception occurred
      expect(tester.takeException(), isNull);
      expect(find.text('Task Management'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'New Task'), findsOneWidget);
    });
  });
}
