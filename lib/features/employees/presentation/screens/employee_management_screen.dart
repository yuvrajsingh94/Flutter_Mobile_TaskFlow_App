import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_phone_field.dart';
import 'package:taskflow_flutter/core/widgets/app_select.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/empty_state.dart';
import 'package:taskflow_flutter/core/widgets/profile_avatar.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/employees/presentation/providers/employee_provider.dart';
import 'package:taskflow_flutter/features/employees/presentation/screens/employee_profile_screen.dart';

class EmployeeManagementScreen extends ConsumerWidget {
  const EmployeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchBg = isDark ? AppColors.darkBgInput : AppColors.lightBgInput;
    final searchBorder = isDark ? AppColors.darkBorderInput : AppColors.lightBorderInput;
    final searchHint = isDark ? AppColors.darkTextPlaceholder : AppColors.lightTextPlaceholder;
    final employeeState = ref.watch(employeeNotifierProvider);
    final filteredEmployees = ref.watch(filteredEmployeesProvider);

    return ScreenWrapper(
      appBar: AppBar(
        title: const Text('Employee Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(employeeNotifierProvider.notifier).loadEmployees(),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Add Member',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const _AddEmployeeModal(),
            ),
          ),
        ],
      ),
      onRefresh: () => ref.read(employeeNotifierProvider.notifier).loadEmployees(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          Container(
            decoration: BoxDecoration(
              color: searchBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: searchBorder),
            ),
            child: TextField(
              onChanged: (val) => ref.read(employeeNotifierProvider.notifier).setSearchQuery(val),
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name, email, department...',
                hintStyle: TextStyle(color: searchHint, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: searchHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (employeeState.errorMessage != null && employeeState.employees.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkErrorBg : AppColors.errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      employeeState.errorMessage!,
                      style: const TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (employeeState.isLoading && employeeState.employees.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (employeeState.errorMessage != null && employeeState.employees.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkErrorBg : AppColors.errorBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.errorBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 44),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to load employees',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      employeeState.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => ref.read(employeeNotifierProvider.notifier).loadEmployees(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredEmployees.isEmpty)
            const EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'No employees found',
              description: 'There are no active employees matching your search criteria.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredEmployees.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final emp = filteredEmployees[index];
                return _buildEmployeeCard(context, ref, emp);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, WidgetRef ref, UserProfile emp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.lightBgCard;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderInput;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;
    final isBlocked = emp.isBlocked;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          SlidePageRoute(
            builder: (_) => EmployeeProfileScreen(employeeId: emp.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          children: [
          ProfileAvatar(
            imageUrl: emp.profilePicture,
            name: emp.fullName,
            radius: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      emp.fullName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    if (isBlocked) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkErrorBg : AppColors.errorBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BLOCKED',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.error),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  emp.email,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
                if (emp.department != null || emp.designation != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [emp.designation, emp.department].where((s) => s != null && s.isNotEmpty).join(' • '),
                    style: TextStyle(fontSize: 11, color: textTertiary),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, size: 20, color: textTertiary),
            onSelected: (action) async {
              if (action == 'toggle_block') {
                if (isBlocked) {
                  await ref.read(employeeNotifierProvider.notifier).unblockEmployee(emp.id);
                } else {
                  await ref.read(employeeNotifierProvider.notifier).blockEmployee(emp.id);
                }
              } else if (action == 'delete') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark ? AppColors.darkBgCard : AppColors.lightBgCard,
                    title: Text('Delete Employee', style: TextStyle(color: textPrimary)),
                    content: Text(
                      'Are you sure you want to remove ${emp.fullName}?',
                      style: TextStyle(color: textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: TextStyle(color: textSecondary)),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await ref.read(employeeNotifierProvider.notifier).deleteEmployee(emp.id);
                        },
                        child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_block',
                child: Text(isBlocked ? 'Unblock Account' : 'Block Account'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Account', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

const List<SelectOption> kEmployeeDepartments = [
  SelectOption(label: 'Engineering', value: 'Engineering'),
  SelectOption(label: 'Design', value: 'Design'),
  SelectOption(label: 'Product', value: 'Product'),
  SelectOption(label: 'QA & Testing', value: 'QA & Testing'),
  SelectOption(label: 'Operations', value: 'Operations'),
  SelectOption(label: 'Marketing', value: 'Marketing'),
  SelectOption(label: 'Human Resources', value: 'Human Resources'),
];

class _AddEmployeeModal extends ConsumerStatefulWidget {
  const _AddEmployeeModal();

  @override
  ConsumerState<_AddEmployeeModal> createState() => _AddEmployeeModalState();
}

class _AddEmployeeModalState extends ConsumerState<_AddEmployeeModal> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _designationController = TextEditingController(text: 'Software Engineer');

  String _countryCode = '+91';
  String _countryIso = 'IN';
  String _phoneNumber = '';
  String _department = 'Engineering';

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _deptError;
  String? _desigError;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final fn = _firstNameController.text.trim();
    final ln = _lastNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final desig = _designationController.text.trim();

    final fErr = Validators.validateFirstName(fn);
    final lErr = Validators.validateLastName(ln);
    final eErr = Validators.validateEmail(email);
    final pErr = Validators.validatePhoneNumber(
      _phoneNumber,
      isRequired: true,
      countryCode: _countryCode,
      isoCode: _countryIso,
    );
    final dErr = Validators.validateDepartment(_department, required: true);
    final desigErr = Validators.validateDesignation(desig, required: true);

    setState(() {
      _firstNameError = fErr;
      _lastNameError = lErr;
      _emailError = eErr;
      _phoneError = pErr;
      _deptError = dErr;
      _desigError = desigErr;
    });

    if (fErr != null || lErr != null || eErr != null || pErr != null || dErr != null || desigErr != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final payload = {
      'firstName': fn,
      'lastName': ln,
      'email': email,
      'phoneNumber': '$_countryCode${_phoneNumber.trim()}',
      'countryCode': _countryCode,
      'department': _department,
      'designation': desig,
    };

    final success = await ref.read(employeeNotifierProvider.notifier).addEmployee(payload);
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text('$fn has been invited with a temporary password.'),
        ),
      );
    } else {
      final err = ref.read(employeeNotifierProvider).errorMessage;
      setState(() => _errorMessage = err ?? 'Failed to add employee.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCard = isDark ? AppColors.darkCard : AppColors.card;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorderInput : AppColors.borderInput,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add New Team Member',
                style: TextStyle(
                  fontSize: AppTypography.fontSizeBase,
                  fontWeight: AppTypography.fontWeightBold,
                  color: textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: textSecondary, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Divider(color: borderSubtle, height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkErrorBg : AppColors.errorBg,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(color: AppColors.errorBorder),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: AppTypography.fontSizeXs),
                      ),
                    ),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'First Name',
                          placeholder: 'Jane',
                          controller: _firstNameController,
                          isRequired: true,
                          maxLength: 30,
                          textCapitalization: TextCapitalization.none,
                          error: _firstNameError,
                          onChanged: (val) {
                            final filtered = Validators.filterFirstName(val);
                            if (filtered != val) {
                              _firstNameController.value = TextEditingValue(
                                text: filtered,
                                selection: TextSelection.collapsed(offset: filtered.length),
                              );
                            }
                            if (_firstNameError != null) setState(() => _firstNameError = null);
                          },
                          onBlur: () {
                            if (_firstNameController.text.isNotEmpty) {
                              setState(() => _firstNameError =
                                  Validators.validateFirstName(_firstNameController.text));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: 'Last Name',
                          placeholder: 'Doe',
                          controller: _lastNameController,
                          isRequired: true,
                          maxLength: 50,
                          textCapitalization: TextCapitalization.none,
                          error: _lastNameError,
                          onChanged: (val) {
                            final filtered = Validators.filterLastName(val);
                            if (filtered != val) {
                              _lastNameController.value = TextEditingValue(
                                text: filtered,
                                selection: TextSelection.collapsed(offset: filtered.length),
                              );
                            }
                            if (_lastNameError != null) setState(() => _lastNameError = null);
                          },
                          onBlur: () {
                            if (_lastNameController.text.isNotEmpty) {
                              setState(() => _lastNameError =
                                  Validators.validateLastName(_lastNameController.text));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  AppTextField(
                    label: 'Work Email',
                    placeholder: 'jane@company.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                    error: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) setState(() => _emailError = null);
                    },
                    onBlur: () {
                      if (_emailController.text.isNotEmpty) {
                        setState(() => _emailError = Validators.validateEmail(_emailController.text));
                      }
                    },
                  ),
                  AppPhoneField(
                    label: 'Phone Number',
                    countryCode: _countryCode,
                    countryIso: _countryIso,
                    onCountryCodeChange: (c) => setState(() => _countryCode = c),
                    onCountryChange: (c) => setState(() {
                      _countryCode = c.code;
                      _countryIso = c.iso;
                      if (_phoneError != null) _phoneError = null;
                    }),
                    value: _phoneNumber,
                    isRequired: true,
                    error: _phoneError,
                    onChanged: (val) {
                      setState(() {
                        _phoneNumber = val;
                        if (_phoneError != null) _phoneError = null;
                      });
                    },
                    onBlur: () {
                      if (_phoneNumber.isNotEmpty) {
                        setState(() => _phoneError = Validators.validatePhoneNumber(
                          _phoneNumber,
                          isRequired: true,
                          countryCode: _countryCode,
                          isoCode: _countryIso,
                        ));
                      }
                    },
                  ),
                  AppSelect(
                    label: 'Department',
                    options: kEmployeeDepartments,
                    value: _department,
                    isRequired: true,
                    onChanged: (val) {
                      setState(() {
                        _department = val;
                        if (_deptError != null) _deptError = null;
                      });
                    },
                  ),
                  AppTextField(
                    label: 'Designation / Role',
                    placeholder: 'e.g. Senior Software Engineer',
                    controller: _designationController,
                    isRequired: true,
                    error: _desigError,
                    onChanged: (_) {
                      if (_desigError != null) setState(() => _desigError = null);
                    },
                    onBlur: () {
                      if (_designationController.text.isNotEmpty) {
                        setState(() => _desigError =
                            Validators.validateDesignation(_designationController.text, required: true));
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    title: 'Create & Send Invitation',
                    onPressed: _handleSubmit,
                    loading: _isSubmitting,
                    size: ButtonSize.lg,
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
