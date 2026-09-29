import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/profile_avatar.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/presentation/providers/task_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _timeFilter = 'month'; // 'month' | 'year'
  List<UserProfile> _employees = [];
  bool _isLoadingEmployees = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final users = await repo.getAllUsers();
      if (mounted) {
        setState(() {
          _employees = users.where((u) => u.isEmployee).toList();
          _isLoadingEmployees = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingEmployees = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskState = ref.watch(taskNotifierProvider);
    final allTasks = taskState.tasks;

    final now = DateTime.now();
    final filteredTasks = allTasks.where((t) {
      final parsedDate = DateTime.tryParse(t.dueDate) ?? t.createdAt;
      if (parsedDate == null) return true;
      if (_timeFilter == 'month') {
        return parsedDate.month == now.month && parsedDate.year == now.year;
      }
      return parsedDate.year == now.year;
    }).toList();

    final total = filteredTasks.length;
    final completed =
        filteredTasks.where((t) => t.status == TaskStatus.completed).length;
    final inProgress =
        filteredTasks.where((t) => t.status == TaskStatus.inProgress).length;
    final pending =
        filteredTasks.where((t) => t.status == TaskStatus.pending).length;
    final blocked =
        filteredTasks.where((t) => t.status == TaskStatus.blocked).length;

    final completionRate =
        total > 0 ? ((completed / total) * 100).round() : 0;

    final highPriority =
        filteredTasks.where((t) => t.priority == TaskPriority.high).length;
    final mediumPriority =
        filteredTasks.where((t) => t.priority == TaskPriority.medium).length;
    final lowPriority =
        filteredTasks.where((t) => t.priority == TaskPriority.low).length;

    // Leaderboard calculation
    final leaderboard = _employees.map((emp) {
      final empTasks = filteredTasks.where((t) =>
          t.assignedUserId == emp.id || t.assignedUser?.id == emp.id);
      final done =
          empTasks.where((t) => t.status == TaskStatus.completed).length;
      final totalAssigned = empTasks.length;
      final rate =
          totalAssigned > 0 ? ((done / totalAssigned) * 100).round() : 0;
      return _LeaderboardEntry(
        employee: emp,
        totalAssigned: totalAssigned,
        completedCount: done,
        rate: rate,
      );
    }).toList()
      ..sort((a, b) => b.completedCount.compareTo(a.completedCount));

    final cardBg = isDark ? AppColors.darkBgCard : AppColors.lightBgCard;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderInput;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final progressTrack = isDark ? AppColors.darkBgInput : AppColors.lightBgSidebar;

    return ScreenWrapper(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reports & Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              'Data-driven productivity insights',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Time Filter Toggle ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _buildTimeFilterBtn('This Month', 'month', isDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTimeFilterBtn('This Year', 'year', isDark),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Completion Rate Card ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: total > 0 ? completed / total : 0,
                        strokeWidth: 7,
                        backgroundColor: progressTrack,
                        color: AppColors.success,
                      ),
                      Text(
                        '$completionRate%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Completion Rate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completed of $total tasks completed successfully',
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Status Distribution Grid ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _buildStatTile('Completed', '$completed', AppColors.success,
                    Icons.check_circle_outline_rounded, isDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatTile('In Progress', '$inProgress',
                    AppColors.primary, Icons.play_arrow_outlined, isDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatTile('Pending', '$pending', AppColors.warning,
                    Icons.hourglass_empty_rounded, isDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatTile('Blocked', '$blocked', AppColors.error,
                    Icons.block_flipped, isDark),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Priority Distribution ───────────────────────────────────────────
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
                Text(
                  'Priority Breakdown',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _buildPriorityRow('High Priority', highPriority, total, AppColors.error, isDark),
                const SizedBox(height: 10),
                _buildPriorityRow('Medium Priority', mediumPriority, total, AppColors.warning, isDark),
                const SizedBox(height: 10),
                _buildPriorityRow('Low Priority', lowPriority, total, AppColors.info, isDark),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Leaderboard Section ─────────────────────────────────────────────
          Text(
            'Employee Performance Leaderboard',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (_isLoadingEmployees)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (leaderboard.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'No employee task activity for this period.',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                return _buildLeaderboardTile(entry, index, isDark);
              },
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTimeFilterBtn(String label, String value, bool isDark) {
    final isSelected = _timeFilter == value;
    final unselectedBg = isDark ? AppColors.darkBgInput : AppColors.lightBgInput;
    final unselectedBorder = isDark ? AppColors.darkBorderInput : AppColors.lightBorderInput;
    final unselectedFg = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final selectedBg = isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary;
    final selectedFg = isDark ? AppColors.darkAccentFg : AppColors.lightAccentFg;

    return InkWell(
      onTap: () => setState(() => _timeFilter = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? selectedBg : unselectedBorder,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? selectedFg : unselectedFg,
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(
      String label, String value, Color color, IconData icon, bool isDark) {
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.lightBgCard;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderInput;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityRow(
      String label, int count, int total, Color color, bool isDark) {
    final pct = total > 0 ? (count / total) : 0.0;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final progressTrack = isDark ? AppColors.darkBgInput : AppColors.lightBgSidebar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            Text(
              '$count tasks',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.toDouble(),
            minHeight: 6,
            backgroundColor: progressTrack,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(_LeaderboardEntry entry, int index, bool isDark) {
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.lightBgCard;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderInput;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textTertiary = isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;
    final successBg = isDark ? AppColors.darkSuccessBg : AppColors.lightSuccessBg;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;

    Widget rankWidget;
    if (index == 0) {
      rankWidget = const Icon(Icons.emoji_events_rounded,
          size: 24, color: Color(0xFFF59E0B));
    } else if (index == 1) {
      rankWidget = const Icon(Icons.military_tech_rounded,
          size: 24, color: Color(0xFF94A3B8));
    } else if (index == 2) {
      rankWidget = const Icon(Icons.military_tech_outlined,
          size: 24, color: Color(0xFFD97706));
    } else {
      rankWidget = Text(
        '#${index + 1}',
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textTertiary),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          SizedBox(width: 32, child: Center(child: rankWidget)),
          const SizedBox(width: 10),
          ProfileAvatar(
            imageUrl: entry.employee.profilePicture,
            name: entry.employee.fullName,
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.employee.fullName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                Text(
                  '${entry.completedCount} of ${entry.totalAssigned} completed',
                  style: TextStyle(fontSize: 11, color: textTertiary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: successBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${entry.rate}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEntry {
  final UserProfile employee;
  final int totalAssigned;
  final int completedCount;
  final int rate;

  _LeaderboardEntry({
    required this.employee,
    required this.totalAssigned,
    required this.completedCount,
    required this.rate,
  });
}
