import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/password_strength_meter.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';

class ChangeTemporaryPasswordModal extends ConsumerStatefulWidget {
  const ChangeTemporaryPasswordModal({super.key});

  @override
  ConsumerState<ChangeTemporaryPasswordModal> createState() =>
      _ChangeTemporaryPasswordModalState();
}

class _ChangeTemporaryPasswordModalState
    extends ConsumerState<ChangeTemporaryPasswordModal> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _currentError;
  String? _newError;
  String? _confirmError;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onPasswordChanged);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final cur = _currentPasswordController.text;
    final neu = _newPasswordController.text;
    final conf = _confirmPasswordController.text;

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    if (cur.isEmpty) {
      setState(() => _currentError = 'Please enter your temporary password.');
      return;
    }

    final newErr = Validators.validateRegisterPassword(
      neu,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
    );
    final confErr = Validators.validateConfirmPassword(neu, conf);

    setState(() {
      _currentError = null;
      _newError = newErr;
      _confirmError = confErr;
      _errorMessage = null;
    });

    if (newErr != null || confErr != null) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.changeTemporaryPassword(
        currentPassword: cur,
        newPassword: neu,
      );

      if (mounted) {
        final updated = user.copyWith(firstLogin: false, emailVerified: true);
        ref.read(authNotifierProvider.notifier).updateUser(updated);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Password updated successfully! Welcome to TaskFlow.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    if (user == null || user.firstLogin != true) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgElevated : AppColors.surfaceElevated;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.borderHairline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final errorBg = isDark ? AppColors.darkErrorBg : AppColors.errorBg;

    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black.withValues(alpha: 0.65),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.key_rounded,
                        size: 32,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Set Permanent Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome, ${user.firstName}! Since this is your first sign-in using a temporary password, you must create a new permanent password for security.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Warning note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined, size: 18, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Choose a strong password: min 8 characters with uppercase, lowercase, numbers, and symbols.',
                            style: TextStyle(fontSize: 12, color: Colors.amber),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: errorBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ),
                  ],

                  AppTextField.password(
                    label: 'Current Temporary Password',
                    placeholder: '••••••••',
                    controller: _currentPasswordController,
                    error: _currentError,
                    onChanged: (_) {
                      if (_currentError != null) setState(() => _currentError = null);
                      if (_errorMessage != null) setState(() => _errorMessage = null);
                    },
                    onBlur: () {
                      if (_currentPasswordController.text.isEmpty) {
                        setState(() => _currentError = 'Please enter your temporary password.');
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  AppTextField.password(
                    label: 'New Permanent Password',
                    placeholder: '••••••••',
                    controller: _newPasswordController,
                    error: _newError,
                    onChanged: (_) {
                      if (_newError != null) setState(() => _newError = null);
                      if (_errorMessage != null) setState(() => _errorMessage = null);
                    },
                    onBlur: () {
                      setState(() => _newError = Validators.validateRegisterPassword(
                        _newPasswordController.text,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        email: user.email,
                      ));
                    },
                  ),
                  PasswordStrengthMeter(password: _newPasswordController.text),
                  const SizedBox(height: 14),

                  AppTextField.password(
                    label: 'Confirm New Password',
                    placeholder: '••••••••',
                    controller: _confirmPasswordController,
                    error: _confirmError,
                    onChanged: (_) {
                      if (_confirmError != null) setState(() => _confirmError = null);
                      if (_errorMessage != null) setState(() => _errorMessage = null);
                    },
                    onBlur: () {
                      setState(() => _confirmError = Validators.validateConfirmPassword(
                        _newPasswordController.text,
                        _confirmPasswordController.text,
                      ));
                    },
                  ),
                  const SizedBox(height: 20),

                  AppButton(
                    title: 'Update Password & Continue',
                    onPressed: _handleSubmit,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
