import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';

enum ConfirmVariant { danger, warning, info }

class ConfirmDialog {
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    ConfirmVariant variant = ConfirmVariant.info,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ConfirmDialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return _ConfirmDialogWidget(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          variant: variant,
          isPrompt: false,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child,
        );
      },
    );
    return result ?? false;
  }

  static Future<String?> prompt(
    BuildContext context, {
    required String title,
    required String message,
    String? placeholder,
    String? defaultValue,
    bool required = false,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    ConfirmVariant variant = ConfirmVariant.info,
  }) async {
    final result = await showGeneralDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PromptDialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return _ConfirmDialogWidget(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          variant: variant,
          isPrompt: true,
          placeholder: placeholder,
          defaultValue: defaultValue,
          isRequired: required,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child,
        );
      },
    );

    if (result is String) return result;
    return null;
  }
}

class _ConfirmDialogWidget extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final ConfirmVariant variant;
  final bool isPrompt;
  final String? placeholder;
  final String? defaultValue;
  final bool isRequired;

  const _ConfirmDialogWidget({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.variant,
    required this.isPrompt,
    this.placeholder,
    this.defaultValue,
    this.isRequired = false,
  });

  @override
  State<_ConfirmDialogWidget> createState() => _ConfirmDialogWidgetState();
}

class _ConfirmDialogWidgetState extends State<_ConfirmDialogWidget> {
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: widget.defaultValue ?? '');
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCard = isDark ? AppColors.darkCard : AppColors.card;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final bgInput = isDark ? AppColors.darkBgInput : AppColors.bgInput;
    final borderInput = isDark ? AppColors.darkBorderInput : AppColors.borderInput;

    IconData icon;
    Color iconColor;
    switch (widget.variant) {
      case ConfirmVariant.danger:
        icon = Icons.error_outline_rounded;
        iconColor = AppColors.error;
        break;
      case ConfirmVariant.warning:
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.warning;
        break;
      case ConfirmVariant.info:
        icon = Icons.info_outline_rounded;
        iconColor = isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary;
        break;
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 340),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(AppBorderRadius.card),
              border: Border.all(color: borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon & Title Row
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeBase,
                          fontWeight: AppTypography.fontWeightBold,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Message
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeSm,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),

                // Prompt Input
                if (widget.isPrompt) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: bgInput,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(color: borderInput),
                    ),
                    child: TextField(
                      controller: _promptController,
                      autofocus: true,
                      style: TextStyle(fontSize: AppTypography.fontSizeSm, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: widget.placeholder ?? 'Enter value...',
                        hintStyle: TextStyle(
                          fontSize: AppTypography.fontSizeSm,
                          color: isDark ? AppColors.darkTextPlaceholder : AppColors.textPlaceholder,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(widget.isPrompt ? null : false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textSecondary,
                        side: BorderSide(color: borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        minimumSize: const Size(0, 40),
                      ),
                      child: Text(
                        widget.cancelText,
                        style: const TextStyle(
                          fontSize: AppTypography.fontSizeSm,
                          fontWeight: AppTypography.fontWeightMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Confirm Button
                    AppButton(
                      title: widget.confirmText,
                      variant: widget.variant == ConfirmVariant.danger
                          ? ButtonVariant.danger
                          : ButtonVariant.primary,
                      size: ButtonSize.sm,
                      onPressed: () {
                        if (widget.isPrompt) {
                          final text = _promptController.text.trim();
                          if (widget.isRequired && text.isEmpty) return;
                          Navigator.of(context).pop(text);
                        } else {
                          Navigator.of(context).pop(true);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
