import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/status_badge.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/presentation/widgets/task_status_update_modal.dart';

void showTaskDetailModal(
  BuildContext context,
  TaskModel task, {
  VoidCallback? onTaskUpdated,
  bool canUpdateStatus = true,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => TaskDetailModal(
      task: task,
      onTaskUpdated: onTaskUpdated,
      canUpdateStatus: canUpdateStatus,
    ),
  );
}

class TaskDetailModal extends ConsumerStatefulWidget {
  final TaskModel task;
  final VoidCallback? onTaskUpdated;
  final bool canUpdateStatus;

  const TaskDetailModal({
    super.key,
    required this.task,
    this.onTaskUpdated,
    this.canUpdateStatus = true,
  });

  @override
  ConsumerState<TaskDetailModal> createState() => _TaskDetailModalState();
}

class _TaskDetailModalState extends ConsumerState<TaskDetailModal> {
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  late TaskModel _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmittingComment = true);

    try {
      final dio = ref.read(dioClientProvider);
      final res = await dio.post(
        '${ApiEndpoints.tasks}/${_currentTask.id}/comments',
        data: {'text': text},
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        _commentController.clear();
        widget.onTaskUpdated?.call();
        // Refresh local task data if needed
        final updatedRes = await dio.get(ApiEndpoints.taskById(_currentTask.id));
        if (updatedRes.statusCode == 200 && updatedRes.data != null) {
          final data = updatedRes.data['task'] ?? updatedRes.data;
          setState(() {
            _currentTask = TaskModel.fromJson(data);
          });
        }
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isSubmittingComment = false);
    }
  }

  String _formatDueDate(String dateStr) {
    if (dateStr.isEmpty) return 'No due date';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return DateFormat('MMM d, yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCard = isDark ? AppColors.darkCard : AppColors.card;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final borderInput = isDark ? AppColors.darkBorderInput : AppColors.borderInput;
    final bgInput = isDark ? AppColors.darkBgInput : AppColors.bgInput;
    final accentPrimary = isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary;

    final progress = _currentTask.progress;
    final assigneeName = _currentTask.assignedUser?.fullName ??
        (_currentTask.assignedUserId != null ? 'Assigned' : 'Unassigned');
    final assigneeInitial = assigneeName.isNotEmpty ? assigneeName[0].toUpperCase() : '?';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: borderInput,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _currentTask.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeBase,
                      fontWeight: AppTypography.fontWeightBold,
                      color: textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          Divider(color: borderSubtle, height: 1),

          // Content Scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges & Meta Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '#${_currentTask.id.length > 6 ? _currentTask.id.substring(_currentTask.id.length - 6).toUpperCase() : _currentTask.id}',
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeXs,
                          fontWeight: AppTypography.fontWeightBold,
                          color: textSecondary,
                        ),
                      ),
                      TaskStatusBadge.fromModel(_currentTask.status),
                      PriorityBadge.fromModel(_currentTask.priority),
                      if (_currentTask.category.isNotEmpty)
                        AppBadge(
                          label: _currentTask.category,
                          bgColor: isDark ? AppColors.darkOverlayMedium : AppColors.overlayMedium,
                          textColor: textPrimary,
                          size: BadgeSize.sm,
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Description
                  Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeTiny,
                      fontWeight: AppTypography.fontWeightBold,
                      letterSpacing: 0.8,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentTask.description.isNotEmpty
                        ? _currentTask.description
                        : 'No description provided.',
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeSm,
                      color: textPrimary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PROGRESS',
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeTiny,
                          fontWeight: AppTypography.fontWeightBold,
                          letterSpacing: 0.8,
                          color: textSecondary,
                        ),
                      ),
                      Text(
                        '$progress%',
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeXs,
                          fontWeight: AppTypography.fontWeightBold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (progress / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: isDark ? AppColors.darkOverlayStrong : AppColors.overlayStrong,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 100 ? AppColors.success : accentPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Info Card (Assigned To, Due Date, Created At)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkOverlayLight : AppColors.overlayLight,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(color: borderSubtle),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: accentPrimary,
                              child: Text(
                                assigneeInitial,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkAccentFg : AppColors.accentFg,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assigned To',
                                    style: TextStyle(fontSize: 10, color: textSecondary),
                                  ),
                                  Text(
                                    assigneeName,
                                    style: TextStyle(
                                      fontSize: AppTypography.fontSizeSm,
                                      fontWeight: AppTypography.fontWeightMedium,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Divider(color: borderSubtle, height: 1),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 16, color: textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Due Date',
                                    style: TextStyle(fontSize: 10, color: textSecondary),
                                  ),
                                  Text(
                                    _formatDueDate(_currentTask.dueDate),
                                    style: TextStyle(
                                      fontSize: AppTypography.fontSizeSm,
                                      fontWeight: AppTypography.fontWeightMedium,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Comments Section
                  Text(
                    'COMMENTS (${_currentTask.comments.length})',
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeTiny,
                      fontWeight: AppTypography.fontWeightBold,
                      letterSpacing: 0.8,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // List of comments
                  if (_currentTask.comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No comments yet. Start the conversation!',
                        style: TextStyle(fontSize: AppTypography.fontSizeXs, color: textSecondary),
                      ),
                    )
                  else
                    ..._currentTask.comments.map((c) {
                      final cAuthor = c.user?.fullName ?? 'Teammate';
                      final cInitial = cAuthor.isNotEmpty ? cAuthor[0].toUpperCase() : 'U';
                      final cDate = DateFormat('MMM d, h:mm a').format(c.createdAt);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkOverlayLight : AppColors.overlayLight,
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          border: Border.all(color: borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: accentPrimary,
                                  child: Text(
                                    cInitial,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? AppColors.darkAccentFg : AppColors.accentFg,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cAuthor,
                                  style: TextStyle(
                                    fontSize: AppTypography.fontSizeXs,
                                    fontWeight: AppTypography.fontWeightBold,
                                    color: textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  cDate,
                                  style: TextStyle(fontSize: 10, color: textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.text,
                              style: TextStyle(fontSize: AppTypography.fontSizeXs, color: textPrimary),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: AppSpacing.sm),

                  // Comment Input
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: bgInput,
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                            border: Border.all(color: borderInput),
                          ),
                          child: TextField(
                            controller: _commentController,
                            style: TextStyle(fontSize: AppTypography.fontSizeSm, color: textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: TextStyle(
                                fontSize: AppTypography.fontSizeSm,
                                color: isDark ? AppColors.darkTextPlaceholder : AppColors.textPlaceholder,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isSubmittingComment ? null : _submitComment,
                        icon: _isSubmittingComment
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.send_rounded, color: accentPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          if (widget.canUpdateStatus)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      title: 'Update Status',
                      variant: ButtonVariant.primary,
                      size: ButtonSize.md,
                      onPressed: () {
                        showTaskStatusUpdateModal(
                          context,
                          _currentTask,
                          onSuccess: () {
                            widget.onTaskUpdated?.call();
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
