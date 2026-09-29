import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_date_picker.dart';
import 'package:taskflow_flutter/core/widgets/app_select.dart';
import 'package:taskflow_flutter/core/widgets/app_textarea.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/leaves/presentation/providers/leave_provider.dart';

const List<SelectOption> kLeaveTypeOptions = [
  SelectOption(label: 'Casual Leave', value: 'Casual'),
  SelectOption(label: 'Sick Leave', value: 'Sick'),
  SelectOption(label: 'Earned / Annual Leave', value: 'Earned'),
  SelectOption(label: 'Unpaid Leave (LWP)', value: 'Unpaid'),
  SelectOption(label: 'Maternity Leave', value: 'Maternity'),
  SelectOption(label: 'Paternity Leave', value: 'Paternity'),
  SelectOption(label: 'Compensatory Off', value: 'Compensatory'),
];

void showApplyLeaveModal(
  BuildContext context, {
  VoidCallback? onSuccess,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ApplyLeaveModal(onSuccess: onSuccess),
  );
}

class ApplyLeaveModal extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;

  const ApplyLeaveModal({super.key, this.onSuccess});

  @override
  ConsumerState<ApplyLeaveModal> createState() => _ApplyLeaveModalState();
}

class _ApplyLeaveModalState extends ConsumerState<ApplyLeaveModal> {
  String _leaveType = 'Casual';
  String _startDate = '';
  String _endDate = '';
  final _reasonController = TextEditingController();

  String? _startError;
  String? _endError;
  String? _reasonError;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int _calculateDays() {
    if (_startDate.isEmpty || _endDate.isEmpty) return 0;
    final s = DateTime.tryParse(_startDate);
    final e = DateTime.tryParse(_endDate);
    if (s == null || e == null) return 0;
    if (e.isBefore(s)) return 0;
    return e.difference(s).inDays + 1;
  }

  Future<void> _handleSubmit() async {
    final dateValidation = Validators.validateLeaveDates(_startDate, _endDate);
    final sErr = dateValidation.startError;
    final eErr = dateValidation.endError;
    final reasonText = _reasonController.text.trim();
    final rErr = Validators.validateLeaveReason(reasonText);

    setState(() {
      _startError = sErr;
      _endError = eErr;
      _reasonError = rErr;
    });

    if (sErr != null || eErr != null || rErr != null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final dio = ref.read(dioClientProvider);
      final res = await dio.post(
        ApiEndpoints.leaves,
        data: {
          'leaveType': _leaveType,
          'startDate': _startDate,
          'endDate': _endDate,
          'reason': reasonText,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        ref.invalidate(myLeavesProvider);
        widget.onSuccess?.call();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('Leave application submitted successfully.'),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = res.data?['message']?.toString() ?? 'Failed to apply for leave.';
        });
      }
    } catch (err) {
      final dynamic e = err;
      final dynamic resData = e?.response?.data;
      final msg = (resData is Map ? resData['message'] : null) ?? 'Failed to apply for leave. Check connection.';
      setState(() => _errorMessage = msg.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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

    final totalDays = _calculateDays();

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Apply for Leave',
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
          ),

          Divider(color: borderSubtle, height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.md,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error Banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: AppTypography.fontSizeXs,
                                fontWeight: AppTypography.fontWeightMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Leave Type Select
                  AppSelect(
                    label: 'Leave Type',
                    options: kLeaveTypeOptions,
                    value: _leaveType,
                    isRequired: true,
                    onChanged: (val) => setState(() => _leaveType = val),
                  ),

                  // Dates Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppDatePicker(
                          label: 'Start Date',
                          value: _startDate,
                          minDate: DateTime.now(),
                          isRequired: true,
                          error: _startError,
                          onChanged: (dt) {
                            setState(() {
                              _startDate = dt;
                              if (_startError != null) _startError = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppDatePicker(
                          label: 'End Date',
                          value: _endDate,
                          minDate: DateTime.now(),
                          isRequired: true,
                          error: _endError,
                          onChanged: (dt) {
                            setState(() {
                              _endDate = dt;
                              if (_endError != null) _endError = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Duration badge
                  if (totalDays > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkOverlayMedium : AppColors.surfaceStone,
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          border: Border.all(color: borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event_note_rounded, size: 16, color: textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'Total Duration: ',
                              style: TextStyle(
                                fontSize: AppTypography.fontSizeXs,
                                color: textSecondary,
                              ),
                            ),
                            Text(
                              '$totalDays day${totalDays > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: AppTypography.fontSizeXs,
                                fontWeight: AppTypography.fontWeightBold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Reason Textarea
                  AppTextarea(
                    label: 'Reason for Leave',
                    placeholder: 'Briefly explain why you are requesting this leave...',
                    value: _reasonController.text,
                    maxLength: 500,
                    minLines: 3,
                    isRequired: true,
                    error: _reasonError,
                    onChanged: (val) {
                      _reasonController.text = val;
                      if (_reasonError != null) setState(() => _reasonError = null);
                    },
                    onBlur: () {
                      if (_reasonController.text.isNotEmpty) {
                        setState(() => _reasonError = Validators.validateLeaveReason(_reasonController.text));
                      }
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Submit Button
                  AppButton(
                    title: _isSubmitting ? 'Submitting Application...' : 'Submit Application',
                    loading: _isSubmitting,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.lg,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
