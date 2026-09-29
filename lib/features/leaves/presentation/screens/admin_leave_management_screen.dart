import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_filter_chips.dart';
import 'package:taskflow_flutter/core/widgets/empty_state.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/core/widgets/status_badge.dart';
import 'package:taskflow_flutter/features/leaves/data/models/leave_model.dart';
import 'package:taskflow_flutter/features/leaves/presentation/providers/leave_provider.dart';
import 'package:taskflow_flutter/features/leaves/presentation/widgets/admin_leave_review_modal.dart';

class AdminLeaveManagementScreen extends ConsumerWidget {
  const AdminLeaveManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Explicitly subscribe to Theme changes so the entire screen rebuilds immediately on theme toggle
    Theme.of(context);
    final leaveState = ref.watch(leaveNotifierProvider);
    final filteredLeaves = ref.watch(filteredLeavesProvider);

    final tabs = ['All', 'Pending', 'Approved', 'Rejected'];

    return ScreenWrapper(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        title: const Text('Leave Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.read(leaveNotifierProvider.notifier).loadLeaves(),
          ),
        ],
      ),
      onRefresh: () => ref.read(leaveNotifierProvider.notifier).loadLeaves(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Filter Tabs (Edge-to-edge scrollable with 16px gutters)
          AppFilterChips<String>(
            items: tabs,
            selectedItem: leaveState.activeFilter,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            onSelected: (tab) {
              ref.read(leaveNotifierProvider.notifier).setFilter(tab);
            },
          ),

          const SizedBox(height: 16),

          // Leaves List (padded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: leaveState.isLoading && leaveState.leaves.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : filteredLeaves.isEmpty
                    ? const EmptyState(
                        icon: Icons.event_available_outlined,
                        title: 'No leave requests',
                        description: 'There are no leave requests matching the selected status.',
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredLeaves.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final leave = filteredLeaves[index];
                          return _AdminLeaveCard(
                            key: ValueKey('admin_leave_${leave.id}'),
                            leave: leave,
                          );
                        },
                      ),
          ),

          // Generous bottom clearance to prevent bottom navigation bar overlap
          SizedBox(height: MediaQuery.of(context).padding.bottom + 96),
        ],
      ),
    );
  }
}

class _AdminLeaveCard extends ConsumerWidget {
  final LeaveModel leave;

  const _AdminLeaveCard({
    super.key,
    required this.leave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.lightBgCard;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderInput;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;
    final chipBg = isDark ? AppColors.darkBgInput : AppColors.lightBgSidebar;

    final dateFormat = DateFormat('MMM d, yyyy');
    final dateRangeStr = '${dateFormat.format(leave.startDate)} - ${dateFormat.format(leave.endDate)}';

    return Container(
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
                leave.employeeName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
              ),
              StatusBadge.leaveStatus(leave.status),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  leave.leaveType.value,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
                ),
              ),
              Text(
                '${leave.totalDays} day(s)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
              ),
              Text('•', style: TextStyle(color: textTertiary)),
              Text(
                dateRangeStr,
                style: TextStyle(fontSize: 12, color: textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            leave.reason,
            style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
          ),
          if (leave.status == LeaveStatus.pending) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    AdminLeaveReviewModal.show(
                      context,
                      leave,
                      onSuccess: () => ref.read(leaveNotifierProvider.notifier).loadLeaves(),
                    );
                  },
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                  label: const Text(
                    'Reject',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.error.withValues(alpha: 0.35)
                          : AppColors.error.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    backgroundColor: isDark
                        ? AppColors.error.withValues(alpha: 0.08)
                        : AppColors.error.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(leaveNotifierProvider.notifier)
                        .updateStatus(leave.id, 'Approved');
                    ref.read(leaveNotifierProvider.notifier).loadLeaves();
                  },
                  icon: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: isDark ? AppColors.darkAccentFg : AppColors.lightAccentFg,
                  ),
                  label: Text(
                    'Approve',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkAccentFg : AppColors.lightAccentFg,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
