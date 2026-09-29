import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

class AppCheckbox extends StatelessWidget {
  final String? label;
  final Widget? labelWidget;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool disabled;

  const AppCheckbox({
    super.key,
    this.label,
    this.labelWidget,
    required this.value,
    this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentPrimary = isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary;
    final accentFg = isDark ? AppColors.darkAccentFg : AppColors.accentFg;
    final borderInput = isDark ? AppColors.darkBorderInput : AppColors.borderInput;
    final bgCard = isDark ? AppColors.darkCard : AppColors.card;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return InkWell(
      onTap: disabled ? null : () => onChanged?.call(!value),
      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: value ? accentPrimary : bgCard,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                border: Border.all(
                  color: value ? accentPrimary : borderInput,
                  width: 1.5,
                ),
              ),
              child: value
                  ? Center(
                      child: Icon(
                        Icons.check,
                        size: 13,
                        color: accentFg,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            if (labelWidget != null)
              Flexible(child: labelWidget!)
            else if (label != null)
              Flexible(
                child: Text(
                  label!,
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeXs,
                    fontWeight: AppTypography.fontWeightMedium,
                    color: disabled
                        ? (isDark ? AppColors.darkTextPlaceholder : AppColors.textPlaceholder)
                        : textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
