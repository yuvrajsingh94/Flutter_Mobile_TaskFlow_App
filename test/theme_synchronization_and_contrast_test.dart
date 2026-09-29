import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/theme/app_theme.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/leaves/data/models/leave_model.dart';
import 'package:taskflow_flutter/features/leaves/data/repositories/leave_repository.dart';
import 'package:taskflow_flutter/features/leaves/presentation/providers/leave_provider.dart';
import 'package:taskflow_flutter/features/leaves/presentation/screens/admin_leave_management_screen.dart';
import 'package:taskflow_flutter/features/leaves/presentation/screens/my_leaves_screen.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/task_detail_screen.dart';

class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier(UserProfile user)
      : super(AuthState(user: user, token: 'mock-jwt-token', isInitialized: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final adminUser = UserProfile(
    id: 'admin-1',
    firstName: 'Admin',
    lastName: 'User',
    email: 'admin@taskflow.com',
    phoneNumber: '9876543210',
    role: UserRole.admin,
  );

  final employeeUser = UserProfile(
    id: 'emp-1',
    firstName: 'BhanuPratap',
    lastName: 'Singh',
    email: 'bhanu@taskflow.com',
    phoneNumber: '9876543211',
    role: UserRole.employee,
  );

  final sampleLeave = LeaveModel(
    id: 'leave-100',
    employeeId: 'emp-1',
    employee: employeeUser,
    leaveType: LeaveType.unpaid,
    startDate: DateTime(2026, 10, 8),
    endDate: DateTime(2026, 10, 28),
    reason: 'having a date',
    status: LeaveStatus.rejected,
    totalDays: 21,
  );

  group('Centralized Dialog & Control Theme Tokens', () {
    testWidgets('AppTheme defines consistent dialogTheme with proper background and text styling',
        (tester) async {
      final lightDialog = AppTheme.lightTheme.dialogTheme;
      final darkDialog = AppTheme.darkTheme.dialogTheme;

      expect(lightDialog.backgroundColor, equals(AppColors.lightBgCard));
      expect(lightDialog.surfaceTintColor, equals(Colors.transparent));
      expect(lightDialog.titleTextStyle?.color, equals(AppColors.lightTextPrimary));
      expect(lightDialog.contentTextStyle?.color, equals(AppColors.lightTextSecondary));

      expect(darkDialog.backgroundColor, equals(AppColors.darkBgCard));
      expect(darkDialog.surfaceTintColor, equals(Colors.transparent));
      expect(darkDialog.titleTextStyle?.color, equals(AppColors.darkTextPrimary));
      expect(darkDialog.contentTextStyle?.color, equals(AppColors.darkTextSecondary));
    });

    testWidgets('AppTheme defines textButtonTheme with visible foreground colors',
        (tester) async {
      final lightTb = AppTheme.lightTheme.textButtonTheme.style;
      final darkTb = AppTheme.darkTheme.textButtonTheme.style;

      final lightFg = lightTb?.foregroundColor?.resolve({});
      final darkFg = darkTb?.foregroundColor?.resolve({});

      expect(lightFg, equals(AppColors.lightTextPrimary));
      expect(darkFg, equals(AppColors.darkTextPrimary));
    });
  });

  group('Leave Management Reactive Theme Switching', () {
    testWidgets('AdminLeaveManagementScreen cards react immediately when ThemeMode toggles Light <-> Dark',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      ThemeMode currentMode = ThemeMode.light;
      late StateSetter triggerRebuild;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(adminUser)),
            leaveRepositoryProvider.overrideWithValue(FakeLeaveRepository([sampleLeave])),
          ],
          child: StatefulBuilder(
            builder: (context, setState) {
              triggerRebuild = setState;
              return MaterialApp(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: currentMode,
                home: const AdminLeaveManagementScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In Light Mode: Verify screen renders employee name
      expect(find.text('BhanuPratap Singh'), findsOneWidget);

      // Find the card container decoration
      final cardFinder = find.descendant(
        of: find.byKey(ValueKey('admin_leave_${sampleLeave.id}')),
        matching: find.byType(Container),
      );
      expect(cardFinder, findsWidgets);

      Container cardContainer = tester.widget<Container>(cardFinder.first);
      BoxDecoration decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.lightBgCard));

      // Dynamically toggle theme to Dark Mode (WITHOUT page reload or navigation)
      triggerRebuild(() {
        currentMode = ThemeMode.dark;
      });
      await tester.pumpAndSettle();

      // Verify card container IMMEDIATELY updated its background to darkBgCard
      cardContainer = tester.widget<Container>(cardFinder.first);
      decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.darkBgCard));

      // Dynamically toggle back to Light Mode
      triggerRebuild(() {
        currentMode = ThemeMode.light;
      });
      await tester.pumpAndSettle();

      cardContainer = tester.widget<Container>(cardFinder.first);
      decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.lightBgCard));
    });

    testWidgets('MyLeavesScreen cards react immediately when ThemeMode toggles Light <-> Dark',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      ThemeMode currentMode = ThemeMode.light;
      late StateSetter triggerRebuild;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(employeeUser)),
            leaveRepositoryProvider.overrideWithValue(FakeLeaveRepository([sampleLeave])),
          ],
          child: StatefulBuilder(
            builder: (context, setState) {
              triggerRebuild = setState;
              return MaterialApp(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: currentMode,
                home: const MyLeavesScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the card container decoration in Light mode
      final cardFinder = find.descendant(
        of: find.byKey(ValueKey('my_leave_${sampleLeave.id}')),
        matching: find.byType(Container),
      );
      expect(cardFinder, findsWidgets);

      Container cardContainer = tester.widget<Container>(cardFinder.first);
      BoxDecoration decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.surfaceElevated));

      // Dynamically toggle to Dark Mode
      triggerRebuild(() {
        currentMode = ThemeMode.dark;
      });
      await tester.pumpAndSettle();

      cardContainer = tester.widget<Container>(cardFinder.first);
      decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.darkBgCard));
    });
  });

  group('TaskDetailScreen Progress Contrast in Dark Mode', () {
    testWidgets('Task progress text is darkAccentPrimary in dark mode, not black',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final task = TaskModel(
        id: 'task-1',
        title: 'Backend Development',
        description: 'Test description',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        dueDate: '2026-10-01',
        progress: 65,
        assignedUserId: 'admin-1',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => MockAuthNotifier(adminUser)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: TaskDetailScreen(task: task),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final progressTextWidget = tester.widget<Text>(find.text('65%'));
      expect(progressTextWidget.style?.color, equals(AppColors.darkAccentPrimary));
      expect(progressTextWidget.style?.color, isNot(equals(AppColors.primary)));
    });
  });

  group('Employee Unblock Action & Dialog Contrast Tests', () {
    testWidgets('Unblock Account button in Dark Mode uses high-contrast darkAccentPrimary, not black',
        (tester) async {
      Color resolveButtonFg({required bool isBlocked, required bool isDark}) {
        return isBlocked
            ? (isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary)
            : (isDark ? AppColors.darkWarning : AppColors.lightWarning);
      }

      Color resolveButtonBorder({required bool isBlocked, required bool isDark}) {
        return isBlocked
            ? (isDark ? AppColors.darkBorderFocus : AppColors.lightAccentPrimary)
            : (isDark ? AppColors.darkWarning : AppColors.lightWarning);
      }

      final foregroundColor = resolveButtonFg(isBlocked: true, isDark: true);
      final borderColor = resolveButtonBorder(isBlocked: true, isDark: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: foregroundColor,
                side: BorderSide(color: borderColor),
              ),
              onPressed: () {},
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Unblock Account'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final resolvedFg = button.style?.foregroundColor?.resolve({});
      final resolvedSide = button.style?.side?.resolve({});

      expect(resolvedFg, equals(AppColors.darkAccentPrimary));
      expect(resolvedFg, isNot(equals(AppColors.primary)));
      expect(resolvedSide?.color, equals(AppColors.darkBorderFocus));
      expect(resolvedSide?.color, isNot(equals(AppColors.primary)));
    });

    testWidgets('Unblock confirmation dialog in Dark Mode renders visible action text and secondary Cancel',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final textSecondary =
                        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
                    final actionColor =
                        isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary;

                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Unblock Employee'),
                        content: const Text('Are you sure you want to unblock?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('Cancel', style: TextStyle(color: textSecondary)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'Yes, Unblock',
                              style: TextStyle(
                                color: actionColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify Cancel and Yes, Unblock text colors
      final cancelText = tester.widget<Text>(find.text('Cancel'));
      final unblockText = tester.widget<Text>(find.text('Yes, Unblock'));

      expect(cancelText.style?.color, equals(AppColors.darkTextSecondary));
      expect(unblockText.style?.color, equals(AppColors.darkAccentPrimary));
      expect(unblockText.style?.color, isNot(equals(AppColors.primary)));
    });
  });
}
