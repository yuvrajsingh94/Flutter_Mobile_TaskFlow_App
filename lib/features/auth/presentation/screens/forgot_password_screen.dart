import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/services/otp_cooldown_service.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/app_text_field.dart';
import 'package:taskflow_flutter/core/widgets/otp_input.dart';
import 'package:taskflow_flutter/core/widgets/password_strength_meter.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<OtpInputState> _otpKey = GlobalKey<OtpInputState>();
  int _step = 1; // 1: Email, 2: OTP, 3: New Password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _otp = '';
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _devOtp;

  String get _target => 'forgot_${_emailController.text.trim().toLowerCase()}';

  Future<void> _fetchDevOtp(String url) async {
    try {
      final res = await Dio().get<String>(url);
      final body = res.data ?? '';
      final match = RegExp(r'Your OTP code is:\s*(?:<b[^>]*>)?(\d{6})').firstMatch(body);
      if (match != null && match.group(1) != null && mounted) {
        setState(() {
          _devOtp = match.group(1);
        });
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim().toLowerCase();
    final emailErr = Validators.validateEmail(email);
    if (emailErr != null) {
      setState(() => _errorMessage = emailErr);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final previewUrl = await repo.forgotPasswordOtp(email);
      if (previewUrl != null && previewUrl.isNotEmpty) {
        _fetchDevOtp(previewUrl);
      }
      await ref.read(otpCooldownProvider.notifier).rehydrate(_target);
      await ref.read(otpCooldownProvider.notifier).startCooldown(_target);

      setState(() {
        _isLoading = false;
        _step = 2;
        _otp = '';
        _successMessage = 'Verification code sent to $email';
      });
    } catch (e) {
      final raw = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      final lower = raw.toLowerCase();
      final isNotFound = lower.contains('not found') ||
          lower.contains('no account') ||
          lower.contains("doesn't exist") ||
          lower.contains('does not exist') ||
          lower.contains('no user') ||
          lower.contains('invalid email');
      setState(() {
        _isLoading = false;
        _errorMessage = isNotFound
            ? 'No account found with this email address. Please check and try again.'
            : raw;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otp.trim();
    final cooldownState = ref.read(otpCooldownProvider);
    if (cooldownState.isLockedOut) {
      setState(() => _errorMessage =
          'Too many failed attempts. Locked out for ${cooldownState.lockoutFormattedTime}.');
      return;
    }

    if (otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the full 6-digit verification code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyForgotPasswordOtp(_emailController.text.trim().toLowerCase(), otp);
      await ref.read(otpCooldownProvider.notifier).resetAttempts(_target);

      setState(() {
        _isLoading = false;
        _step = 3;
        _successMessage = 'Code verified. Enter your new password.';
      });
    } catch (e) {
      await ref.read(otpCooldownProvider.notifier).recordFailedAttempt(_target);
      final updated = ref.read(otpCooldownProvider);
      setState(() {
        _isLoading = false;
        if (updated.isLockedOut) {
          _errorMessage =
              'Too many failed attempts. Verification is temporarily locked for ${updated.lockoutFormattedTime}.';
        } else {
          _errorMessage =
              OtpCooldownNotifier.formatAttemptsRemaining(updated.remainingAttempts);
        }
      });
    }
  }

  Future<void> _resetPassword() async {
    final pass = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final email = _emailController.text.trim().toLowerCase();

    final passErr = Validators.validateRegisterPassword(pass, email: email);
    if (passErr != null) {
      setState(() => _errorMessage = passErr);
      return;
    }

    final confirmErr = Validators.validateConfirmPassword(pass, confirm);
    if (confirmErr != null) {
      setState(() => _errorMessage = confirmErr);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(
        email: email,
        otp: _otp.trim(),
        newPassword: pass,
      );
      setState(() {
        _isLoading = false;
        _successMessage = 'Password reset successfully. You may now log in.';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpCooldownProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final errorBg = isDark ? AppColors.darkErrorBg : AppColors.errorBg;
    final successBg = isDark ? AppColors.darkSuccessBg : AppColors.successBg;

    return ScreenWrapper(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step > 1) {
              setState(() {
                _step--;
                _errorMessage = null;
                _successMessage = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            _step == 1
                ? 'Forgot Password'
                : _step == 2
                    ? 'Enter Verification Code'
                    : 'Set New Password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _step == 1
                ? 'Enter your registered email address and we will send you a verification code.'
                : _step == 2
                    ? 'Enter the 6-digit OTP sent to ${_emailController.text.trim()}.'
                    : 'Create a strong, new password for your account.',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 24),

          // Messages
          if (_step == 2 && otpState.isLockedOut) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock_outlined, color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Account temporarily locked due to too many failed attempts. Try again in ${otpState.lockoutFormattedTime}.',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          ],
          if (_successMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: successBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.successBorder),
              ),
              child: Text(
                _successMessage!,
                style: const TextStyle(color: AppColors.success, fontSize: 13),
              ),
            ),
          ],

          if (_step == 1) ...[
            AppTextField(
              label: 'Email address',
              placeholder: 'name@company.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              leftIcon: const Icon(Icons.mail_outline_rounded, size: 20, color: AppColors.textTertiary),
              onChanged: (_) {
                if (_errorMessage != null) setState(() => _errorMessage = null);
              },
              onBlur: () {
                final err = Validators.validateEmail(_emailController.text);
                if (err != null) setState(() => _errorMessage = err);
              },
            ),
            const SizedBox(height: 24),
            AppButton(
              title: 'Send Verification Code',
              isLoading: _isLoading,
              onPressed: _sendOtp,
            ),
          ] else if (_step == 2) ...[
            if (_devOtp != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkOverlayMedium : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorderSubtle : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mark_email_read_outlined,
                      color: isDark ? AppColors.darkAccentPrimary : AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Email OTP: $_devOtp',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF166534),
                            ),
                          ),
                          Text(
                            'Auto-detected from Ethereal preview',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _otp = _devOtp!;
                        });
                        _otpKey.currentState?.setValue(_devOtp!);
                      },
                      child: const Text('Auto-Fill', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
            OtpInput(
              key: _otpKey,
              length: 6,
              enabled: !_isLoading && !otpState.isLockedOut,
              onChanged: (val) {
                setState(() {
                  _otp = val;
                  if (_errorMessage != null) _errorMessage = null;
                });
              },
              onCompleted: (val) {
                // Intentionally do NOT auto-submit. User must tap the button.
                setState(() => _otp = val);
              },
            ),
            const SizedBox(height: 24),
            AppButton(
              title: 'Verify Code',
              isLoading: _isLoading,
              onPressed: otpState.isLockedOut ? null : _verifyOtp,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: (otpState.countdown == 0 && !otpState.isLockedOut && !_isLoading)
                    ? _sendOtp
                    : null,
                child: Text(
                  otpState.isLockedOut
                      ? 'Locked out (${otpState.lockoutFormattedTime})'
                      : (otpState.countdown > 0
                          ? 'Resend Code in ${otpState.countdown}s'
                          : 'Resend Code'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: (otpState.countdown > 0 || otpState.isLockedOut)
                        ? AppColors.textTertiary
                        : (isDark ? AppColors.darkAccentPrimary : AppColors.primary),
                  ),
                ),
              ),
            ),
          ] else ...[
            AppTextField.password(
              label: 'New Password',
              placeholder: '••••••••',
              controller: _passwordController,
              isRequired: true,
              leftIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textTertiary),
              onChanged: (_) {
                if (_errorMessage != null) setState(() => _errorMessage = null);
              },
              onBlur: () {
                final err = Validators.validateRegisterPassword(
                  _passwordController.text,
                  email: _emailController.text.trim(),
                );
                if (err != null) setState(() => _errorMessage = err);
              },
            ),
            PasswordStrengthMeter(password: _passwordController.text),
            const SizedBox(height: 16),
            AppTextField.password(
              label: 'Confirm New Password',
              placeholder: '••••••••',
              controller: _confirmPasswordController,
              isRequired: true,
              leftIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textTertiary),
              onChanged: (_) {
                if (_errorMessage != null) setState(() => _errorMessage = null);
              },
              onBlur: () {
                final err = Validators.validateConfirmPassword(
                  _passwordController.text,
                  _confirmPasswordController.text,
                );
                if (err != null) setState(() => _errorMessage = err);
              },
            ),
            const SizedBox(height: 24),
            AppButton(
              title: 'Reset Password',
              isLoading: _isLoading,
              onPressed: _resetPassword,
            ),
          ],
        ],
      ),
    );
  }
}
