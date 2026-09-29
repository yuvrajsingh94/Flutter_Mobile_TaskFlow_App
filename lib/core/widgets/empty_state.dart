import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/app_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionTitle;
  final String? actionText;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.description,
    this.actionTitle,
    this.actionText,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final overlayMedium = isDark ? AppColors.darkOverlayMedium : AppColors.overlayMedium;

    final btnText = actionTitle ?? actionText ?? actionLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.huge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: overlayMedium,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 36,
                  color: textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textPrimary,
                fontSize: AppTypography.fontSizeBase,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: AppTypography.fontSizeXs,
                  height: 1.4,
                ),
              ),
            ],
            if (btnText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                title: btnText,
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
