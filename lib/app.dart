import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:taskflow_flutter/core/theme/app_theme.dart';
import 'package:taskflow_flutter/core/theme/theme_provider.dart';
import 'package:taskflow_flutter/features/navigation/presentation/root_navigation.dart';

/// Root Application widget for TaskFlow Enterprise.
class TaskFlowApp extends ConsumerWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'TaskFlow Enterprise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const RootNavigation(),
    );
  }
}

