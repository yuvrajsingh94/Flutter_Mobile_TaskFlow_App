import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_filter_chips.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/core/widgets/status_badge.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/create_task_screen.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late TaskModel _task;
  late int _progress;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _progress = widget.task.progress;
  }

  Future<void> _updateStatus(TaskStatus newStatus) async {
    setState(() => _isUpdating = true);
    final success = await ref
        .read(tasksNotifierProvider.notifier)
        .updateTaskStatus(_task.id, newStatus);
    if (success && mounted) {
      setState(() {
        _task = _task.copyWith(status: newStatus);
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${newStatus.value}')),
      );
    } else if (mounted) {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _updateProgress(int newProgress) async {
    final success = await ref
        .read(tasksNotifierProvider.notifier)
        .updateTaskProgress(_task.id, newProgress);
    if (success && mounted) {
      setState(() {
        _task = _task.copyWith(progress: newProgress);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.lightBgCard;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderInput;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;
    final progressTrack = isDark ? AppColors.darkBgInput : AppColors.surfaceMuted;
    final dividerColor = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle;

    final authState = ref.watch(authNotifierProvider);
    final isAdmin = authState.isAdmin;

    return ScreenWrapper(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Task',
              onPressed: () async {
                final nav = Navigator.of(context);
                final updated = await Navigator.push<bool>(
                  context,
                  SlidePageRoute(
                    builder: (_) => CreateTaskScreen(editTask: _task),
                  ),
                );
                if (updated == true) {
                  await ref.read(tasksNotifierProvider.notifier).loadTasks();
                  nav.pop();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark ? AppColors.darkBgCard : AppColors.lightBgCard,
                    title: Text('Delete Task', style: TextStyle(color: textPrimary)),
                    content: Text(
                      'Are you sure you want to delete "${_task.title}"?',
                      style: TextStyle(color: textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: TextStyle(color: textSecondary)),
                      ),
                      TextButton(
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          Navigator.pop(ctx);
                          await ref
                              .read(tasksNotifierProvider.notifier)
                              .deleteTask(_task.id);
                          nav.pop();
                        },
                        child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge.taskStatus(_task.status),
                    StatusBadge.taskPriority(_task.priority),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _task.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _task.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: dividerColor),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 16, color: textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      'Assigned to: ',
                      style: TextStyle(fontSize: 13, color: textTertiary),
                    ),
                    Text(
                      _task.assignedToName,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      'Due date: ',
                      style: TextStyle(fontSize: 13, color: textTertiary),
                    ),
                    Text(
                      _task.dueDate,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (!isAdmin) ...[
            // Status Updater (Employees only)
            Text(
              'Update Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
            ),
            const SizedBox(height: 10),
            AppFilterChips<TaskStatus>(
              items: TaskStatus.values,
              selectedItem: _task.status,
              labelBuilder: (s) => s.value,
              padding: EdgeInsets.zero,
              onSelected: _isUpdating ? (_) {} : (status) => _updateStatus(status),
            ),

            const SizedBox(height: 24),

            // Progress Slider (Employees only)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
                ),
                Text(
                  '$_progress%',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _progress.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
              inactiveColor: progressTrack,
              onChanged: (val) {
                setState(() => _progress = val.round());
              },
              onChangeEnd: (val) {
                _updateProgress(val.round());
              },
            ),
          ] else ...[
            // Read-only Progress Card for Admin
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
                      ),
                      Text(
                        '$_progress%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: (_progress / 100.0).clamp(0.0, 1.0),
                      backgroundColor: progressTrack,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progress == 100
                            ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess)
                            : (isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Comments Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
              ),
              Text(
                '${_task.comments.length}',
                style: TextStyle(fontSize: 14, color: textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_task.comments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cardBorder),
              ),
              child: Center(
                child: Text(
                  'No comments yet.',
                  style: TextStyle(fontSize: 13, color: textTertiary),
                ),
              ),
            )
          else
            ..._task.comments.map((c) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.user?.fullName ?? 'Colleague',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.text,
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
