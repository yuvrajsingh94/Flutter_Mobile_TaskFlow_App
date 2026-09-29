import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/leaves/data/models/leave_model.dart';

enum BadgeSize { sm, md }

/// 1-to-1 Replica of React Native TaskStatusBadge.tsx
class TaskStatusBadge extends StatelessWidget {
  final String status;
  final BadgeSize size;

  const TaskStatusBadge({
    super.key,
    required this.status,
    this.size = BadgeSize.sm,
  });

  factory TaskStatusBadge.fromModel(TaskStatus taskStatus, {BadgeSize size = BadgeSize.sm}) {
    String label;
    switch (taskStatus) {
      case TaskStatus.inProgress:
        label = 'In Progress';
        break;
      case TaskStatus.review:
        label = 'Review';
        break;
      case TaskStatus.completed:
        label = 'Completed';
        break;
      case TaskStatus.blocked:
        label = 'Blocked';
        break;
      case TaskStatus.pending:
        label = 'Pending';
        break;
    }
    return TaskStatusBadge(status: label, size: size);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color textColor;

    final norm = status.trim().toLowerCase();
    if (norm == 'in progress') {
      bg = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.35) : const Color(0xFFEFF6FF);
      textColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
    } else if (norm == 'review' || norm == 'on hold') {
      bg = isDark ? const Color(0xFF78350F).withValues(alpha: 0.35) : const Color(0xFFFEF3C7);
      textColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309);
    } else if (norm == 'completed') {
      bg = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFDCFCE7);
      textColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D);
    } else if (norm == 'blocked') {
      bg = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.35) : const Color(0xFFFEE2E2);
      textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
    } else {
      // Pending / default
      bg = isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6);
      textColor = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF4B5563);
    }

    final isSm = size == BadgeSize.sm;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSm ? 8 : 10,
        vertical: isSm ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppBorderRadius.pill),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: isSm ? AppTypography.fontSizeTiny : AppTypography.fontSizeXs,
          fontWeight: AppTypography.fontWeightSemibold,
        ),
      ),
    );
  }
}

/// 1-to-1 Replica of React Native PriorityBadge.tsx with dot indicator
class PriorityBadge extends StatelessWidget {
  final String priority;
  final BadgeSize size;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.size = BadgeSize.sm,
  });

  factory PriorityBadge.fromModel(TaskPriority taskPriority, {BadgeSize size = BadgeSize.sm}) {
    String label;
    switch (taskPriority) {
      case TaskPriority.high:
        label = 'High';
        break;
      case TaskPriority.medium:
        label = 'Medium';
        break;
      case TaskPriority.low:
        label = 'Low';
        break;
    }
    return PriorityBadge(priority: label, size: size);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color dotColor;
    Color textColor;

    final norm = priority.trim().toLowerCase();
    if (norm == 'urgent') {
      bg = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.35) : const Color(0xFFFEE2E2);
      dotColor = const Color(0xFFEF4444);
      textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
    } else if (norm == 'high') {
      bg = isDark ? const Color(0xFF78350F).withValues(alpha: 0.35) : const Color(0xFFFEF3C7);
      dotColor = const Color(0xFFF59E0B);
      textColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309);
    } else if (norm == 'medium') {
      bg = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.35) : const Color(0xFFEFF6FF);
      dotColor = const Color(0xFF3B82F6);
      textColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
    } else {
      // Low / default
      bg = isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6);
      dotColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
      textColor = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF4B5563);
    }

    final isSm = size == BadgeSize.sm;
    final dotSize = isSm ? 6.0 : 7.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSm ? 8 : 10,
        vertical: isSm ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppBorderRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            priority,
            style: TextStyle(
              color: textColor,
              fontSize: isSm ? AppTypography.fontSizeTiny : AppTypography.fontSizeXs,
              fontWeight: AppTypography.fontWeightSemibold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 1-to-1 Replica of React Native LeaveStatusBadge.tsx
class LeaveStatusBadge extends StatelessWidget {
  final String status;
  final BadgeSize size;

  const LeaveStatusBadge({
    super.key,
    required this.status,
    this.size = BadgeSize.md,
  });

  factory LeaveStatusBadge.fromModel(LeaveStatus leaveStatus, {BadgeSize size = BadgeSize.md}) {
    String label;
    switch (leaveStatus) {
      case LeaveStatus.approved:
        label = 'Approved';
        break;
      case LeaveStatus.rejected:
        label = 'Rejected';
        break;
      case LeaveStatus.cancelled:
        label = 'Cancelled';
        break;
      case LeaveStatus.pending:
        label = 'Pending';
        break;
    }
    return LeaveStatusBadge(status: label, size: size);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color textColor;

    final norm = status.trim().toLowerCase();
    if (norm == 'approved') {
      bg = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFD1FAE5);
      textColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF047857);
    } else if (norm == 'rejected') {
      bg = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.35) : const Color(0xFFFEE2E2);
      textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
    } else if (norm == 'cancelled') {
      bg = isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6);
      textColor = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF4B5563);
    } else {
      // Pending
      bg = isDark ? const Color(0xFF78350F).withValues(alpha: 0.35) : const Color(0xFFFEF3C7);
      textColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309);
    }

    final isSm = size == BadgeSize.sm;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSm ? 6 : 10,
        vertical: isSm ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppBorderRadius.round),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: isSm ? AppTypography.fontSizeXs : AppTypography.fontSizeSm,
          fontWeight: AppTypography.fontWeightSemibold,
        ),
      ),
    );
  }
}

