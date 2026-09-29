import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_filter_chips.dart';
import 'package:taskflow_flutter/core/widgets/empty_state.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/core/widgets/status_badge.dart';
import 'package:taskflow_flutter/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskflow_flutter/features/tasks/presentation/widgets/task_status_update_modal.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/task_detail_screen.dart';

class MyTasksScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  const MyTasksScreen({super.key, this.initialFilter});

  @override
  ConsumerState<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends ConsumerState<MyTasksScreen> {
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

    final tabs = ['All', 'Pending', 'In Progress', 'Completed'];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.surfaceElevated;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : AppColors.borderHairline;
    final searchBg = isDark ? AppColors.darkBgInput : AppColors.surfaceElevated;
    final searchBorder = isDark ? AppColors.darkBorder : AppColors.borderHairline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextDisabled : AppColors.textTertiary;
    final progressTrack = isDark ? AppColors.darkBgInput : AppColors.surfaceMuted;
    final progressColor = isDark ? AppColors.darkAccentPrimary : AppColors.primary;

    return ScreenWrapper(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.read(tasksNotifierProvider.notifier).loadTasks(),
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
                color: searchBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: searchBorder),
              ),
              child: TextField(
                style: TextStyle(color: textPrimary, fontSize: 14),
                onChanged: (val) => ref.read(tasksNotifierProvider.notifier).setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search my assigned tasks...',
                  hintStyle: TextStyle(color: textTertiary, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: textTertiary),
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
                    ? const EmptyState(
                        icon: Icons.task_alt_outlined,
                        title: 'No tasks found',
                        description: 'You have no assigned tasks in this filter view. Great job keeping up!',
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(builder: (_) => TaskDetailScreen(task: task)),
                              );
                            },
                            onLongPress: () => TaskStatusUpdateModal.show(context, task),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
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
                                      StatusBadge.taskStatus(task.status),
                                      StatusBadge.taskPriority(task.priority),
                                    ],
                                  ),
                        const SizedBox(height: 10),
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: textSecondary),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: task.progress / 100.0,
                            backgroundColor: progressTrack,
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                            minHeight: 5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress: ${task.progress}%',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 13, color: textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  task.dueDate,
                                  style: TextStyle(fontSize: 12, color: textTertiary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Generous bottom clearance
          SizedBox(height: MediaQuery.of(context).padding.bottom + 96),
        ],
      ),
    );
  }
}
