import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/utils/validators.dart';

class CountryCode {
  final String code;
  final String name;
  final String flag;
  final String iso;

  const CountryCode({
    required this.code,
    required this.name,
    required this.flag,
    required this.iso,
  });
}

const List<CountryCode> kCountries = [
  CountryCode(code: '+91', name: 'India', flag: '🇮🇳', iso: 'IN'),
  CountryCode(code: '+1', name: 'United States', flag: '🇺🇸', iso: 'US'),
  CountryCode(code: '+1', name: 'Canada', flag: '🇨🇦', iso: 'CA'),
  CountryCode(code: '+44', name: 'United Kingdom', flag: '🇬🇧', iso: 'GB'),
  CountryCode(code: '+61', name: 'Australia', flag: '🇦🇺', iso: 'AU'),
  CountryCode(code: '+49', name: 'Germany', flag: '🇩🇪', iso: 'DE'),
  CountryCode(code: '+33', name: 'France', flag: '🇫🇷', iso: 'FR'),
  CountryCode(code: '+971', name: 'United Arab Emirates', flag: '🇦🇪', iso: 'AE'),
  CountryCode(code: '+966', name: 'Saudi Arabia', flag: '🇸🇦', iso: 'SA'),
  CountryCode(code: '+65', name: 'Singapore', flag: '🇸🇬', iso: 'SG'),
  CountryCode(code: '+81', name: 'Japan', flag: '🇯🇵', iso: 'JP'),
  CountryCode(code: '+86', name: 'China', flag: '🇨🇳', iso: 'CN'),
  CountryCode(code: '+55', name: 'Brazil', flag: '🇧🇷', iso: 'BR'),
  CountryCode(code: '+27', name: 'South Africa', flag: '🇿🇦', iso: 'ZA'),
  CountryCode(code: '+234', name: 'Nigeria', flag: '🇳🇬', iso: 'NG'),
  CountryCode(code: '+254', name: 'Kenya', flag: '🇰🇪', iso: 'KE'),
  CountryCode(code: '+60', name: 'Malaysia', flag: '🇲🇾', iso: 'MY'),
  CountryCode(code: '+62', name: 'Indonesia', flag: '🇮🇩', iso: 'ID'),
  CountryCode(code: '+63', name: 'Philippines', flag: '🇵🇭', iso: 'PH'),
  CountryCode(code: '+64', name: 'New Zealand', flag: '🇳🇿', iso: 'NZ'),
  CountryCode(code: '+34', name: 'Spain', flag: '🇪🇸', iso: 'ES'),
  CountryCode(code: '+39', name: 'Italy', flag: '🇮🇹', iso: 'IT'),
  CountryCode(code: '+31', name: 'Netherlands', flag: '🇳🇱', iso: 'NL'),
  CountryCode(code: '+41', name: 'Switzerland', flag: '🇨🇭', iso: 'CH'),
  CountryCode(code: '+46', name: 'Sweden', flag: '🇸🇪', iso: 'SE'),
  CountryCode(code: '+353', name: 'Ireland', flag: '🇮🇪', iso: 'IE'),
  CountryCode(code: '+52', name: 'Mexico', flag: '🇲🇽', iso: 'MX'),
  CountryCode(code: '+92', name: 'Pakistan', flag: '🇵🇰', iso: 'PK'),
  CountryCode(code: '+880', name: 'Bangladesh', flag: '🇧🇩', iso: 'BD'),
  CountryCode(code: '+94', name: 'Sri Lanka', flag: '🇱🇰', iso: 'LK'),
  CountryCode(code: '+977', name: 'Nepal', flag: '🇳🇵', iso: 'NP'),
  CountryCode(code: '+974', name: 'Qatar', flag: '🇶🇦', iso: 'QA'),
  CountryCode(code: '+965', name: 'Kuwait', flag: '🇰🇼', iso: 'KW'),
  CountryCode(code: '+968', name: 'Oman', flag: '🇴🇲', iso: 'OM'),
  CountryCode(code: '+20', name: 'Egypt', flag: '🇪🇬', iso: 'EG'),
  CountryCode(code: '+90', name: 'Turkey', flag: '🇹🇷', iso: 'TR'),
  CountryCode(code: '+82', name: 'South Korea', flag: '🇰🇷', iso: 'KR'),
  CountryCode(code: '+7', name: 'Russia', flag: '🇷🇺', iso: 'RU'),
];

