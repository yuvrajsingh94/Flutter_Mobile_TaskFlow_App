import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';

void showTaskStatusUpdateModal(
  BuildContext context,
  TaskModel task, {
  VoidCallback? onSuccess,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => TaskStatusUpdateModal(
      task: task,
      onSuccess: onSuccess,
    ),
  );
}

class TaskStatusUpdateModal extends ConsumerStatefulWidget {
  final TaskModel task;
  final VoidCallback? onSuccess;

  const TaskStatusUpdateModal({
    super.key,
    required this.task,
    this.onSuccess,
  });

  static void show(
    BuildContext context,
    TaskModel task, {
    VoidCallback? onSuccess,
  }) {
    showTaskStatusUpdateModal(context, task, onSuccess: onSuccess);
  }

  @override
  ConsumerState<TaskStatusUpdateModal> createState() => _TaskStatusUpdateModalState();
}

class _TaskStatusUpdateModalState extends ConsumerState<TaskStatusUpdateModal> {
  late TaskStatus _selectedStatus;
  late int _progress;
  bool _isUpdating = false;

  final List<TaskStatus> _statuses = [
    TaskStatus.pending,
    TaskStatus.inProgress,
    TaskStatus.completed,
  ];

  final List<int> _progressPresets = [0, 25, 50, 75, 100];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status;
    _progress = widget.task.progress;
  }

  Future<void> _handleUpdate() async {
    setState(() => _isUpdating = true);

    try {
      final dio = ref.read(dioClientProvider);
      final finalProgress = _selectedStatus == TaskStatus.completed ? 100 : _progress;

      final res = await dio.put(
        ApiEndpoints.taskById(widget.task.id),
        data: {
          'status': _selectedStatus.value,
          'progress': finalProgress,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        widget.onSuccess?.call();
        if (mounted) Navigator.of(context).pop();
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
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
    final accentFg = isDark ? AppColors.darkAccentFg : AppColors.accentFg;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: borderInput,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Update Task Status',
                style: TextStyle(
                  fontSize: AppTypography.fontSizeBase,
                  fontWeight: AppTypography.fontWeightBold,
                  color: textPrimary,
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

          const SizedBox(height: AppSpacing.sm),

          // Task Title
          Text(
            widget.task.title,
            style: TextStyle(
              fontSize: AppTypography.fontSizeSm,
              color: textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Select Status
          Text(
            'SELECT STATUS',
            style: TextStyle(
              fontSize: AppTypography.fontSizeTiny,
              fontWeight: AppTypography.fontWeightBold,
              letterSpacing: 0.8,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          Row(
            children: _statuses.map((s) {
              final isSelected = _selectedStatus == s;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedStatus = s;
                        if (s == TaskStatus.completed) _progress = 100;
                        if (s == TaskStatus.pending) _progress = 0;
                      });
                    },
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? accentPrimary : bgInput,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(
                          color: isSelected ? accentPrimary : borderInput,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          s.value,
                          style: TextStyle(
                            fontSize: AppTypography.fontSizeXs,
                            fontWeight: isSelected
                                ? AppTypography.fontWeightBold
                                : AppTypography.fontWeightMedium,
                            color: isSelected ? accentFg : textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Completion Progress Presets
          Text(
            'COMPLETION: $_progress%',
            style: TextStyle(
              fontSize: AppTypography.fontSizeTiny,
              fontWeight: AppTypography.fontWeightBold,
              letterSpacing: 0.8,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          Row(
            children: _progressPresets.map((p) {
              final isSelected = _progress == p;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () => setState(() => _progress = p),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentPrimary
                            : (isDark ? AppColors.darkOverlayMedium : AppColors.overlayMedium),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        border: Border.all(
                          color: isSelected ? accentPrimary : borderSubtle,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$p%',
                          style: TextStyle(
                            fontSize: AppTypography.fontSizeXs,
                            fontWeight: isSelected
                                ? AppTypography.fontWeightBold
                                : AppTypography.fontWeightMedium,
                            color: isSelected ? accentFg : textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Submit Button
          AppButton(
            title: 'Save Changes',
            loading: _isUpdating,
            variant: ButtonVariant.primary,
            size: ButtonSize.lg,
            onPressed: _handleUpdate,
          ),
        ],
      ),
    );
  }
}
