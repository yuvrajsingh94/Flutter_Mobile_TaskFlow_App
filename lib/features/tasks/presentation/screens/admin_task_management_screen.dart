import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_filter_chips.dart';
import 'package:taskflow_flutter/core/widgets/empty_state.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/core/widgets/status_badge.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/create_task_screen.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/task_detail_screen.dart';

class AdminTaskManagementScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  const AdminTaskManagementScreen({super.key, this.initialFilter});

  @override
  ConsumerState<AdminTaskManagementScreen> createState() => _AdminTaskManagementScreenState();
}

class _AdminTaskManagementScreenState extends ConsumerState<AdminTaskManagementScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(tasksNotifierProvider.notifier).setFilter(widget.initialFilter!);
          ref.read(tasksNotifierProvider.notifier).setSearchQuery('');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(tasksNotifierProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = ['All', 'Pending', 'In Progress', 'Completed'];

    return ScreenWrapper(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        title: const Text('Task Management'),
        titleSpacing: 16,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            visualDensity: VisualDensity.compact,
            onPressed: () => ref.read(tasksNotifierProvider.notifier).loadTasks(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: AppButton(
                text: 'New Task',
                leftIcon: Icon(
                  Icons.add_rounded,
                  size: 19,
                  color: isDark ? AppColors.darkAccentFg : AppColors.lightAccentFg,
                ),
                height: 44,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(builder: (_) => const CreateTaskScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      onRefresh: () => ref.read(tasksNotifierProvider.notifier).loadTasks(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Search Input (padded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBgInput : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorderSubtle : AppColors.borderHairline,
                ),
              ),
              child: TextField(
                onChanged: (val) => ref.read(tasksNotifierProvider.notifier).setSearchQuery(val),
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search tasks, assignees...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextPlaceholder : AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Filter Tabs (Edge-to-edge scrollable with 16px gutters)
          AppFilterChips<String>(
            items: tabs,
            selectedItem: taskState.activeFilter,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            onSelected: (tab) {
              ref.read(tasksNotifierProvider.notifier).setFilter(tab);
            },
          ),

          const SizedBox(height: 16),

          // Tasks List (padded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: taskState.isLoading && taskState.tasks.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : filteredTasks.isEmpty
                    ? EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'No tasks found',
                        description: 'There are no tasks matching your selected filters or search query.',
                        actionLabel: 'Create Task',
                        onAction: () {
                          Navigator.push(
                            context,
                            SlidePageRoute(builder: (_) => const CreateTaskScreen()),
                          );
                        },
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return _buildTaskCard(context, ref, task);
                        },
                      ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.surfaceElevated;
    final borderCol = isDark ? AppColors.darkBorderSubtle : AppColors.borderHairline;
    final titleCol = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final descCol = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final metaCol = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final tertiaryCol = isDark ? AppColors.darkTextDisabled : AppColors.textTertiary;
    final trackCol = isDark ? AppColors.darkBgSidebar : AppColors.surfaceMuted;
    final progressCol = isDark ? AppColors.darkAccentPrimary : AppColors.primary;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          SlidePageRoute(builder: (_) => TaskDetailScreen(task: task)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0x08292524),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge.taskStatus(task.status),
                StatusBadge.taskPriority(task.priority),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: titleCol,
              ),
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: descCol),
              ),
            ],
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: task.progress / 100.0,
                backgroundColor: trackCol,
                valueColor: AlwaysStoppedAnimation<Color>(progressCol),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 14, color: tertiaryCol),
                    const SizedBox(width: 4),
                    Text(
                      task.assignedToName,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: metaCol),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: tertiaryCol),
                    const SizedBox(width: 4),
                    Text(
                      () {
                        final parsed = DateTime.tryParse(task.dueDate);
                        return parsed != null
                            ? DateFormat('MMM d, y').format(parsed)
                            : task.dueDate;
                      }(),
                      style: TextStyle(fontSize: 12, color: tertiaryCol),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
