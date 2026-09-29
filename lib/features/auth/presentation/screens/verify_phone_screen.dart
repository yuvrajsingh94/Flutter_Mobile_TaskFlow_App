import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/network/dio_client.dart';
import 'package:taskflow_flutter/core/services/otp_cooldown_service.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/otp_input.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';

class VerifyPhoneScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const VerifyPhoneScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen> {
  String get _target => 'phone_${widget.phoneNumber}';
  String _otp = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otpCooldownProvider.notifier).rehydrate(_target).then((_) {
        final state = ref.read(otpCooldownProvider);
        if (state.countdown == 0 && !state.isLockedOut) {
          ref.read(otpCooldownProvider.notifier).startCooldown(_target);
        }
      });
    });
  }

  Future<void> _handleVerify() async {
    final cooldownState = ref.read(otpCooldownProvider);
    if (cooldownState.isLockedOut) {
      setState(() => _errorMessage =
          'Too many failed attempts. Locked out for ${cooldownState.lockoutFormattedTime}.');
      return;
    }

    if (_otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the full 6-digit SMS verification code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.post(
        ApiEndpoints.verifyPhoneOtp,
        data: {
          'phoneNumber': widget.phoneNumber,
          'otp': _otp,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await ref.read(otpCooldownProvider.notifier).resetAttempts(_target);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('Phone number verified successfully!'),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      await ref.read(otpCooldownProvider.notifier).recordFailedAttempt(_target);
      final updated = ref.read(otpCooldownProvider);
      if (mounted) {
        if (updated.isLockedOut) {
          setState(() => _errorMessage =
              'Too many failed attempts. Try again in ${updated.lockoutFormattedTime}.');
        } else {
          final errStr = DioClient.extractErrorMessage(e);
          setState(() => _errorMessage =
              '$errStr (${updated.remainingAttempts} attempts remaining)');
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
      await repo.sendPhoneOtpPublic(widget.phoneNumber);
      await ref.read(otpCooldownProvider.notifier).startCooldown(_target);
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isDark ? AppColors.darkAccentPrimary : AppColors.primary,
            content: Text(
              'A fresh SMS OTP was sent to ${widget.phoneNumber}',
              style: TextStyle(color: isDark ? AppColors.darkAccentFg : AppColors.lightAccentFg),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        setState(() => _errorMessage = 'Could not resend SMS OTP: $cleanMsg');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpCooldownProvider);

    return ScreenWrapper(
      appBar: AppBar(
        title: const Text('Verify Mobile'),
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
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                size: 40,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Verify your phone',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Enter the 6-digit code sent via SMS to\n${widget.phoneNumber}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
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
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock_outlined, color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'SMS verification temporarily locked. Try again in ${otpState.lockoutFormattedTime}.',
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
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.errorBorder),
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

          // OTP Input
          OtpInput(
            length: 6,
            enabled: !_isLoading && !otpState.isLockedOut,
            onChanged: (val) {
              setState(() {
                _otp = val;
                if (_errorMessage != null) _errorMessage = null;
              });
            },
            onCompleted: (val) {
              // Intentionally do NOT auto-submit. User must tap button.
              setState(() => _otp = val);
            },
          ),
          const SizedBox(height: 28),

          // Submit Button
          AppButton(
            title: 'Verify Phone Number',
            onPressed: otpState.isLockedOut ? null : _handleVerify,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 24),

          // Resend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Didn't receive the SMS? ",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
                          : 'Resend SMS'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: (otpState.countdown > 0 || otpState.isLockedOut)
                        ? AppColors.textTertiary
                        : AppColors.primary,
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
