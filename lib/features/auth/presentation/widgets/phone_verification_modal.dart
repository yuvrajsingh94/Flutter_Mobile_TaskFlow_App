import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/services/otp_cooldown_service.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/otp_input.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';

class PhoneVerificationModal extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;

  const PhoneVerificationModal({super.key, this.onSuccess});

  static Future<void> show(BuildContext context, {VoidCallback? onSuccess}) {
    return showDialog(
      context: context,
      builder: (_) => PhoneVerificationModal(onSuccess: onSuccess),
    );
  }

  @override
  ConsumerState<PhoneVerificationModal> createState() =>
      _PhoneVerificationModalState();
}

class _PhoneVerificationModalState
    extends ConsumerState<PhoneVerificationModal> {
  String _otp = '';
  bool _isVerifying = false;
  bool _isSending = false;
  String? _errorMessage;

  String _getTarget() {
    final user = ref.read(authNotifierProvider).user;
    return 'phone_modal_${user?.phoneNumber ?? "current"}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _getTarget();
      ref.read(otpCooldownProvider.notifier).rehydrate(target).then((_) {
        final state = ref.read(otpCooldownProvider);
        if (state.countdown == 0 && !state.isLockedOut) {
          ref.read(otpCooldownProvider.notifier).startCooldown(target);
        }
      });
    });
  }

  Future<void> _handleSendOtp() async {
    final target = _getTarget();
    final cooldownState = ref.read(otpCooldownProvider);
    if (cooldownState.countdown > 0 || cooldownState.isLockedOut || _isSending) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendPhoneOtp();
      await ref.read(otpCooldownProvider.notifier).startCooldown(target);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('SMS verification code sent!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _handleVerify() async {
    final target = _getTarget();
    final cooldownState = ref.read(otpCooldownProvider);
    if (cooldownState.isLockedOut) {
      setState(() => _errorMessage =
          'Too many attempts. Locked out for ${cooldownState.lockoutFormattedTime}.');
      return;
    }

    if (_otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit SMS code.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyPhoneOtp(_otp);
      await ref.read(otpCooldownProvider.notifier).resetAttempts(target);

      if (mounted) {
        final user = ref.read(authNotifierProvider).user;
        if (user != null) {
          ref.read(authNotifierProvider.notifier).updateUser(
                user.copyWith(phoneVerified: true),
              );
        }
        widget.onSuccess?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Phone number verified successfully!'),
          ),
        );
      }
    } catch (e) {
      await ref.read(otpCooldownProvider.notifier).recordFailedAttempt(target);
      final updated = ref.read(otpCooldownProvider);
      if (mounted) {
        if (updated.isLockedOut) {
          setState(() => _errorMessage =
              'Too many failed attempts. Try again in ${updated.lockoutFormattedTime}.');
        } else {
          setState(() => _errorMessage =
              OtpCooldownNotifier.formatAttemptsRemaining(updated.remainingAttempts));
        }
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final otpState = ref.watch(otpCooldownProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppColors.darkBgElevated : AppColors.surfaceElevated;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final errorBg = isDark ? AppColors.darkErrorBg : AppColors.errorBg;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: dialogBg,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verify Phone Number',
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
            Text(
              'Enter the 6-digit SMS code sent to ${user?.phoneNumber ?? "your registered number"}',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 20),

            if (otpState.isLockedOut) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: errorBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Locked out due to failed attempts. Try again in ${otpState.lockoutFormattedTime}.',
                  style: const TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ),
            ] else if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 14),
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

            OtpInput(
              length: 6,
              enabled: !_isVerifying && !otpState.isLockedOut,
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
              title: 'Verify Phone',
              onPressed: otpState.isLockedOut ? null : _handleVerify,
              isLoading: _isVerifying,
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: (otpState.countdown == 0 && !otpState.isLockedOut && !_isSending)
                  ? _handleSendOtp
                  : null,
              child: Text(
                otpState.isLockedOut
                    ? 'Locked out (${otpState.lockoutFormattedTime})'
                    : (otpState.countdown > 0
                        ? 'Resend SMS in ${otpState.countdown}s'
                        : (_isSending ? 'Sending SMS...' : 'Resend SMS Code')),
                style: TextStyle(
                  fontSize: 13,
                  color: (otpState.countdown > 0 || otpState.isLockedOut)
                      ? AppColors.textTertiary
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
