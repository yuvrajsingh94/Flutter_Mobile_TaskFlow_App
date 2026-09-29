import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

enum LogoSize { sm, md, lg }

class Logo extends StatelessWidget {
  final dynamic size;
  final bool showWordmark;
  final VoidCallback? onLongPress;

  const Logo({
    super.key,
    this.size = LogoSize.md,
    this.showWordmark = true,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentPrimary = isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary;
    final accentFg = isDark ? AppColors.darkAccentFg : AppColors.accentFg;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    double boxSize;
    double iconSize;
    double textSize;
    double radius;

    if (size is num) {
      boxSize = (size as num).toDouble();
      iconSize = boxSize * 0.55;
      textSize = boxSize * 0.45;
      radius = boxSize * 0.22;
    } else if (size == LogoSize.sm) {
      boxSize = 26;
      iconSize = 16;
      textSize = AppTypography.fontSizeSm;
      radius = 8;
    } else if (size == LogoSize.lg) {
      boxSize = 44;
      iconSize = 26;
      textSize = AppTypography.fontSizeXl;
      radius = 12;
    } else {
      boxSize = 34;
      iconSize = 20;
      textSize = AppTypography.fontSizeMd;
      radius = 8;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: accentPrimary,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Center(
            child: Icon(
              Icons.check,
              size: iconSize,
              color: accentFg,
            ),
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 8),
          Text(
            'TaskFlow',
            style: TextStyle(
              color: textPrimary,
              fontSize: textSize,
              fontWeight: AppTypography.fontWeightBold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );

    if (onLongPress != null) {
      return GestureDetector(
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
