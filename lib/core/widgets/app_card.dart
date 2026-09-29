import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

/// 1-to-1 replica of `src/components/ui/Card.tsx`
/// - Background: theme card color (light #FFFFFF, dark #1C1C1F)
/// - Border: 1px borderSubtle (light #EAE8E3, dark #2E2E32)
/// - Radius: 16px (AppBorderRadius.card)
/// - Padding: 14px (AppSpacing.cardPadding)
/// - Subtle elevation shadow
/// - Optional colored accent stripe on left edge (4px wide, rounded corners)
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.accentColor,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? AppColors.darkBgCard : AppColors.lightBgCard);
    final border = borderColor ?? (isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle);

    Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    if (accentColor != null) {
      content = Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppBorderRadius.card),
                  bottomLeft: Radius.circular(AppBorderRadius.card),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: content,
          ),
        ],
      );
    }

    final cardDecoration = BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(AppBorderRadius.card),
      border: Border.all(color: border, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );

    if (onTap != null) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        decoration: cardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppBorderRadius.card),
            child: content,
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
