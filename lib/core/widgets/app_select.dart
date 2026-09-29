import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

class SelectOption {
  final String label;
  final String value;

  const SelectOption({required this.label, required this.value});
}

class AppSelect extends StatefulWidget {
  final String? label;
  final List<SelectOption> options;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? error;
  final String placeholder;
  final bool isRequired;
  final bool searchable;
  final bool enabled;
  final VoidCallback? onBlur;
  final EdgeInsetsGeometry? margin;

  const AppSelect({
    super.key,
    this.label,
    required this.options,
    this.value,
    this.onChanged,
    this.onBlur,
    this.error,
    this.placeholder = 'Select an option...',
    this.isRequired = false,
    this.searchable = false,
    this.enabled = true,
    this.margin,
  });

  @override
  State<AppSelect> createState() => _AppSelectState();
}

class _AppSelectState extends State<AppSelect> {
  void _openSelectionModal(BuildContext context) async {
    if (!widget.enabled) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SelectModalSheet(
        title: widget.label ?? 'Select Option',
        options: widget.options,
        selectedValue: widget.value,
        searchable: widget.searchable,
        isDark: isDark,
        onSelect: (val) {
          Navigator.of(ctx).pop();
          widget.onChanged?.call(val);
        },
      ),
    );
    widget.onBlur?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textLabelColor = isDark ? AppColors.darkTextLabel : AppColors.lightTextLabel;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;
    final bgInput = widget.enabled
        ? (isDark ? AppColors.darkBgInput : AppColors.bgInput)
        : (isDark ? AppColors.darkCard : AppColors.surface);
    final borderInput = widget.error != null
        ? errorColor
        : (isDark ? AppColors.darkBorderInput : AppColors.borderInput);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textPlaceholder = isDark ? AppColors.darkTextPlaceholder : AppColors.textPlaceholder;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final selected = widget.options
        .where((o) => o.value == widget.value)
        .firstOrNull;

    return Padding(
      padding: widget.margin ?? const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (widget.label != null && widget.label!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeSm,
                      fontWeight: AppTypography.fontWeightMedium,
                      color: textLabelColor,
                    ),
                  ),
                  if (widget.isRequired)
                    Text(
                      ' *',
                      style: TextStyle(
                        color: errorColor,
                        fontSize: AppTypography.fontSizeSm,
                        fontWeight: AppTypography.fontWeightMedium,
                      ),
                    ),
                ],
              ),
            ),

          // Trigger Box
          InkWell(
            onTap: widget.enabled ? () => _openSelectionModal(context) : null,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: bgInput,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(color: borderInput, width: 1.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selected != null ? selected.label : widget.placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeSm,
                        color: selected != null ? textPrimary : textPlaceholder,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Error text
          if (widget.error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                widget.error!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: errorColor,
                  fontSize: AppTypography.fontSizeXs,
                  fontWeight: AppTypography.fontWeightMedium,
                  height: 1.25,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectModalSheet extends StatefulWidget {
  final String title;
  final List<SelectOption> options;
  final String? selectedValue;
  final bool searchable;
  final bool isDark;
  final ValueChanged<String> onSelect;

  const _SelectModalSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.searchable,
    required this.isDark,
    required this.onSelect,
  });

  @override
  State<_SelectModalSheet> createState() => _SelectModalSheetState();
}

class _SelectModalSheetState extends State<_SelectModalSheet> {
  String _searchQuery = '';

  List<SelectOption> get _filtered {
    if (!widget.searchable || _searchQuery.trim().isEmpty) return widget.options;
    final q = _searchQuery.toLowerCase().trim();
    return widget.options
        .where((opt) => opt.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bgCard = widget.isDark ? AppColors.darkCard : AppColors.card;
    final textPrimary = widget.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = widget.isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderSubtle = widget.isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final bgInput = widget.isDark ? AppColors.darkBgInput : AppColors.bgInput;
    final borderInput = widget.isDark ? AppColors.darkBorderInput : AppColors.borderInput;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.70,
      ),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: borderInput,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeBase,
                    fontWeight: AppTypography.fontWeightBold,
                    color: textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Search Box if searchable
          if (widget.searchable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: bgInput,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: borderInput),
                ),
                child: TextField(
                  style: TextStyle(fontSize: AppTypography.fontSizeSm, color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search options...',
                    hintStyle: TextStyle(
                      fontSize: AppTypography.fontSizeSm,
                      color: widget.isDark
                          ? AppColors.darkTextPlaceholder
                          : AppColors.textPlaceholder,
                    ),
                    prefixIcon: Icon(Icons.search, color: textSecondary, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ),

          Divider(color: borderSubtle, height: 1),

          // Options List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => Divider(color: borderSubtle, height: 1),
              itemBuilder: (ctx, index) {
                final opt = _filtered[index];
                final isSelected = opt.value == widget.selectedValue;
                return ListTile(
                  dense: true,
                  tileColor: isSelected
                      ? (widget.isDark ? AppColors.darkOverlayMedium : AppColors.overlayMedium)
                      : Colors.transparent,
                  title: Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeSm,
                      fontWeight: isSelected
                          ? AppTypography.fontWeightBold
                          : AppTypography.fontWeightRegular,
                      color: isSelected
                          ? (widget.isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary)
                          : textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: widget.isDark
                              ? AppColors.darkAccentPrimary
                              : AppColors.accentPrimary,
                          size: 18,
                        )
                      : null,
                  onTap: () => widget.onSelect(opt.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
