import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

/// Reusable horizontal filter chips styled after TaskFlow's enterprise SaaS design system.
/// Matches `src/screens/admin/TaskManagementScreen.tsx` and `AdminLeaveManagementScreen.tsx`.
class AppFilterChips<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final String Function(T item)? labelBuilder;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const AppFilterChips({
    super.key,
    required this.items,
    required this.selectedItem,
    this.labelBuilder,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary;
    final activeFg = isDark ? AppColors.darkAccentFg : AppColors.lightAccentFg;
    final inactiveBg = isDark ? AppColors.darkBgInput : AppColors.lightBgInput;
    final inactiveBorder = isDark ? AppColors.darkBorderInput : AppColors.lightBorderInput;
    final inactiveFg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final isSelected = item == selectedItem;
          final label = labelBuilder != null ? labelBuilder!(item) : item.toString();

          return Padding(
            padding: EdgeInsets.only(right: item == items.last ? 0 : spacing),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(item),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? activeBg : inactiveBg,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(
                      color: isSelected ? activeBg : inactiveBorder,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeSm,
                        fontWeight: isSelected
                            ? AppTypography.fontWeightBold
                            : AppTypography.fontWeightMedium,
                        color: isSelected ? activeFg : inactiveFg,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
