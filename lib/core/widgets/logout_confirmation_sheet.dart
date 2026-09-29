import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';

/// Displays the native Android Material 3 Logout Confirmation Modal Bottom Sheet.
///
/// Implements Material 3 specifications:
/// - 28dp top corner radius (extraLarge shape token)
/// - Centered Material 3 drag handle
/// - Circular icon container with [Icons.logout]
/// - Static 'Log Out' headline
/// - Dynamic role-aware confirmation copy sourced from [UserRoleLabel]
/// - Vertically stacked, full-width destructive and neutral action buttons (>= 48dp touch targets)
/// - Medium haptic feedback triggered on confirmation before the logout callback runs
/// - Zero side-effects on dismissal via cancel, scrim tap, or downward drag
Future<void> showLogoutConfirmationSheet({
  required BuildContext context,
  required FutureOr<void> Function() onConfirmLogout,
  UserRole? role,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => LogoutConfirmationSheet(
      role: role,
      onConfirm: () async {
        Navigator.of(sheetContext).pop();
        await onConfirmLogout();
      },
      onCancel: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

/// Material 3 Modal Bottom Sheet Content for Logout Confirmation.
class LogoutConfirmationSheet extends StatefulWidget {
  final UserRole? role;
  final FutureOr<void> Function() onConfirm;
  final VoidCallback onCancel;

  const LogoutConfirmationSheet({
    super.key,
    this.role,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<LogoutConfirmationSheet> createState() =>
      _LogoutConfirmationSheetState();
}

class _LogoutConfirmationSheetState extends State<LogoutConfirmationSheet> {
  bool _isLoggingOut = false;

  Future<void> _handleConfirm() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    // Haptic feedback executes strictly before logout callback
    await HapticFeedback.mediumImpact();

    await widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Drag Handle ──────────────────────────────────────────────
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Logout Icon ──────────────────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 28,
                  color: colorScheme.error,
                ),
              ),

              const SizedBox(height: 16),

              // ── Title ────────────────────────────────────────────────────
              Text(
                'Log Out',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              // ── Role-Aware Confirmation Copy ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.role.logoutConfirmationMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Log Out Button (Destructive, Full-Width) ─────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isLoggingOut ? null : _handleConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Log Out'),
                ),
              ),

              const SizedBox(height: 12),

              // ── Cancel Button (Neutral, Full-Width) ──────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isLoggingOut ? null : widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
