import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, danger, destructive, ghost }
enum ButtonSize { sm, md, lg }

/// 1-to-1 replica of `src/components/ui/Button.tsx`
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool disabled;
  final Widget? icon;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    String? text,
    String? title,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    bool? isLoading,
    bool? loading,
    this.disabled = false,
    this.icon,
    this.leftIcon,
    this.rightIcon,
    this.width,
    this.height,
    this.textStyle,
    this.borderRadius,
    this.padding,
  }) : text = text ?? title ?? '',
       isLoading = loading ?? isLoading ?? false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.secondary:
        bgColor = isDark ? AppColors.darkOverlayMedium : AppColors.lightOverlayMedium;
        textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        break;
      case ButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        borderSide = BorderSide(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
          width: 1,
        );
        break;
      case ButtonVariant.danger:
      case ButtonVariant.destructive:
        bgColor = isDark ? AppColors.darkError : AppColors.lightError;
        textColor = Colors.white;
        break;
      case ButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        break;
      case ButtonVariant.primary:
        bgColor = isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary;
        textColor = isDark ? AppColors.darkAccentFg : AppColors.lightAccentFg;
        break;
    }

    final double verticalPadding;
    final double horizontalPadding;
    final double fontSize;

    switch (size) {
      case ButtonSize.sm:
        verticalPadding = 8;
        horizontalPadding = 12;
        fontSize = AppTypography.sm;
        break;
      case ButtonSize.lg:
        verticalPadding = 16;
        horizontalPadding = 24;
        fontSize = AppTypography.md;
        break;
      case ButtonSize.md:
        verticalPadding = 12;
        horizontalPadding = 18;
        fontSize = AppTypography.base;
        break;
    }

    final isClickable = onPressed != null && !isLoading && !disabled;
    final effectiveLeftIcon = leftIcon ?? icon;

    Widget buttonBody = Center(
      child: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (effectiveLeftIcon != null) ...[
                  effectiveLeftIcon,
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isClickable ? textColor : textColor.withValues(alpha: 0.5),
                      fontSize: fontSize,
                      fontWeight: AppTypography.semibold,
                    ).merge(textStyle),
                  ),
                ),
                if (rightIcon != null) ...[
                  const SizedBox(width: 8),
                  rightIcon!,
                ],
              ],
            ),
    );

    final effectiveRadius = borderRadius ?? AppBorderRadius.lg;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isClickable ? bgColor : bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: borderSide != BorderSide.none
            ? Border.fromBorderSide(borderSide)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isClickable ? onPressed : null,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            child: buttonBody,
          ),
        ),
      ),
    );
  }
}

