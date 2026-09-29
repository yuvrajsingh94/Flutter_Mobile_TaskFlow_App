import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';
import 'package:taskflow_flutter/core/widgets/otp_input.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';

class EmailVerificationBanner extends ConsumerStatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  ConsumerState<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState
    extends ConsumerState<EmailVerificationBanner> {
  int _countdown = 0;
  Timer? _timer;
  bool _isSending = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        if (mounted) setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleResend() async {
    if (_countdown > 0 || _isSending) return;
    setState(() => _isSending = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendVerificationEmail();
      if (mounted) {
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Verification code sent to your email.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Failed to send verification: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _openVerificationDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (ctx) => EmailVerificationDialog(
        email: email,
        onVerified: () {
          final user = ref.read(authNotifierProvider).user;
          if (user != null) {
            ref.read(authNotifierProvider.notifier).updateUser(
                  user.copyWith(emailVerified: true),
                );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    if (user == null || user.emailVerified) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerBg = isDark ? const Color(0xFF2A1C0A) : const Color(0xFFFFFBEB);
    final bannerBorder = isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A);
    final textCol = isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bannerBg,
        border: Border(
          bottom: BorderSide(color: bannerBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: Color(0xFFD97706),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'Please verify your email (',
                    style: TextStyle(
                      fontSize: 13,
                      color: textCol,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: user.email,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: ') to ensure account security.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 28),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () => _openVerificationDialog(context, user.email),
                icon: const Icon(Icons.check_circle_outline, size: 15),
                label: const Text(
                  'Verify Now',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF92400E),
                  side: const BorderSide(color: Color(0xFFFCD34D)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: (_countdown == 0 && !_isSending) ? _handleResend : null,
                child: Text(
                  _countdown > 0 ? 'Resend (${_countdown}s)' : 'Resend Code',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmailVerificationDialog extends ConsumerStatefulWidget {
  final String email;
  final VoidCallback onVerified;

  const EmailVerificationDialog({
    super.key,
    required this.email,
    required this.onVerified,
  });

  static Future<void> show(
    BuildContext context,
    String email, {
    VoidCallback? onVerified,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EmailVerificationDialog(
        email: email,
        onVerified: onVerified ?? () {},
      ),
    );
  }

  @override
  ConsumerState<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState
    extends ConsumerState<EmailVerificationDialog> {
  String _otp = '';
  bool _isVerifying = false;
  String? _errorMessage;

  Future<void> _handleVerify() async {
    if (_otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit verification code.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyEmailCurrent(_otp);

      if (mounted) {
        widget.onVerified();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Email verified successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Verify Email Address',
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
              'Enter the 6-digit code sent to ${widget.email}',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 20),

            if (_errorMessage != null) ...[
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
              onChanged: (val) {
                setState(() {
                  _otp = val;
                  if (_errorMessage != null) _errorMessage = null;
                });
              },
              onCompleted: (val) {
                setState(() => _otp = val);
                _handleVerify();
              },
            ),
            const SizedBox(height: 24),

            AppButton(
              title: 'Verify Code',
              onPressed: _handleVerify,
              isLoading: _isVerifying,
            ),
          ],
        ),
      ),
    );
  }
}
