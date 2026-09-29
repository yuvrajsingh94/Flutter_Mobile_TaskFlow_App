import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int kDefaultOtpCooldownSecs = 60;
const int kMaxOtpAttempts = 6;
const int kLockoutDurationSecs = 600; // 10 minutes

const String _timestampPrefix = '@taskflow_otp_ts_';
const String _attemptsPrefix = '@taskflow_otp_att_';
const String _lockoutPrefix = '@taskflow_otp_lock_';

String formatOtpTime(int seconds) {
  if (seconds <= 0) return '00:00';
  final mins = seconds ~/ 60;
  final secs = seconds % 60;
  return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

class OtpCooldownState {
  final int countdown;
  final int attempts;
  final int lockoutRemaining;
  final String target;

  const OtpCooldownState({
    this.countdown = 0,
    this.attempts = 0,
    this.lockoutRemaining = 0,
    this.target = '',
  });

  bool get isLockedOut => lockoutRemaining > 0;
  int get remainingAttempts => (kMaxOtpAttempts - attempts).clamp(0, kMaxOtpAttempts);
  String get formattedTime => formatOtpTime(countdown);
  String get lockoutFormattedTime => formatOtpTime(lockoutRemaining);

  OtpCooldownState copyWith({
    int? countdown,
    int? attempts,
    int? lockoutRemaining,
    String? target,
  }) {
    return OtpCooldownState(
      countdown: countdown ?? this.countdown,
      attempts: attempts ?? this.attempts,
      lockoutRemaining: lockoutRemaining ?? this.lockoutRemaining,
      target: target ?? this.target,
    );
  }
}

class OtpCooldownNotifier extends StateNotifier<OtpCooldownState> {
  Timer? _timer;

  OtpCooldownNotifier() : super(const OtpCooldownState()) {
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.countdown > 0 || state.lockoutRemaining > 0) {
        final newCountdown = state.countdown > 0 ? state.countdown - 1 : 0;
        final newLockout = state.lockoutRemaining > 0 ? state.lockoutRemaining - 1 : 0;
        // If lockout just expired via timer, reset attempts as well
        final newAttempts = (state.lockoutRemaining > 0 && newLockout == 0) ? 0 : state.attempts;
        state = state.copyWith(
          countdown: newCountdown,
          lockoutRemaining: newLockout,
          attempts: newAttempts,
        );
      }
    });
  }

  /// Syncs/rehydrates state for an email or phone target from persistent storage
  Future<void> rehydrate(String target) async {
    if (target.trim().isEmpty) return;
    final cleanTarget = target.trim().toLowerCase();

    try {
      final prefs = await SharedPreferences.getInstance();
      final tsRaw = prefs.getInt('$_timestampPrefix$cleanTarget');
      final attRaw = prefs.getInt('$_attemptsPrefix$cleanTarget');
      final lockRaw = prefs.getInt('$_lockoutPrefix$cleanTarget');

      int currentLockout = 0;
      int currentCountdown = 0;
      int currentAttempts = attRaw ?? 0;

      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. Lockout check
      if (lockRaw != null) {
        final remaining = ((lockRaw - now) / 1000).ceil();
        if (remaining > 0) {
          currentLockout = remaining;
        } else {
          currentLockout = 0;
          currentAttempts = 0;
          await prefs.remove('$_lockoutPrefix$cleanTarget');
          await prefs.remove('$_attemptsPrefix$cleanTarget');
        }
      }

      // 2. Cooldown check
      if (tsRaw != null) {
        final elapsed = ((now - tsRaw) / 1000).floor();
        final remaining = kDefaultOtpCooldownSecs - elapsed;
        currentCountdown = remaining > 0 ? remaining : 0;
      }

      state = OtpCooldownState(
        countdown: currentCountdown,
        attempts: currentAttempts,
        lockoutRemaining: currentLockout,
        target: cleanTarget,
      );
    } catch (_) {
      state = state.copyWith(target: cleanTarget);
    }
  }

  /// Starts standard 60-second cooldown
  Future<void> startCooldown([String? target]) async {
    final tgt = (target ?? state.target).trim().toLowerCase();
    if (tgt.isEmpty) return;

    state = state.copyWith(countdown: kDefaultOtpCooldownSecs, target: tgt);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_timestampPrefix$tgt', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Records a failed verification attempt and locks out after 7 attempts
  Future<void> recordFailedAttempt([String? target]) async {
    final tgt = (target ?? state.target).trim().toLowerCase();
    if (tgt.isEmpty) return;

    final nextAttempts = state.attempts + 1;
    int nextLockout = state.lockoutRemaining;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_attemptsPrefix$tgt', nextAttempts);

      if (nextAttempts >= kMaxOtpAttempts) {
        final lockoutUntil = DateTime.now().millisecondsSinceEpoch + (kLockoutDurationSecs * 1000);
        await prefs.setInt('$_lockoutPrefix$tgt', lockoutUntil);
        nextLockout = kLockoutDurationSecs;
      }
    } catch (_) {}

    state = state.copyWith(
      attempts: nextAttempts,
      lockoutRemaining: nextLockout,
      target: tgt,
    );
  }

  /// Explicit lockout (e.g. from backend 429 response)
  Future<void> startLockout({int durationSecs = kLockoutDurationSecs, String? target}) async {
    final tgt = (target ?? state.target).trim().toLowerCase();
    if (tgt.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutUntil = DateTime.now().millisecondsSinceEpoch + (durationSecs * 1000);
      await prefs.setInt('$_lockoutPrefix$tgt', lockoutUntil);
    } catch (_) {}

    state = state.copyWith(
      lockoutRemaining: durationSecs,
      target: tgt,
    );
  }

  /// Resets all counters upon successful verification
  Future<void> resetAttempts([String? target]) async {
    final tgt = (target ?? state.target).trim().toLowerCase();
    if (tgt.isEmpty) return;

    state = state.copyWith(
      attempts: 0,
      lockoutRemaining: 0,
      countdown: 0,
      target: tgt,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_timestampPrefix$tgt');
      await prefs.remove('$_attemptsPrefix$tgt');
      await prefs.remove('$_lockoutPrefix$tgt');
    } catch (_) {}
  }

  /// Formats polite enterprise attempts remaining message
  static String formatAttemptsRemaining(int remaining) {
    return 'Invalid OTP code. $remaining ${remaining == 1 ? 'attempt' : 'attempts'} remaining.';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final otpCooldownProvider =
    StateNotifierProvider.autoDispose<OtpCooldownNotifier, OtpCooldownState>((ref) {
  return OtpCooldownNotifier();
});
