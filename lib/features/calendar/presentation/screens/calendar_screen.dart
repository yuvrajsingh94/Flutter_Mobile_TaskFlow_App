import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/empty_state.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/core/widgets/status_badge.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/task_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    // Find Monday of the current week (weekday 1)
    _currentWeekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskNotifierProvider);
    final myTasks = taskState.tasks;

    final weekDays = List.generate(7, (i) => _currentWeekStart.add(Duration(days: i)));

    final tasksForSelectedDate = myTasks.where((t) {
      final due = DateTime.tryParse(t.dueDate);
      if (due == null) return false;
      return _isSameDay(due, _selectedDate);
    }).toList();

    final monthTitle = DateFormat('MMMM yyyy').format(_selectedDate);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextDisabled : AppColors.textTertiary;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.borderHairline;
    final activeDayBg = isDark ? AppColors.darkAccentPrimary : AppColors.primary;
    final activeDayFg = isDark ? AppColors.darkAccentFg : Colors.white;
    final inactiveDayBg = isDark ? AppColors.darkBgCard : AppColors.surfaceElevated;

    return ScreenWrapper(
      scrollable: false,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
            ),
            Text(
              'Schedule & upcoming deadlines',
              style: TextStyle(fontSize: 12, color: textTertiary),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month & Week Navigation Header ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, size: 22, color: textPrimary),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: borderCol),
                      ),
                      padding: const EdgeInsets.all(6),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, size: 22, color: textPrimary),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: borderCol),
                      ),
                      padding: const EdgeInsets.all(6),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
                      });
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Week Day Strip ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((d) {
              final isSelected = _isSameDay(d, _selectedDate);
              final hasTasks = myTasks.any((t) {
                final due = DateTime.tryParse(t.dueDate);
                return due != null && _isSameDay(due, d);
              });

              final dayName = DateFormat('E').format(d).substring(0, 3);
              final dayNum = '${d.day}';

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => setState(() => _selectedDate = d),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? activeDayBg : inactiveDayBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? activeDayBg : borderCol,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? (isDark ? activeDayFg.withValues(alpha: 0.8) : Colors.white70) : textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayNum,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? activeDayFg : textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasTasks
                                  ? (isSelected ? activeDayFg : activeDayBg)
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ── Selected Date Title ─────────────────────────────────────────────
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // ── Task List for Selected Date ─────────────────────────────────────
          Expanded(
            child: tasksForSelectedDate.isEmpty
                ? const Center(
                    child: EmptyState(
                      icon: Icons.calendar_today_outlined,
                      title: 'No deadlines on this date',
                      description: 'Enjoy your focused workflow or assign new milestones.',
                    ),
                  )
                : ListView.separated(
                    itemCount: tasksForSelectedDate.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = tasksForSelectedDate[index];
                      return _buildTaskCalendarCard(context, task);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCalendarCard(BuildContext context, TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.surfaceElevated;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : AppColors.borderHairline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextDisabled : AppColors.textTertiary;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          SlidePageRoute(
            builder: (_) => TaskDetailScreen(task: task),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
                StatusBadge.taskPriority(task.priority),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge.taskStatus(task.status),
                if (task.dueDate.isNotEmpty)
                  Text(
                    'Due ${task.dueDate}',
                    style: TextStyle(fontSize: 12, color: textTertiary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
