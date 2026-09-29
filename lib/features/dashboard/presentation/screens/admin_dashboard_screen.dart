import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_card.dart';
import 'package:taskflow_flutter/core/widgets/empty_state.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/core/widgets/status_badge.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/auth/presentation/widgets/email_verification_banner.dart';
import 'package:taskflow_flutter/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:taskflow_flutter/features/employees/presentation/screens/employee_management_screen.dart';
import 'package:taskflow_flutter/features/leaves/presentation/screens/admin_leave_management_screen.dart';
import 'package:taskflow_flutter/features/navigation/presentation/admin_more_screen.dart';
import 'package:taskflow_flutter/features/reports/presentation/screens/reports_screen.dart';
import 'package:taskflow_flutter/features/settings/presentation/screens/settings_screen.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/admin_task_management_screen.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/create_task_screen.dart';
import 'package:taskflow_flutter/features/tasks/presentation/widgets/task_detail_modal.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final bgCard = isDark ? AppColors.darkCard : AppColors.card;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final accentPrimary = isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary;
    final accentFg = isDark ? AppColors.darkAccentFg : AppColors.accentFg;

    final tasksAsync = ref.watch(tasksProvider);
    final todayStr = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return ScreenWrapper(
      scrollable: true,
      dismissKeyboardOnTap: false,
      padding: EdgeInsets.zero,
      onRefresh: () async {
        ref.invalidate(tasksProvider);
        ref.invalidate(adminStatsProvider);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            todayStr,
                            style: TextStyle(
                              fontSize: AppTypography.fontSizeXs,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const AppBadge(
                            label: 'Admin',
                            bgColor: AppColors.errorBg,
                            textColor: AppColors.error,
                            size: BadgeSize.sm,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user?.firstName ?? 'Admin'} Workspace',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: AppTypography.fontWeightBold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Organization oversight & team management',
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeXs,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Settings Icon Button
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          SlidePageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: bgCard,
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          border: Border.all(color: borderSubtle),
                        ),
                        child: Center(
                          child: Icon(Icons.settings_outlined, size: 18, color: textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Avatar Circle
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          SlidePageRoute(builder: (_) => const AdminMoreScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(19),
                      child: CircleAvatar(
                        radius: 19,
                        backgroundColor: accentPrimary,
                        child: Text(
                          user?.firstName.isNotEmpty == true ? user!.firstName[0].toUpperCase() : 'A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: accentFg,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Email Verification Reminder Banner
            const EmailVerificationBanner(),

            const SizedBox(height: AppSpacing.md),

            // Quick Actions Row (4 buttons)
            Row(
              children: [
                _buildQuickActionBtn(
                  context,
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Assign Task',
                  isDark: isDark,
                  onTap: () => Navigator.of(context).push(
                    SlidePageRoute(builder: (_) => const CreateTaskScreen()),
                  ),
                ),
                const SizedBox(width: 8),
                _buildQuickActionBtn(
                  context,
                  icon: Icons.people_outline_rounded,
                  label: 'Employees',
                  isDark: isDark,
                  onTap: () => Navigator.of(context).push(
                    SlidePageRoute(builder: (_) => const EmployeeManagementScreen()),
                  ),
                ),
                const SizedBox(width: 8),
                _buildQuickActionBtn(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Leaves',
                  isDark: isDark,
                  onTap: () => Navigator.of(context).push(
                    SlidePageRoute(builder: (_) => const AdminLeaveManagementScreen()),
                  ),
                ),
                const SizedBox(width: 8),
                _buildQuickActionBtn(
                  context,
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  isDark: isDark,
                  onTap: () => Navigator.of(context).push(
                    SlidePageRoute(builder: (_) => const ReportsScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Main tasks & KPIs content
            tasksAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: AppColors.errorBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Failed to load dashboard: $err',
                        style: const TextStyle(color: AppColors.error, fontSize: AppTypography.fontSizeXs),
                      ),
                    ),
                  ],
                ),
              ),
              data: (tasks) {
                final totalTasks = tasks.length;
                final pendingCount = tasks.where((t) => t.status == TaskStatus.pending).length;
                final inProgressCount = tasks.where((t) => t.status == TaskStatus.inProgress).length;
                final completedCount = tasks.where((t) => t.status == TaskStatus.completed).length;

                final recentTasks = [...tasks]
                  ..sort((a, b) => (b.createdAt ?? DateTime.now())
                      .compareTo(a.createdAt ?? DateTime.now()));
                final topRecent = recentTasks.take(4).toList();

                if (totalTasks == 0) {
                  // Onboarding Card for fresh workspaces
                  return AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkBgInput : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(Icons.auto_awesome, color: Color(0xFF2563EB), size: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Get Started with TaskFlow',
                                    style: TextStyle(
                                      fontSize: AppTypography.fontSizeSm,
                                      fontWeight: AppTypography.fontWeightBold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Complete these steps to set up your team workflow:',
                                    style: TextStyle(
                                      fontSize: AppTypography.fontSizeTiny,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildOnboardingStep(
                          step: 1,
                          title: 'Assign your first task',
                          desc: 'Set deadlines, priorities, and delegate to teammates.',
                          isDark: isDark,
                          onTap: () => Navigator.of(context).push(
                            SlidePageRoute(builder: (_) => const CreateTaskScreen()),
                          ),
                        ),
                        _buildOnboardingStep(
                          step: 2,
                          title: 'Build your team directory',
                          desc: 'View members, departments, and active statuses.',
                          isDark: isDark,
                          onTap: () => Navigator.of(context).push(
                            SlidePageRoute(builder: (_) => const EmployeeManagementScreen()),
                          ),
                        ),
                        _buildOnboardingStep(
                          step: 3,
                          title: 'Workspace preferences',
                          desc: 'Theme appearance and backend connection settings.',
                          isDark: isDark,
                          isLast: true,
                          onTap: () => Navigator.of(context).push(
                            SlidePageRoute(builder: (_) => const SettingsScreen()),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                void navigateToTasks(String filter) {
                  ref.read(tasksNotifierProvider.notifier).setFilter(filter);
                  ref.read(tasksNotifierProvider.notifier).setSearchQuery('');
                  Navigator.of(context).push(
                    SlidePageRoute(
                      builder: (_) => AdminTaskManagementScreen(initialFilter: filter),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 4 Stat Metric Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Tasks',
                            count: totalTasks,
                            icon: Icons.list_alt_rounded,
                            iconColor: const Color(0xFF2563EB),
                            iconBg: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
                            isDark: isDark,
                            onTap: () => navigateToTasks('All'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Pending',
                            count: pendingCount,
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFFD97706),
                            iconBg: isDark ? const Color(0xFF3D2B0A) : const Color(0xFFFEF3C7),
                            isDark: isDark,
                            onTap: () => navigateToTasks('Pending'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'In Progress',
                            count: inProgressCount,
                            icon: Icons.trending_up_rounded,
                            iconColor: const Color(0xFF0284C7),
                            iconBg: isDark ? const Color(0xFF0C2A3D) : const Color(0xFFE0F2FE),
                            isDark: isDark,
                            onTap: () => navigateToTasks('In Progress'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Completed',
                            count: completedCount,
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: const Color(0xFF059669),
                            iconBg: isDark ? const Color(0xFF0A2E1E) : const Color(0xFFD1FAE5),
                            isDark: isDark,
                            onTap: () => navigateToTasks('Completed'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Visual Workload Distribution Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workload Distribution',
                            style: TextStyle(
                              fontSize: AppTypography.fontSizeSm,
                              fontWeight: AppTypography.fontWeightBold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Stacked Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              height: 10,
                              child: Row(
                                children: [
                                  if (completedCount > 0)
                                    Expanded(
                                      flex: completedCount,
                                      child: Container(
                                        color: isDark
                                            ? const Color(0xFF10B981).withValues(alpha: 0.8)
                                            : const Color(0xFF10B981),
                                      ),
                                    ),
                                  if (inProgressCount > 0)
                                    Expanded(
                                      flex: inProgressCount,
                                      child: Container(
                                        color: isDark
                                            ? const Color(0xFF0284C7).withValues(alpha: 0.8)
                                            : const Color(0xFF0284C7),
                                      ),
                                    ),
                                  if (pendingCount > 0)
                                    Expanded(
                                      flex: pendingCount,
                                      child: Container(
                                        color: isDark
                                            ? const Color(0xFFF59E0B).withValues(alpha: 0.8)
                                            : const Color(0xFFF59E0B),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Legend Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildLegendItem('Done ($completedCount)', const Color(0xFF10B981), textSecondary),
                              _buildLegendItem('Active ($inProgressCount)', const Color(0xFF0284C7), textSecondary),
                              _buildLegendItem('Pending ($pendingCount)', const Color(0xFFF59E0B), textSecondary),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Recent Tasks Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Tasks',
                          style: TextStyle(
                            fontSize: AppTypography.fontSizeBase,
                            fontWeight: AppTypography.fontWeightBold,
                            color: textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: () => navigateToTasks('All'),
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: AppTypography.fontSizeSm,
                              fontWeight: AppTypography.fontWeightBold,
                              color: accentPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    if (topRecent.isEmpty)
                      EmptyState(
                        icon: Icons.task_alt_rounded,
                        title: 'No tasks yet',
                        description: "You don't have any tasks yet. Assign one to get started.",
                        actionTitle: '+ Assign Task',
                        onAction: () => Navigator.of(context).push(
                          SlidePageRoute(builder: (_) => const CreateTaskScreen()),
                        ),
                      )
                    else
                      ...topRecent.map((task) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: AppCard(
                            onTap: () => showTaskDetailModal(
                              context,
                              task,
                              onTaskUpdated: () => ref.invalidate(tasksProvider),
                            ),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: AppTypography.fontSizeSm,
                                          fontWeight: AppTypography.fontWeightBold,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TaskStatusBadge.fromModel(task.status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      task.assignedUser?.fullName ?? 'Unassigned',
                                      style: TextStyle(
                                        fontSize: AppTypography.fontSizeXs,
                                        color: textSecondary,
                                      ),
                                    ),
                                    PriorityBadge.fromModel(task.priority),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgCard = isDark ? AppColors.darkCard : AppColors.card;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final accentPrimary = isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(color: borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: accentPrimary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: AppTypography.fontWeightMedium,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgCard = isDark ? AppColors.darkCard : AppColors.card;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(AppBorderRadius.card),
          border: Border.all(color: borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: AppTypography.fontWeightBold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: AppTypography.fontSizeXs,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String text, Color dotColor, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: textColor),
        ),
      ],
    );
  }

  Widget _buildOnboardingStep({
    required int step,
    required String title,
    required String desc,
    required bool isDark,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final overlayMedium = isDark ? AppColors.darkOverlayMedium : AppColors.overlayMedium;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: borderSubtle)),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: overlayMedium, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '$step',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textPrimary),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeXs,
                      fontWeight: AppTypography.fontWeightBold,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 10, color: textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: textSecondary),
          ],
        ),
      ),
    );
  }
}
