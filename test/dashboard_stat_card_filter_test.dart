import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/widgets/app_filter_chips.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/data/repositories/task_repository.dart';
import 'package:taskflow_flutter/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/admin_task_management_screen.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/my_tasks_screen.dart';
import 'package:taskflow_flutter/features/dashboard/presentation/screens/admin_dashboard_screen.dart';

class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier(UserProfile user)
      : super(AuthState(user: user, token: 'mock-jwt-token', isInitialized: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTaskRepository implements TaskRepository {
  final List<TaskModel> tasks;
  FakeTaskRepository(this.tasks);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<TaskModel>> getTasks() async => tasks;
}

void main() {
  final adminUser = UserProfile(
    id: 'admin-1',
    firstName: 'Admin',
    lastName: 'User',
    email: 'admin@taskflow.com',
    phoneNumber: '9876543210',
    role: UserRole.admin,
  );

  final testTasks = [
    TaskModel(
      id: 'task-1',
      title: 'Fix Navigation Bug',
      description: 'Slide animations',
      status: TaskStatus.pending,
      priority: TaskPriority.high,
      dueDate: '2026-10-01',
    ),
    TaskModel(
      id: 'task-2',
      title: 'Build Dashboard',
      description: 'KPI charts',
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
      dueDate: '2026-10-02',
    ),
    TaskModel(
      id: 'task-3',
      title: 'Setup Database',
      description: 'Postgres migrations',
      status: TaskStatus.completed,
      priority: TaskPriority.low,
      dueDate: '2026-10-03',
    ),
  ];

  group('Dashboard Stat Cards Filter Routing Tests', () {
    testWidgets('Tapping Pending card on AdminDashboard navigates to Tasks with Pending filter active',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(adminUser)),
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository(testTasks)),
            tasksProvider.overrideWith((ref) async => testTasks),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dashboard shows stat cards
      expect(find.text('Pending'), findsWidgets);

      // Tap on the Pending stat card
      await tester.tap(find.text('Pending').first);
      await tester.pumpAndSettle();

      // Verify we navigated to AdminTaskManagementScreen
      expect(find.byType(AdminTaskManagementScreen), findsOneWidget);

      // Verify "Pending" chip is active
      final chipFinder = find.byType(AppFilterChips<String>);
      expect(chipFinder, findsOneWidget);
      final chipWidget = tester.widget<AppFilterChips<String>>(chipFinder);
      expect(chipWidget.selectedItem, equals('Pending'));

      // Verify only the Pending task is displayed
      expect(find.text('Fix Navigation Bug'), findsOneWidget);
      expect(find.text('Build Dashboard'), findsNothing);
      expect(find.text('Setup Database'), findsNothing);
    });

    testWidgets('Tapping In Progress card on AdminDashboard navigates with In Progress filter active',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(adminUser)),
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository(testTasks)),
            tasksProvider.overrideWith((ref) async => testTasks),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the In Progress stat card
      await tester.tap(find.text('In Progress').first);
      await tester.pumpAndSettle();

      // Verify we navigated to AdminTaskManagementScreen
      expect(find.byType(AdminTaskManagementScreen), findsOneWidget);

      final chipFinder = find.byType(AppFilterChips<String>);
      final chipWidget = tester.widget<AppFilterChips<String>>(chipFinder);
      expect(chipWidget.selectedItem, equals('In Progress'));

      // Verify only In Progress task is displayed
      expect(find.text('Build Dashboard'), findsOneWidget);
      expect(find.text('Fix Navigation Bug'), findsNothing);
      expect(find.text('Setup Database'), findsNothing);
    });

    testWidgets('Tapping Completed card on AdminDashboard navigates with Completed filter active',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(adminUser)),
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository(testTasks)),
            tasksProvider.overrideWith((ref) async => testTasks),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the Completed stat card
      await tester.tap(find.text('Completed').first);
      await tester.pumpAndSettle();

      // Verify we navigated to AdminTaskManagementScreen
      expect(find.byType(AdminTaskManagementScreen), findsOneWidget);

      final chipFinder = find.byType(AppFilterChips<String>);
      final chipWidget = tester.widget<AppFilterChips<String>>(chipFinder);
      expect(chipWidget.selectedItem, equals('Completed'));

      // Verify only Completed task is displayed
      expect(find.text('Setup Database'), findsOneWidget);
      expect(find.text('Fix Navigation Bug'), findsNothing);
      expect(find.text('Build Dashboard'), findsNothing);
    });

    testWidgets('Tapping Total Tasks card navigates with All filter active',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(adminUser)),
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository(testTasks)),
            tasksProvider.overrideWith((ref) async => testTasks),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the Total Tasks stat card
      await tester.tap(find.text('Total Tasks').first);
      await tester.pumpAndSettle();

      // Verify we navigated to AdminTaskManagementScreen
      expect(find.byType(AdminTaskManagementScreen), findsOneWidget);

      final chipFinder = find.byType(AppFilterChips<String>);
      final chipWidget = tester.widget<AppFilterChips<String>>(chipFinder);
      expect(chipWidget.selectedItem, equals('All'));

      // All tasks displayed
      expect(find.text('Fix Navigation Bug'), findsOneWidget);
      expect(find.text('Build Dashboard'), findsOneWidget);
      expect(find.text('Setup Database'), findsOneWidget);
    });

    testWidgets('MyTasksScreen supports direct initialFilter instantiation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(adminUser)),
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository(testTasks)),
          ],
          child: const MaterialApp(
            home: MyTasksScreen(initialFilter: 'Pending'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final chipFinder = find.byType(AppFilterChips<String>);
      final chipWidget = tester.widget<AppFilterChips<String>>(chipFinder);
      expect(chipWidget.selectedItem, equals('Pending'));
    });
  });
}
