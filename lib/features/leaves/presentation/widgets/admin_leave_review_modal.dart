import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/status_badge.dart';
import 'package:taskflow_flutter/features/leaves/data/models/leave_model.dart';
import 'package:taskflow_flutter/features/leaves/presentation/providers/leave_provider.dart';

class AdminLeaveReviewModal extends ConsumerStatefulWidget {
  final LeaveModel leave;
  final VoidCallback? onSuccess;

  const AdminLeaveReviewModal({
    super.key,
    required this.leave,
    this.onSuccess,
  });

  static Future<void> show(
    BuildContext context,
    LeaveModel leave, {
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminLeaveReviewModal(
        leave: leave,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  ConsumerState<AdminLeaveReviewModal> createState() =>
      _AdminLeaveReviewModalState();
}

class _AdminLeaveReviewModalState extends ConsumerState<AdminLeaveReviewModal> {
  final _reasonController = TextEditingController();
  bool _isRejecting = false;
  bool _isLoading = false;
  String? _reasonError;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return DateFormat('MMM d, yyyy').format(d);
  }

  Future<void> _handleReview(String status) async {
    if (status == 'Rejected') {
      final rErr = Validators.validateRejectionReason(
        _reasonController.text.trim(),
        required: true,
      );
      if (rErr != null) {
        setState(() => _reasonError = rErr);
        return;
      }
    }

    setState(() => _isLoading = true);

    final success = await ref.read(leaveNotifierProvider.notifier).updateStatus(
          widget.leave.id,
          status,
          reason: status == 'Rejected' ? _reasonController.text.trim() : null,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        widget.onSuccess?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor:
                status == 'Approved' ? AppColors.success : AppColors.error,
            content: Text('Leave request $status successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Failed to update leave request.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leave = widget.leave;
    final empName = leave.employeeName.isNotEmpty ? leave.employeeName : 'Employee';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkBgCard : AppColors.lightBgCard;
    final infoBg = isDark ? AppColors.darkBgInput : AppColors.lightBgSidebar;
    final infoBorder = isDark ? AppColors.darkBorderInput : AppColors.lightBorderInput;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final dragHandleColor = isDark ? AppColors.darkBorderInput : AppColors.lightBorderInput;
    final borderColor = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderInput;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: dragHandleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Review Leave Request',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20, color: textSecondary),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Leave Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: infoBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: infoBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      empName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    StatusBadge.leaveStatus(leave.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${leave.leaveType.value} Leave • ${leave.totalDays} day${leave.totalDays > 1 ? "s" : ""}',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 16, color: isDark ? AppColors.darkAccentPrimary : AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(leave.startDate)} – ${_formatDate(leave.endDate)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '"${leave.reason}"',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Rejection Reason Input
          if (_isRejecting) ...[
            AppTextField(
              label: 'Rejection Reason *',
              hint: 'Explain why the leave request is rejected...',
              controller: _reasonController,
              maxLines: 3,
              errorText: _reasonError,
              onChanged: (_) {
                if (_reasonError != null) setState(() => _reasonError = null);
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => setState(() => _isRejecting = false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : () => _handleReview('Rejected'),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirm Reject',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => setState(() => _isRejecting = true),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    title: 'Approve Leave',
                    onPressed: () => _handleReview('Approved'),
                    isLoading: _isLoading,
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
