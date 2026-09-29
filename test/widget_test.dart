import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_flutter/core/widgets/logo.dart';
import 'package:taskflow_flutter/core/widgets/status_badge.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';

void main() {
  testWidgets('Logo renders brand mark and text correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Logo(size: LogoSize.md),
          ),
        ),
      ),
    );

    expect(find.text('TaskFlow'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('StatusBadge renders appropriate labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusBadge.taskStatus(TaskStatus.inProgress),
              StatusBadge.taskPriority(TaskPriority.high),
            ],
          ),
        ),
      ),
    );

    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });
}