class AppPhoneField extends StatefulWidget {
  final String label;
  final String countryCode;
  final String? countryIso;
  final ValueChanged<String>? onCountryCodeChange;
  final ValueChanged<CountryCode>? onCountryChange;
  final String value;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBlur;
  final String? error;
  final String placeholder;
  final bool editable;
  final String? helperText;
  final bool isRequired;
  final EdgeInsetsGeometry? margin;

  const AppPhoneField({
    super.key,
    this.label = 'Phone Number',
    this.countryCode = '+91',
    this.countryIso,
    this.onCountryCodeChange,
    this.onCountryChange,
    required this.value,
    this.onChanged,
    this.onBlur,
    this.error,
    this.placeholder = '9876543210',
    this.editable = true,
    this.helperText,
    this.isRequired = false,
    this.margin,
  });

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

int getCountryMaxLength(String iso) {
  return Validators.getCountryPhoneLengths(iso).max;
}

int getCountryMinLength(String iso) {
  return Validators.getCountryPhoneLengths(iso).min;
}

String getCountryPlaceholder(String iso) {
  final cleanIso = iso.toUpperCase();
  switch (cleanIso) {
    case 'IN':
      return '9876543210';
    case 'US':
    case 'CA':
      return '2025550123';
    case 'GB':
      return '7911123456';
    case 'AU':
      return '412345678';
    case 'DE':
      return '15123456789';
    case 'FR':
      return '612345678';
    case 'IT':
      return '3123456789';
    case 'ES':
      return '612345678';
    case 'SG':
      return '81234567';
    case 'AE':
    case 'SA':
      return '501234567';
    case 'JP':
      return '9012345678';
    case 'BR':
      return '11987654321';
    case 'CN':
      return '13800138000';
    default:
      final maxLen = getCountryMaxLength(iso);
      if (maxLen >= 10) return '9876543210'.padRight(maxLen, '0');
      return '9876543210'.substring(0, maxLen);
  }
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _cleanNumber(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.onBlur?.call();
      }
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant AppPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final cleaned = _cleanNumber(widget.value);
      if (_controller.text != cleaned) {
        _controller.value = TextEditingValue(
          text: cleaned,
          selection: TextSelection.collapsed(offset: cleaned.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isIndia =>
      widget.countryCode == '+91' ||
      widget.countryCode == '91' ||
      _currentCountry.iso == 'IN';

  int get _maxDigits => getCountryMaxLength(_currentCountry.iso);

  String _cleanNumber(String val) {
    String d = val.replaceAll(RegExp(r'\D'), '');
    if (_isIndia) {
      if (d.length > 10 && d.startsWith('91')) {
        d = d.substring(2);
      } else if (d.length > 10 && d.startsWith('0')) {
        d = d.replaceFirst(RegExp(r'^0+'), '');
      }
    }
    if (d.length > _maxDigits) {
      d = d.substring(0, _maxDigits);
    }
    return d;
  }

  CountryCode get _currentCountry {
    if (widget.countryIso != null && widget.countryIso!.isNotEmpty) {
      final match = kCountries.firstWhere(
        (c) => c.iso.toUpperCase() == widget.countryIso!.toUpperCase(),
        orElse: () => kCountries[0],
      );
      return match;
    }
    final code = widget.countryCode.startsWith('+')
        ? widget.countryCode
        : '+${widget.countryCode}';
    return kCountries.firstWhere(
      (c) => c.code == code,
      orElse: () => kCountries.firstWhere(
        (c) => code.startsWith(c.code),
        orElse: () => kCountries[0],
      ),
    );
  }

  void _openCountryPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CountryPickerSheet(
        currentCode: widget.countryCode,
        isDark: isDark,
        onSelect: (selected) {
          Navigator.of(ctx).pop();
          widget.onCountryCodeChange?.call(selected.code);
          widget.onCountryChange?.call(selected);

          final newMax = getCountryMaxLength(selected.iso);
          var digits = _controller.text.replaceAll(RegExp(r'\D'), '');
          if (selected.iso == 'IN') {
            if (digits.length > 10 && digits.startsWith('91')) {
              digits = digits.substring(2);
            } else if (digits.length > 10 && digits.startsWith('0')) {
              digits = digits.replaceFirst(RegExp(r'^0+'), '');
            }
          }
          if (digits.length > newMax) {
            digits = digits.substring(0, newMax);
          }
          _controller.text = digits;
          widget.onChanged?.call(digits);
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textLabelColor = isDark ? AppColors.darkTextLabel : AppColors.lightTextLabel;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;
    final bgInput = widget.editable
        ? (isDark ? AppColors.darkBgInput : AppColors.bgInput)
        : (isDark ? AppColors.darkCard : AppColors.surface);
    final borderInput = widget.error != null
        ? errorColor
        : _focusNode.hasFocus
            ? (isDark ? AppColors.darkTextPrimary : AppColors.accentPrimary)
            : (isDark ? AppColors.darkBorderInput : AppColors.borderInput);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Padding(
      padding: widget.margin ?? const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (widget.label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(
                    widget.label,
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

          // Input Row
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: bgInput,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(
                color: borderInput,
                width: _focusNode.hasFocus ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Country Code Trigger
                InkWell(
                  onTap: widget.editable ? () => _openCountryPicker(context) : null,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppBorderRadius.lg - 1),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentCountry.flag,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _currentCountry.code,
                          style: TextStyle(
                            fontSize: AppTypography.fontSizeSm,
                            fontWeight: AppTypography.fontWeightMedium,
                            color: textPrimary,
                          ),
                        ),
                        if (widget.editable) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Phone Digits Text Field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.editable,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(_maxDigits),
                    ],
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeSm,
                      color: textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: getCountryPlaceholder(_currentCountry.iso),
                      hintStyle: TextStyle(
                        fontSize: AppTypography.fontSizeSm,
                        color: isDark
                            ? AppColors.darkTextPlaceholder
                            : AppColors.textPlaceholder,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                    onChanged: (text) {
                      final cleaned = _cleanNumber(text);
                      widget.onChanged?.call(cleaned);
                      setState(() {});
                    },
                  ),
                ),

                // Country-aware digit counter
                if (widget.editable && _maxDigits <= 11 && _controller.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Text(
                      '${_controller.text.length}/$_maxDigits',
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeTiny,
                        fontWeight: AppTypography.fontWeightMedium,
                        color: _controller.text.length == _maxDigits
                            ? AppColors.success
                            : textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Error or Helper text
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
            )
          else if (widget.helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                widget.helperText!,
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

class _CountryPickerSheet extends StatefulWidget {
  final String currentCode;
  final bool isDark;
  final ValueChanged<CountryCode> onSelect;

  const _CountryPickerSheet({
    required this.currentCode,
    required this.isDark,
    required this.onSelect,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _searchQuery = '';

  List<CountryCode> get _filtered {
    if (_searchQuery.trim().isEmpty) return kCountries;
    final q = _searchQuery.toLowerCase().trim();
    return kCountries
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.code.contains(q) ||
            c.iso.toLowerCase().contains(q))
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

    final normCurrent = widget.currentCode.startsWith('+')
        ? widget.currentCode
        : '+${widget.currentCode}';

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      child: Column(
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
                  'Select Country',
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeBase,
                    fontWeight: AppTypography.fontWeightBold,
                    color: textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: textPrimary, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: bgInput,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: borderInput),
              ),
              child: TextField(
                autofocus: false,
                style: TextStyle(fontSize: AppTypography.fontSizeSm, color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search country or code (e.g. US, +1)...',
                  hintStyle: TextStyle(
                    fontSize: AppTypography.fontSizeSm,
                    color: widget.isDark
                        ? AppColors.darkTextPlaceholder
                        : AppColors.textPlaceholder,
                  ),
                  prefixIcon: Icon(Icons.search, color: textSecondary, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),
          Divider(color: borderSubtle, height: 1),

          // Countries List
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => Divider(color: borderSubtle, height: 1),
              itemBuilder: (ctx, index) {
                final c = _filtered[index];
                final isSelected = c.code == normCurrent;
                return ListTile(
                  dense: true,
                  tileColor: isSelected
                      ? (widget.isDark ? AppColors.darkOverlayMedium : AppColors.overlayMedium)
                      : Colors.transparent,
                  leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                  title: Text(
                    c.name,
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeSm,
                      fontWeight: isSelected
                          ? AppTypography.fontWeightBold
                          : AppTypography.fontWeightRegular,
                      color: textPrimary,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.code,
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeSm,
                          color: textSecondary,
                          fontWeight: isSelected
                              ? AppTypography.fontWeightBold
                              : AppTypography.fontWeightRegular,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check,
                          color: widget.isDark
                              ? AppColors.darkAccentPrimary
                              : AppColors.accentPrimary,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  onTap: () => widget.onSelect(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
