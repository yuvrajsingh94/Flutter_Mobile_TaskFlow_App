import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:taskflow_flutter/core/services/otp_cooldown_service.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/otp_input.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  final Map<String, dynamic>? pendingData;
  final Map<String, dynamic>? registrationPayload;
  final String? previewUrl;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    this.pendingData,
    this.registrationPayload,
    this.previewUrl,
  });

  Map<String, dynamic> get effectiveData => registrationPayload ?? pendingData ?? {};

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final GlobalKey<OtpInputState> _otpKey = GlobalKey<OtpInputState>();
  String _otp = '';
  bool _isLoading = false;
  String? _errorMessage;
  String? _previewUrl;
  String? _devOtp;

  @override
  void initState() {
    super.initState();
    _previewUrl = widget.previewUrl;
    if (_previewUrl != null && _previewUrl!.isNotEmpty) {
      _fetchDevOtp(_previewUrl!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otpCooldownProvider.notifier).rehydrate(widget.email).then((_) {
        final state = ref.read(otpCooldownProvider);
        if (state.countdown == 0 && !state.isLockedOut) {
          ref.read(otpCooldownProvider.notifier).startCooldown(widget.email);
        }
      });
    });
  }

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

  Future<void> _handleVerify() async {
    final cooldownState = ref.read(otpCooldownProvider);
    if (cooldownState.isLockedOut) {
      setState(() => _errorMessage =
          'Too many failed attempts. Locked out for ${cooldownState.lockoutFormattedTime}.');
      return;
    }

    if (_otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the full 6-digit verification code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = widget.effectiveData;
      final success = await ref.read(authNotifierProvider.notifier).register(
            firstName: data['firstName'] ?? '',
            lastName: data['lastName'] ?? '',
            email: data['email'] ?? widget.email,
            password: data['password'] ?? '',
            phoneNumber: data['phoneNumber'] ?? '',
            countryCode: data['countryCode'],
            dob: data['dob'],
            gender: data['gender'],
            qualification: data['qualification'],
            bio: data['bio'],
            department: data['department'],
            designation: data['designation'],
            role: data['role'] ?? 'employee',
            otp: _otp,
          );

      if (success) {
        await ref.read(otpCooldownProvider.notifier).resetAttempts(widget.email);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Account Created Successfully! Welcome to TaskFlow.'),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        await ref.read(otpCooldownProvider.notifier).recordFailedAttempt(widget.email);
        if (!mounted) return;
        final updated = ref.read(otpCooldownProvider);
        if (updated.isLockedOut) {
          setState(() => _errorMessage =
              'Too many failed attempts. Verification is temporarily locked for ${updated.lockoutFormattedTime}.');
        } else {
          setState(() => _errorMessage =
              OtpCooldownNotifier.formatAttemptsRemaining(updated.remainingAttempts));
        }
      }
    } catch (e) {
      if (mounted) {
        await ref.read(otpCooldownProvider.notifier).recordFailedAttempt(widget.email);
        if (mounted) {
          final updated = ref.read(otpCooldownProvider);
          if (updated.isLockedOut) {
            setState(() => _errorMessage =
                'Too many failed attempts. Verification is temporarily locked for ${updated.lockoutFormattedTime}.');
          } else {
            setState(() => _errorMessage =
                OtpCooldownNotifier.formatAttemptsRemaining(updated.remainingAttempts));
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    final cooldownState = ref.read(otpCooldownProvider);
    if (cooldownState.countdown > 0 || cooldownState.isLockedOut || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final newPreview = await repo.sendEmailOtp(widget.email);
      if (newPreview != null && newPreview.isNotEmpty) {
        _previewUrl = newPreview;
        _fetchDevOtp(newPreview);
      }
      await ref.read(otpCooldownProvider.notifier).startCooldown(widget.email);
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isDark ? AppColors.darkAccentPrimary : AppColors.primary,
            content: Text(
              'A fresh 6-digit verification code was sent to ${widget.email}',
              style: TextStyle(color: isDark ? AppColors.darkAccentFg : AppColors.lightAccentFg),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        setState(() => _errorMessage = 'Could not resend OTP code: $cleanMsg');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpCooldownProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final iconColor = isDark ? AppColors.darkAccentPrimary : AppColors.primary;
    final iconBg = isDark ? AppColors.darkBgInput : AppColors.primary.withValues(alpha: 0.1);
    final errorBg = isDark ? AppColors.darkErrorBg : AppColors.lightErrorBg;
    final errorBorder = isDark ? AppColors.darkError.withValues(alpha: 0.3) : AppColors.errorBorder;

    return ScreenWrapper(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          // Icon Box
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 40,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'We sent a 6-digit verification code to\n${widget.email}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Lockout Banner
          if (otpState.isLockedOut) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: errorBorder),
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
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: errorBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
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
          ],

          // Test OTP Banner (Auto-detected from Ethereal preview in development)
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

          // OTP Input
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
          const SizedBox(height: 28),

          // Submit Button
          AppButton(
            title: 'Verify & Create Account',
            onPressed: otpState.isLockedOut ? null : _handleVerify,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 24),

          // Resend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive the code? ",
                style: TextStyle(fontSize: 14, color: textSecondary),
              ),
              TextButton(
                onPressed: (otpState.countdown == 0 && !otpState.isLockedOut && !_isLoading)
                    ? _handleResend
                    : null,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  otpState.isLockedOut
                      ? 'Locked out (${otpState.lockoutFormattedTime})'
                      : (otpState.countdown > 0
                          ? 'Resend in ${otpState.countdown}s'
                          : 'Resend Code'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: (otpState.countdown > 0 || otpState.isLockedOut)
                        ? (isDark ? AppColors.darkTextDisabled : AppColors.textTertiary)
                        : (isDark ? AppColors.darkAccentPrimary : AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
