import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

const List<String> kDOBMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

const List<String> kDOBFullMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

const List<String> kDOBDaysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

enum DOBPickerStage { year, month, day }

class AppDOBPicker extends StatelessWidget {
  final String label;
  final String? value; // YYYY-MM-DD
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBlur;
  final String? error;
  final String? helperText;
  final bool isRequired;
  final bool enabled;
  final EdgeInsetsGeometry? margin;

  const AppDOBPicker({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.onBlur,
    this.error,
    this.helperText,
    this.isRequired = false,
    this.enabled = true,
    this.margin,
  });

  DateTime? _parseValue() {
    if (value == null || value!.isEmpty) return null;
    final parts = value!.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  String _formatDisplay(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.day.toString().padLeft(2, '0');
    final m = kDOBMonths[dt.month - 1];
    final y = dt.year;
    return '$d $m $y';
  }

  void _openDOBPicker(BuildContext context) async {
    if (!enabled) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _parseValue();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DOBPickerSheet(
        initialDate: selected,
        isDark: isDark,
        onSelect: (dt) {
          Navigator.of(ctx).pop();
          final yStr = dt.year.toString();
          final mStr = dt.month.toString().padLeft(2, '0');
          final dStr = dt.day.toString().padLeft(2, '0');
          onChanged?.call('$yStr-$mStr-$dStr');
        },
      ),
    );
    onBlur?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textLabelColor = isDark ? AppColors.darkTextLabel : AppColors.lightTextLabel;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;
    final bgInput = enabled
        ? (isDark ? AppColors.darkBgInput : AppColors.bgInput)
        : (isDark ? AppColors.darkCard : AppColors.surface);
    final borderInput = error != null
        ? errorColor
        : (isDark ? AppColors.darkBorderInput : AppColors.borderInput);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textPlaceholder = isDark ? AppColors.darkTextPlaceholder : AppColors.textPlaceholder;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final parsed = _parseValue();
    final displayText = _formatDisplay(parsed);

    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeSm,
                    fontWeight: AppTypography.fontWeightMedium,
                    color: textLabelColor,
                  ),
                ),
                if (isRequired)
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
            onTap: enabled ? () => _openDOBPicker(context) : null,
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
                      displayText.isNotEmpty ? displayText : 'DD MMM YYYY',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeSm,
                        color: displayText.isNotEmpty ? textPrimary : textPlaceholder,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.cake_outlined,
                    size: 18,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Error / Helper text
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                error!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: errorColor,
                  fontSize: AppTypography.fontSizeXs,
                  fontWeight: AppTypography.fontWeightMedium,
                  height: 1.25,
                ),
              ),
            )
          else if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                helperText!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: AppTypography.fontSizeXs,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DOBPickerSheet extends StatefulWidget {
  final DateTime? initialDate;
  final bool isDark;
  final ValueChanged<DateTime> onSelect;

  const _DOBPickerSheet({
    required this.initialDate,
    required this.isDark,
    required this.onSelect,
  });

  @override
  State<_DOBPickerSheet> createState() => _DOBPickerSheetState();
}

