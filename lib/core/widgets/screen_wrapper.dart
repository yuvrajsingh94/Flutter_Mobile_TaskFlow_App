import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

class ScreenWrapper extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? rightAction;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Future<void> Function()? onRefresh;
  final bool scrollable;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final bool dismissKeyboardOnTap;

  const ScreenWrapper({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.onBack,
    this.rightAction,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.onRefresh,
    this.scrollable = true,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.backgroundColor,
    this.dismissKeyboardOnTap = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? AppColors.darkBackground : AppColors.background);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;

    // Header Widget if title, onBack, or rightAction are supplied
    Widget? customHeader;
    if (title != null || onBack != null || rightAction != null) {
      customHeader = Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderSubtle, width: 1)),
        ),
        child: Row(
          children: [
            if (onBack != null) ...[
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.chevron_left, size: 24, color: textPrimary),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeLg,
                        fontWeight: AppTypography.fontWeightBold,
                        color: textPrimary,
                      ),
                    ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeXs,
                        color: textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (rightAction != null) rightAction!,
          ],
        ),
      );
    }

    Widget body = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (scrollable) {
      body = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: body,
      );
    }

    if (onRefresh != null) {
      body = RefreshIndicator(
        color: isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary,
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        onRefresh: onRefresh!,
        child: body,
      );
    }

    if (dismissKeyboardOnTap) {
      body = GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: appBar,
      body: SafeArea(
        child: Column(
          children: [
            if (customHeader != null) customHeader,
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
