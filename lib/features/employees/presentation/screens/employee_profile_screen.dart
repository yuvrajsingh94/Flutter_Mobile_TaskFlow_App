import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/network/dio_client.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/profile_avatar.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/core/widgets/status_badge.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/tasks/data/models/task_model.dart';
import 'package:taskflow_flutter/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/create_task_screen.dart';
import 'package:taskflow_flutter/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:taskflow_flutter/features/employees/presentation/providers/employee_provider.dart';

class EmployeeProfileScreen extends ConsumerStatefulWidget {
  final String employeeId;

  const EmployeeProfileScreen({super.key, required this.employeeId});

  @override
  ConsumerState<EmployeeProfileScreen> createState() =>
      _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends ConsumerState<EmployeeProfileScreen> {
  UserProfile? _employee;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = ref.read(dioClientProvider).dio;
      final response =
          await dio.get(ApiEndpoints.employeeById(widget.employeeId));
      final raw = response.data;
      final userMap =
          raw is Map<String, dynamic> && raw['employee'] != null
              ? raw['employee'] as Map<String, dynamic>
              : raw as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _employee = UserProfile.fromJson(userMap);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = DioClient.extractErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleToggleBlock() async {
    if (_employee == null) return;
    final shouldBlock = !_employee!.isBlocked;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final actionColor = shouldBlock
        ? (isDark ? AppColors.darkError : AppColors.lightError)
        : (isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(shouldBlock ? 'Block Employee' : 'Unblock Employee'),
        content: Text(
          shouldBlock
              ? 'Are you sure you want to block ${_employee!.fullName}? They will be unable to access the workspace.'
              : 'Are you sure you want to unblock ${_employee!.fullName}? They will regain workspace access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              shouldBlock ? 'Yes, Block' : 'Yes, Unblock',
              style: TextStyle(
                color: actionColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repo = ref.read(employeeRepositoryProvider);
    try {
      if (shouldBlock) {
        await repo.blockEmployee(_employee!.id);
      } else {
        await repo.unblockEmployee(_employee!.id);
      }
      ref.read(employeeNotifierProvider.notifier).loadEmployees();
      await _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shouldBlock
                ? '${_employee!.fullName} blocked'
                : '${_employee!.fullName} unblocked'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    if (_employee == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final deleteColor = isDark ? AppColors.darkError : AppColors.lightError;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to archive ${_employee!.fullName}? This will revoke account access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: deleteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repo = ref.read(employeeRepositoryProvider);
    try {
      await repo.deleteEmployee(_employee!.id);
      ref.read(employeeNotifierProvider.notifier).loadEmployees();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_employee!.fullName} removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.lightBgCard;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderInput;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;
    final chipBg = isDark ? AppColors.darkBgInput : AppColors.surfaceStone;
    final dividerColor = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle;

    final taskState = ref.watch(taskNotifierProvider);
    final employeeTasks = taskState.tasks.where((t) {
      return t.assignedUserId == widget.employeeId ||
          t.assignedUser?.id == widget.employeeId;
    }).toList();

    return ScreenWrapper(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employee Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              'Account details & task history',
              style: TextStyle(fontSize: 12, color: textTertiary),
            ),
          ],
        ),
      ),
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.errorBorder),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadProfile,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _employee == null
                  ? const Center(child: Text('Employee not found'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header Card ───────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Column(
                            children: [
                              ProfileAvatar(
                                imageUrl: _employee!.profilePicture,
                                name: _employee!.fullName,
                                radius: 36,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _employee!.fullName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                  if (_employee!.isBlocked) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.errorBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'BLOCKED',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _employee!.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: chipBg,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  [_employee!.designation, _employee!.department]
                                      .where((s) => s != null && s.isNotEmpty)
                                      .join(' • '),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Personal Details ──────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(Icons.phone_outlined, 'Phone',
                                  _employee!.phoneNumber, textPrimary, textTertiary),
                              Divider(height: 20, color: dividerColor),
                              _buildInfoRow(
                                  Icons.school_outlined,
                                  'Qualification',
                                  _employee!.qualification ?? 'Not provided',
                                  textPrimary,
                                  textTertiary),
                              Divider(height: 20, color: dividerColor),
                              _buildInfoRow(
                                  Icons.cake_outlined,
                                  'Date of Birth',
                                  _employee!.dob ?? 'Not provided',
                                  textPrimary,
                                  textTertiary),
                              Divider(height: 20, color: dividerColor),
                              _buildInfoRow(Icons.person_outline_rounded,
                                  'Gender', _employee!.gender ?? 'Not specified',
                                  textPrimary,
                                  textTertiary),
                              if (_employee!.bio != null &&
                                  _employee!.bio!.isNotEmpty) ...[
                                Divider(height: 20, color: dividerColor),
                                _buildInfoRow(Icons.notes_rounded, 'Bio',
                                    _employee!.bio!, textPrimary, textTertiary),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Assigned Tasks Section ────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Assigned Tasks (${employeeTasks.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  SlidePageRoute(
                                    builder: (_) => CreateTaskScreen(
                                      preselectedEmployeeId: _employee!.id,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_task_rounded, size: 16),
                              label: const Text('Assign Task'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (employeeTasks.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: cardBorder),
                            ),
                            child: Center(
                              child: Text(
                                'No tasks currently assigned to this employee.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: employeeTasks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final task = employeeTasks[index];
                              return _buildEmployeeTaskTile(task, cardBg, cardBorder, textPrimary, textTertiary);
                            },
                          ),

                        const SizedBox(height: 28),

                        // ── Admin Actions (Block / Delete) ────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _employee!.isBlocked
                                      ? (isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary)
                                      : (isDark ? AppColors.darkWarning : AppColors.lightWarning),
                                  side: BorderSide(
                                    color: _employee!.isBlocked
                                        ? (isDark ? AppColors.darkBorderFocus : AppColors.lightAccentPrimary)
                                        : (isDark ? AppColors.darkWarning : AppColors.lightWarning),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _handleToggleBlock,
                                icon: Icon(
                                  _employee!.isBlocked
                                      ? Icons.lock_open_rounded
                                      : Icons.lock_outline_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  _employee!.isBlocked
                                      ? 'Unblock Account'
                                      : 'Block Account',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? AppColors.darkError : AppColors.lightError,
                                  side: BorderSide(
                                    color: isDark ? AppColors.darkError : AppColors.lightError,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _handleDelete,
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 16),
                                label: const Text('Delete Account'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, Color textPrimary, Color textTertiary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeTaskTile(TaskModel task, Color cardBg, Color cardBorder,
      Color textPrimary, Color textTertiary) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          SlidePageRoute(
            builder: (_) => TaskDetailScreen(task: task),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StatusBadge.taskStatus(task.status),
                      const SizedBox(width: 8),
                      StatusBadge.taskPriority(task.priority),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: textTertiary),
          ],
        ),
      ),
    );
  }
}
