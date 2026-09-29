import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_filter_chips.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/empty_state.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/core/widgets/status_badge.dart';
import 'package:taskflow_flutter/features/leaves/data/models/leave_model.dart';
import 'package:taskflow_flutter/features/leaves/presentation/providers/leave_provider.dart';

class MyLeavesScreen extends ConsumerWidget {
  const MyLeavesScreen({super.key});

  void _showApplyLeaveSheet(BuildContext context, WidgetRef ref) {
    LeaveType selectedType = LeaveType.casual;
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    final reasonController = TextEditingController();
    bool isSubmitting = false;
    String? formError;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkBgElevated : AppColors.surfaceElevated;
    final inputBg = isDark ? AppColors.darkBgInput : AppColors.surfaceElevated;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.borderHairline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final errorBg = isDark ? AppColors.darkErrorBg : AppColors.errorBg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final dateFormat = DateFormat('yyyy-MM-dd');

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Apply for Leave',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                          onPressed: () => Navigator.pop(bottomSheetCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (formError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: errorBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.errorBorder),
                        ),
                        child: Text(
                          formError!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                    ],

                    // Leave Type
                    Text('Leave Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderCol),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<LeaveType>(
                          value: selectedType,
                          dropdownColor: sheetBg,
                          isExpanded: true,
                          items: LeaveType.values.map((t) {
                            return DropdownMenuItem<LeaveType>(
                              value: t,
                              child: Text(t.value, style: TextStyle(color: textPrimary)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setSheetState(() => selectedType = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date Pickers Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: startDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) {
                                    setSheetState(() {
                                      startDate = picked;
                                      if (endDate.isBefore(startDate)) endDate = startDate;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.borderHairline),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(dateFormat.format(startDate), style: const TextStyle(fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: endDate,
                                    firstDate: startDate,
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) setSheetState(() => endDate = picked);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.borderHairline),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(dateFormat.format(endDate), style: const TextStyle(fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Reason
                    AppTextField(
                      label: 'Reason for Leave',
                      hint: 'Medical appointment, family vacation, etc.',
                      controller: reasonController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    AppButton(
                      text: 'Submit Leave Request',
                      isLoading: isSubmitting,
                      onPressed: () async {
                        final dateErr = Validators.validateLeaveDates(
                          dateFormat.format(startDate),
                          dateFormat.format(endDate),
                        );
                        if (dateErr.startError != null || dateErr.endError != null) {
                          setSheetState(() => formError = dateErr.startError ?? dateErr.endError);
                          return;
                        }

                        final reason = reasonController.text.trim();
                        final reasonErr = Validators.validateLeaveReason(reason);
                        if (reasonErr != null) {
                          setSheetState(() => formError = reasonErr);
                          return;
                        }

                        setSheetState(() {
                          isSubmitting = true;
                          formError = null;
                        });

                        final success = await ref.read(leaveNotifierProvider.notifier).applyLeave(
                              leaveType: selectedType,
                              startDate: startDate,
                              endDate: endDate,
                              reason: reason,
                            );

                        if (success && bottomSheetCtx.mounted) {
                          Navigator.pop(bottomSheetCtx);
                        } else {
                          setSheetState(() {
                            isSubmitting = false;
                            formError = 'Failed to submit leave. Check for overlapping dates.';
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveState = ref.watch(leaveNotifierProvider);
    final filteredLeaves = ref.watch(filteredLeavesProvider);

    final tabs = ['All', 'Pending', 'Approved', 'Rejected'];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fabBg = isDark ? AppColors.darkAccentPrimary : AppColors.primary;
    final fabFg = isDark ? AppColors.darkAccentFg : AppColors.canvas;

    return ScreenWrapper(
      appBar: AppBar(
        title: const Text('My Leaves'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(leaveNotifierProvider.notifier).loadLeaves(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: fabBg,
        foregroundColor: fabFg,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Apply Leave'),
        onPressed: () => _showApplyLeaveSheet(context, ref),
      ),
      onRefresh: () => ref.read(leaveNotifierProvider.notifier).loadLeaves(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Tabs
          AppFilterChips<String>(
            items: tabs,
            selectedItem: leaveState.activeFilter,
            padding: EdgeInsets.zero,
            onSelected: (tab) {
              ref.read(leaveNotifierProvider.notifier).setFilter(tab);
            },
          ),

          const SizedBox(height: 16),

          if (leaveState.isLoading && leaveState.leaves.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filteredLeaves.isEmpty)
            EmptyState(
              icon: Icons.beach_access_outlined,
              title: 'No leave records',
              description: 'You have not submitted any leave requests matching this filter.',
              actionLabel: 'Apply for Leave',
              onAction: () => _showApplyLeaveSheet(context, ref),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredLeaves.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final leave = filteredLeaves[index];
                return _MyLeaveCard(
                  key: ValueKey('my_leave_${leave.id}'),
                  leave: leave,
                );
              },
            ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 96),
        ],
      ),
    );
  }
}

class _MyLeaveCard extends ConsumerWidget {
  final LeaveModel leave;

  const _MyLeaveCard({
    super.key,
    required this.leave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.surfaceElevated;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : AppColors.borderHairline;
    final chipBg = isDark ? AppColors.darkBgInput : AppColors.surfaceStone;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextDisabled : AppColors.textTertiary;

    final dateFormat = DateFormat('MMM d, yyyy');
    final dateRangeStr =
        '${dateFormat.format(leave.startDate)} - ${dateFormat.format(leave.endDate)}';

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  leave.leaveType.value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
              StatusBadge.leaveStatus(leave.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            dateRangeStr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: ${leave.totalDays} day(s)',
            style: TextStyle(fontSize: 12, color: textTertiary),
          ),
          const SizedBox(height: 8),
          Text(
            leave.reason,
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
          if (leave.status == LeaveStatus.pending) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await ref
                      .read(leaveNotifierProvider.notifier)
                      .cancelLeave(leave.id);
                },
                icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                label: const Text(
                  'Cancel Request',
                  style: TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