/// Generic Badge (Badge.tsx)
class AppBadge extends StatelessWidget {
  final String label;
  final Color? bgColor;
  final Color textColor;
  final bool outline;
  final BadgeSize size;

  const AppBadge({
    super.key,
    required this.label,
    this.bgColor,
    this.textColor = const Color(0xFF1F2937),
    this.outline = false,
    this.size = BadgeSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final isSm = size == BadgeSize.sm;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSm ? 6 : 10,
        vertical: isSm ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : (bgColor ?? Colors.black.withValues(alpha: 0.05)),
        border: outline ? Border.all(color: textColor, width: 1) : null,
        borderRadius: BorderRadius.circular(AppBorderRadius.round),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: isSm ? AppTypography.fontSizeXs : AppTypography.fontSizeSm,
          fontWeight: AppTypography.fontWeightSemibold,
        ),
      ),
    );
  }
}

/// Legacy alias for backwards compatibility
class StatusBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    this.icon,
  });

  factory StatusBadge.taskStatus(TaskStatus status) {
    String label;
    switch (status) {
      case TaskStatus.inProgress:
        label = 'In Progress';
        break;
      case TaskStatus.review:
        label = 'Review';
        break;
      case TaskStatus.completed:
        label = 'Completed';
        break;
      case TaskStatus.blocked:
        label = 'Blocked';
        break;
      case TaskStatus.pending:
        label = 'Pending';
        break;
    }
    return StatusBadge(
      label: label,
      textColor: AppColors.textPrimary,
      backgroundColor: AppColors.card,
      borderColor: AppColors.borderSubtle,
    );
  }

  factory StatusBadge.taskPriority(TaskPriority priority) {
    String label;
    switch (priority) {
      case TaskPriority.high:
        label = 'High';
        break;
      case TaskPriority.medium:
        label = 'Medium';
        break;
      case TaskPriority.low:
        label = 'Low';
        break;
    }
    return StatusBadge(
      label: label,
      textColor: AppColors.textPrimary,
      backgroundColor: AppColors.card,
      borderColor: AppColors.borderSubtle,
    );
  }

  factory StatusBadge.leaveStatus(LeaveStatus status) {
    String label;
    switch (status) {
      case LeaveStatus.approved:
        label = 'Approved';
        break;
      case LeaveStatus.rejected:
        label = 'Rejected';
        break;
      case LeaveStatus.cancelled:
        label = 'Cancelled';
        break;
      case LeaveStatus.pending:
        label = 'Pending';
        break;
    }
    return StatusBadge(
      label: label,
      textColor: AppColors.textPrimary,
      backgroundColor: AppColors.card,
      borderColor: AppColors.borderSubtle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TaskStatusBadge(status: label);
  }
}
