import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_filter_chips.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/data/repositories/task_repository.dart';
import 'package:taskflow_flutter/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/admin_task_management_screen.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:taskflow_flutter/features/leaves/data/models/leave_model.dart';
import 'package:taskflow_flutter/features/leaves/presentation/providers/leave_provider.dart';
import 'package:taskflow_flutter/features/leaves/presentation/screens/admin_leave_management_screen.dart';

import 'package:taskflow_flutter/features/leaves/data/repositories/leave_repository.dart';

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

class FakeLeaveRepository implements LeaveRepository {
  final List<LeaveModel> leaves;
  FakeLeaveRepository([this.leaves = const []]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<LeaveModel>> getLeaves() async => leaves;
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

  final employeeUser = UserProfile(
    id: 'emp-1',
    firstName: 'Alice',
    lastName: 'Dev',
    email: 'alice@taskflow.com',
    phoneNumber: '9876543211',
    role: UserRole.employee,
  );

  final sampleTask = TaskModel(
    id: 'task-101',
    title: 'Migrate React Native to Flutter',
    description: 'Ensure 100% parity with design and business rules.',
    status: TaskStatus.inProgress,
    priority: TaskPriority.high,
    dueDate: '2026-10-01',
    progress: 45,
    assignedUserId: 'emp-1',
    assignedUser: employeeUser,
  );

  group('AppFilterChips Component', () {
    testWidgets('Renders all chips without clipping or checkmarks and triggers onSelected',
        (tester) async {
      String selected = 'All';
      final tabs = ['All', 'Pending', 'In Progress', 'Completed'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppFilterChips<String>(
                  items: tabs,
                  selectedItem: selected,
                  onSelected: (val) {
                    setState(() => selected = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify all 4 tabs are present
      for (final tab in tabs) {
        expect(find.text(tab), findsOneWidget);
      }

      // No Checkbox or Checkmark icons should exist
      expect(find.byIcon(Icons.check), findsNothing);

      // Tap 'Completed'
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      expect(selected, equals('Completed'));
    });
  });

  group('AdminTaskManagementScreen UI & Button Placement', () {
    testWidgets('Header contains "+ New Task" button and FAB is removed', (tester) async {
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

      // Verify New Task button exists in AppBar actions with plus icon
      expect(find.widgetWithText(AppButton, 'New Task'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Verify FloatingActionButton is NOT present (no bottom nav overlap!)
      expect(find.byType(FloatingActionButton), findsNothing);

      // Verify filter chips
      expect(find.byType(AppFilterChips<String>), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });
  });

  group('Admin Task Status Business Rules (TaskDetailScreen)', () {
    testWidgets('Admin CANNOT manually change status: hides Update Status chips & slider',
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
          child: MaterialApp(
            home: TaskDetailScreen(task: sampleTask),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Admin must NOT see 'Update Status' chips or Slider
      expect(find.text('Update Status'), findsNothing);
      expect(find.byType(Slider), findsNothing);

      // Admin DOES see read-only progress indicator
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Admin has Edit Task and Delete Task actions in AppBar
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('Employee CAN update status and progress for assigned task',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(employeeUser)),
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
          ],
          child: MaterialApp(
            home: TaskDetailScreen(task: sampleTask),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Employee DOES see 'Update Status' chips and Slider
      expect(find.text('Update Status'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);

      // Employee does NOT have edit/delete in AppBar
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });
  });

  group('AdminLeaveManagementScreen Filter UX', () {
    testWidgets('Renders unclipped AppFilterChips for leaves', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(adminUser)),
            leaveRepositoryProvider.overrideWithValue(FakeLeaveRepository()),
          ],
          child: const MaterialApp(
            home: AdminLeaveManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppFilterChips<String>), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
    });

    testWidgets('Pending leave renders sleek outlined Reject and primary Approve buttons with icons',
        (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final sampleLeave = LeaveModel(
        id: 'leave-1',
        employeeId: 'emp-1',
        employee: employeeUser,
        leaveType: LeaveType.unpaid,
        startDate: DateTime(2026, 9, 22),
        endDate: DateTime(2026, 9, 29),
        reason: 'I have a medical checkup scheduled for this workdays!!',
        status: LeaveStatus.pending,
        totalDays: 8,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(adminUser)),
            leaveRepositoryProvider.overrideWithValue(FakeLeaveRepository([sampleLeave])),
          ],
          child: const MaterialApp(
            home: AdminLeaveManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify leave card content
      expect(find.text('Alice Dev'), findsOneWidget);
      expect(find.text('8 day(s)'), findsOneWidget);
      expect(find.byType(Wrap), findsWidgets);

      // Verify sleek Reject button with close icon
      expect(find.widgetWithText(OutlinedButton, 'Reject'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Verify sleek Approve button with check icon
      expect(find.widgetWithText(FilledButton, 'Approve'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