class _DOBPickerSheetState extends State<_DOBPickerSheet> {
  late DOBPickerStage _stage;
  late int _selectedYear;
  late int _selectedMonth; // 0-11

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedYear = widget.initialDate!.year;
      _selectedMonth = widget.initialDate!.month - 1;
      _stage = DOBPickerStage.day;
    } else {
      _selectedYear = DateTime.now().year - 22;
      _selectedMonth = 0;
      _stage = DOBPickerStage.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgCard = widget.isDark ? AppColors.darkCard : AppColors.card;
    final textPrimary = widget.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = widget.isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderSubtle = widget.isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final borderInput = widget.isDark ? AppColors.darkBorderInput : AppColors.borderInput;
    final accentPrimary = widget.isDark ? AppColors.darkAccentPrimary : AppColors.accentPrimary;
    final accentFg = widget.isDark ? AppColors.darkAccentFg : AppColors.accentFg;

    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month - 1; // 0-11
    final currentDay = now.day;
    final years = List.generate(100, (i) => currentYear - i);

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

          // Header with stage breadcrumbs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _stage = DOBPickerStage.year),
                      child: Text(
                        '$_selectedYear',
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeBase,
                          fontWeight: _stage == DOBPickerStage.year
                              ? AppTypography.fontWeightBold
                              : AppTypography.fontWeightRegular,
                          color: _stage == DOBPickerStage.year ? accentPrimary : textSecondary,
                        ),
                      ),
                    ),
                    const Text('  /  ', style: TextStyle(color: AppColors.textTertiary)),
                    InkWell(
                      onTap: () => setState(() => _stage = DOBPickerStage.month),
                      child: Text(
                        kDOBMonths[_selectedMonth],
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeBase,
                          fontWeight: _stage == DOBPickerStage.month
                              ? AppTypography.fontWeightBold
                              : AppTypography.fontWeightRegular,
                          color: _stage == DOBPickerStage.month ? accentPrimary : textSecondary,
                        ),
                      ),
                    ),
                    if (_stage == DOBPickerStage.day) ...[
                      const Text('  /  ', style: TextStyle(color: AppColors.textTertiary)),
                      Text(
                        'Select Day',
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeBase,
                          fontWeight: AppTypography.fontWeightBold,
                          color: accentPrimary,
                        ),
                      ),
                    ],
                  ],
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

          Divider(color: borderSubtle, height: 1),

          // Stage 1: Year selection grid
          if (_stage == DOBPickerStage.year)
            Flexible(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2.2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: years.length,
                itemBuilder: (ctx, i) {
                  final y = years[i];
                  final isSelected = y == _selectedYear;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedYear = y;
                        _stage = DOBPickerStage.month;
                      });
                    },
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? accentPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        border: Border.all(
                          color: isSelected ? accentPrimary : borderSubtle,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$y',
                          style: TextStyle(
                            fontSize: AppTypography.fontSizeSm,
                            fontWeight: isSelected
                                ? AppTypography.fontWeightBold
                                : AppTypography.fontWeightRegular,
                            color: isSelected ? accentFg : textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Stage 2: Month selection grid
          if (_stage == DOBPickerStage.month)
            Flexible(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: 12,
                itemBuilder: (ctx, i) {
                  final isFuture = _selectedYear == currentYear && i > currentMonth;
                  final isSelected = i == _selectedMonth && !isFuture;
                  return InkWell(
                    onTap: isFuture
                        ? null
                        : () {
                            setState(() {
                              _selectedMonth = i;
                              _stage = DOBPickerStage.day;
                            });
                          },
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? accentPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        border: Border.all(
                          color: isSelected ? accentPrimary : borderSubtle,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          kDOBFullMonths[i],
                          style: TextStyle(
                            fontSize: AppTypography.fontSizeSm,
                            fontWeight: isSelected
                                ? AppTypography.fontWeightBold
                                : AppTypography.fontWeightRegular,
                            color: isFuture
                                ? (widget.isDark ? Colors.white24 : Colors.black26)
                                : (isSelected ? accentFg : textPrimary),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Stage 3: Day selection
          if (_stage == DOBPickerStage.day) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Row(
                children: kDOBDaysOfWeek
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: TextStyle(
                                fontSize: AppTypography.fontSizeXs,
                                fontWeight: AppTypography.fontWeightMedium,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Builder(builder: (ctx) {
                  final daysInMonth = DateTime(_selectedYear, _selectedMonth + 2, 0).day;
                  final firstWeekday = DateTime(_selectedYear, _selectedMonth + 1, 1).weekday % 7;

                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: firstWeekday + daysInMonth,
                    itemBuilder: (c, idx) {
                      if (idx < firstWeekday) return const SizedBox();
                      final dayNum = idx - firstWeekday + 1;
                      final isFuture = _selectedYear == currentYear &&
                          _selectedMonth == currentMonth &&
                          dayNum > currentDay;
                      final isSelected = widget.initialDate != null &&
                          widget.initialDate!.year == _selectedYear &&
                          widget.initialDate!.month == _selectedMonth + 1 &&
                          widget.initialDate!.day == dayNum &&
                          !isFuture;

                      return InkWell(
                        onTap: isFuture
                            ? null
                            : () => widget.onSelect(
                                DateTime(_selectedYear, _selectedMonth + 1, dayNum),
                              ),
                        borderRadius: BorderRadius.circular(AppBorderRadius.round),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? accentPrimary : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: AppTypography.fontSizeSm,
                                fontWeight: isSelected
                                    ? AppTypography.fontWeightBold
                                    : AppTypography.fontWeightRegular,
                                color: isFuture
                                    ? (widget.isDark ? Colors.white24 : Colors.black26)
                                    : (isSelected ? accentFg : textPrimary),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
