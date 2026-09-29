import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_date_picker.dart';
import 'package:taskflow_flutter/core/widgets/app_select.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/app_textarea.dart';
import 'package:taskflow_flutter/core/widgets/employee_select.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/presentation/providers/task_provider.dart';

const List<String> kPriorities = ['Low', 'Medium', 'High'];
const List<SelectOption> kCategoryOptions = [
  SelectOption(label: 'Engineering', value: 'Engineering'),
  SelectOption(label: 'Design', value: 'Design'),
  SelectOption(label: 'Product', value: 'Product'),
  SelectOption(label: 'QA & Testing', value: 'QA & Testing'),
  SelectOption(label: 'Operations', value: 'Operations'),
];

class CreateTaskScreen extends ConsumerStatefulWidget {
  final TaskModel? editTask;
  final String? preselectedEmployeeId;

  const CreateTaskScreen({
    super.key,
    this.editTask,
    this.preselectedEmployeeId,
  });

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

typedef AssignTaskScreen = CreateTaskScreen;

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _priority = 'Medium';
  String _category = 'Engineering';
  String _dueDate = '';
  String? _selectedEmployeeId;

  String? _titleError;
  String? _descError;
  String? _assigneeError;
  String? _dueDateError;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.editTask != null) {
      _titleController.text = widget.editTask!.title;
      _descController.text = widget.editTask!.description;
      _priority = widget.editTask!.priority.value;
      _category = widget.editTask!.category.isNotEmpty ? widget.editTask!.category : 'Engineering';
      _dueDate = widget.editTask!.dueDate.split('T')[0];
      _selectedEmployeeId = widget.editTask!.assignedUserId ?? widget.editTask!.assignedUser?.id;
    } else {
      _dueDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 3)));
      if (widget.preselectedEmployeeId != null) {
        _selectedEmployeeId = widget.preselectedEmployeeId;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    final tErr = Validators.validateTaskTitle(title);
    final dErr = Validators.validateTaskDesc(desc);
    final aErr = _selectedEmployeeId != null && _selectedEmployeeId!.isNotEmpty
        ? null
        : 'Please select an employee to assign this task.';
    final dateErr = Validators.validateTaskDueDate(_dueDate);

    setState(() {
      _titleError = tErr;
      _descError = dErr;
      _assigneeError = aErr;
      _dueDateError = dateErr;
    });

    if (tErr != null || dErr != null || aErr != null || dateErr != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final payload = {
      'title': title,
      'description': desc,
      'assignedTo': _selectedEmployeeId,
      'priority': _priority,
      'category': _category,
      'dueDate': _dueDate,
    };

    try {
      final dio = ref.read(dioClientProvider);
      final isEdit = widget.editTask != null;
      final url = isEdit ? ApiEndpoints.taskById(widget.editTask!.id) : ApiEndpoints.tasks;

      final res = isEdit
          ? await dio.put(url, data: payload)
          : await dio.post(url, data: payload);

      if (res.statusCode == 200 || res.statusCode == 201) {
        ref.invalidate(tasksProvider);
        ref.read(tasksNotifierProvider.notifier).loadTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.success,
              content: Text(isEdit ? 'Task Updated' : 'Task Assigned Successfully'),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _errorMessage = res.data?['message']?.toString() ?? 'Failed to save task.';
        });
      }
    } catch (e) {
      final dynamic err = e;
      final dynamic resData = err?.response?.data;
      final msg = (resData is Map ? resData['message'] : null) ?? 'Network error. Could not save task.';
      setState(() => _errorMessage = msg.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final bgInput = isDark ? AppColors.darkBgInput : AppColors.bgInput;
    final borderInput = isDark ? AppColors.darkBorderInput : AppColors.borderInput;
    final isEdit = widget.editTask != null;

    return ScreenWrapper(
      title: isEdit ? 'Edit Task' : 'Assign New Task',
      subtitle: isEdit ? 'Modify task properties' : 'Create & assign work to team',
      onBack: () => Navigator.of(context).pop(),
      scrollable: true,
      dismissKeyboardOnTap: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error Banner
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkErrorBg : AppColors.errorBg,
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

              // Task Title Input
              AppTextField(
                label: 'Task Title',
                placeholder: 'e.g. Design Landing Page Mockups',
                controller: _titleController,
                isRequired: true,
                maxLength: 100,
                error: _titleError,
                onChanged: (_) {
                  if (_titleError != null) setState(() => _titleError = null);
                },
                onBlur: () {
                  setState(() => _titleError = Validators.validateTaskTitle(_titleController.text));
                },
              ),

              // Task Description Textarea
              AppTextarea(
                label: 'Description',
                placeholder: 'Provide detailed requirements, context, and expected deliverables...',
                value: _descController.text,
                isRequired: true,
                maxLength: 500,
                minLines: 4,
                error: _descError,
                onChanged: (text) {
                  _descController.text = text;
                  if (_descError != null) setState(() => _descError = null);
                },
                onBlur: () {
                  setState(() => _descError = Validators.validateTaskDesc(_descController.text));
                },
              ),

              // Employee Select
              EmployeeSelect(
                label: 'Assign To',
                isRequired: true,
                value: _selectedEmployeeId,
                selectedEmployee: widget.editTask?.assignedUser,
                error: _assigneeError,
                onChanged: (val) {
                  setState(() {
                    _selectedEmployeeId = val?.toString();
                    if (_assigneeError != null) _assigneeError = null;
                  });
                },
              ),

              // Due Date Picker
              AppDatePicker(
                label: 'Due Date',
                value: _dueDate,
                isRequired: true,
                error: _dueDateError,
                onChanged: (dt) {
                  setState(() {
                    _dueDate = dt;
                    if (_dueDateError != null) _dueDateError = null;
                  });
                },
              ),

              // Priority Selection
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeSm,
                        fontWeight: AppTypography.fontWeightMedium,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: kPriorities.map((p) {
                        final isSelected = _priority == p;
                        Color dotColor;
                        Color activeBg;
                        Color activeText;

                        if (p == 'High') {
                          dotColor = const Color(0xFFD97706);
                          activeBg = isDark ? const Color(0xFF3D2B0A) : const Color(0xFFFEF3C7);
                          activeText = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
                        } else if (p == 'Medium') {
                          dotColor = const Color(0xFF2563EB);
                          activeBg = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);
                          activeText = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
                        } else {
                          dotColor = const Color(0xFF6B7280);
                          activeBg = isDark ? const Color(0xFF2A2A2E) : const Color(0xFFF3F4F6);
                          activeText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
                        }

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InkWell(
                              onTap: () => setState(() => _priority = p),
                              borderRadius: BorderRadius.circular(AppBorderRadius.md),
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isSelected ? activeBg : bgInput,
                                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                                  border: Border.all(
                                    color: isSelected ? activeText : borderInput,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: dotColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      p,
                                      style: TextStyle(
                                        fontSize: AppTypography.fontSizeSm,
                                        fontWeight: isSelected
                                            ? AppTypography.fontWeightBold
                                            : AppTypography.fontWeightMedium,
                                        color: isSelected ? activeText : textPrimary,
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
                  ],
                ),
              ),

              // Category Select
              AppSelect(
                label: 'Category',
                options: kCategoryOptions,
                value: _category,
                onChanged: (val) => setState(() => _category = val),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Submit Button
              AppButton(
                title: _isSubmitting
                    ? (isEdit ? 'Updating Task...' : 'Assigning Task...')
                    : (isEdit ? 'Update Task' : 'Assign Task'),
                loading: _isSubmitting,
                variant: ButtonVariant.primary,
                size: ButtonSize.lg,
                onPressed: _handleSubmit,
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
