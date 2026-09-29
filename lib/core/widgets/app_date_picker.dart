import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

const List<String> kMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

const List<String> kShortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

const List<String> kDaysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

class AppDatePicker extends StatelessWidget {
  final String? label;
  final String? value; // YYYY-MM-DD
  final ValueChanged<String>? onChanged;
  final String? error;
  final String? helperText;
  final bool isRequired;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String placeholder;
  final bool enabled;

  const AppDatePicker({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.error,
    this.helperText,
    this.isRequired = false,
    this.minDate,
    this.maxDate,
    this.placeholder = 'Select date',
    this.enabled = true,
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
    final m = kShortMonths[dt.month - 1];
    final y = dt.year;
    return '$d $m $y';
  }

  void _openDatePicker(BuildContext context) {
    if (!enabled) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _parseValue();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DatePickerSheet(
        initialDate: selected,
        minDate: minDate,
        maxDate: maxDate,
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textLabelColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final bgInput = enabled
        ? (isDark ? AppColors.darkBgInput : AppColors.bgInput)
        : (isDark ? AppColors.darkCard : AppColors.surface);
    final borderInput = error != null
        ? AppColors.error
        : (isDark ? AppColors.darkBorderInput : AppColors.borderInput);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textPlaceholder = isDark ? AppColors.darkTextPlaceholder : AppColors.textPlaceholder;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final parsed = _parseValue();
    final displayText = _formatDisplay(parsed);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (label != null && label!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeSm,
                      fontWeight: AppTypography.fontWeightMedium,
                      color: textLabelColor,
                    ),
                  ),
                  if (isRequired)
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: AppTypography.fontSizeSm,
                        fontWeight: AppTypography.fontWeightMedium,
                      ),
                    ),
                ],
              ),
            ),

          // Trigger Box
          InkWell(
            onTap: enabled ? () => _openDatePicker(context) : null,
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: bgInput,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: borderInput, width: 1.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText.isNotEmpty ? displayText : placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeSm,
                        color: displayText.isNotEmpty ? textPrimary : textPlaceholder,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
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
              padding: const EdgeInsets.only(top: AppSpacing.tiny),
              child: Text(
                error!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: AppTypography.fontSizeXs,
                ),
              ),
            )
          else if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.tiny),
              child: Text(
                helperText!,
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

class _DatePickerSheet extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool isDark;
  final ValueChanged<DateTime> onSelect;

  const _DatePickerSheet({
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
    required this.isDark,
    required this.onSelect,
  });

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late int _viewYear;
  late int _viewMonth; // 0-indexed (0 to 11)

  @override
  void initState() {
    super.initState();
    final base = widget.initialDate ??
        (widget.minDate != null && widget.minDate!.isAfter(DateTime.now())
            ? widget.minDate!
            : DateTime.now());
    _viewYear = base.year;
    _viewMonth = base.month - 1;
  }

  void _prevMonth() {
    setState(() {
      if (_viewMonth == 0) {
        _viewMonth = 11;
        _viewYear--;
      } else {
        _viewMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_viewMonth == 11) {
        _viewMonth = 0;
        _viewYear++;
      } else {
        _viewMonth++;
      }
    });
  }

  bool _isDayDisabled(int day) {
    final check = DateTime(_viewYear, _viewMonth + 1, day);
    if (widget.minDate != null) {
      final min = DateTime(widget.minDate!.year, widget.minDate!.month, widget.minDate!.day);
      if (check.isBefore(min)) return true;
    }
    if (widget.maxDate != null) {
      final max = DateTime(widget.maxDate!.year, widget.maxDate!.month, widget.maxDate!.day);
      if (check.isAfter(max)) return true;
    }
    return false;
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

    final daysInMonth = DateTime(_viewYear, _viewMonth + 2, 0).day;
    final firstWeekday = DateTime(_viewYear, _viewMonth + 1, 1).weekday % 7; // Sunday=0

    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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

          // Header Month Navigator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: Icon(Icons.chevron_left, color: textPrimary),
                ),
                Text(
                  '${kMonths[_viewMonth]} $_viewYear',
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeBase,
                    fontWeight: AppTypography.fontWeightBold,
                    color: textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: Icon(Icons.chevron_right, color: textPrimary),
                ),
              ],
            ),
          ),

          Divider(color: borderSubtle, height: 1),

          // Day-of-week headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Row(
              children: kDaysOfWeek
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

          // Calendar Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (ctx, index) {
                if (index < firstWeekday) {
                  return const SizedBox();
                }
                final dayNum = index - firstWeekday + 1;
                final isSelected = widget.initialDate != null &&
                    widget.initialDate!.year == _viewYear &&
                    widget.initialDate!.month == _viewMonth + 1 &&
                    widget.initialDate!.day == dayNum;
                final disabled = _isDayDisabled(dayNum);

                return InkWell(
                  onTap: disabled
                      ? null
                      : () => widget.onSelect(
                            DateTime(_viewYear, _viewMonth + 1, dayNum),
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
                          color: disabled
                              ? (widget.isDark
                                  ? AppColors.darkTextPlaceholder
                                  : AppColors.textPlaceholder)
                              : isSelected
                                  ? accentFg
                                  : textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
