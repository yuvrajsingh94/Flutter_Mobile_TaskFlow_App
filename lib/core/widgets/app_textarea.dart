import 'package:flutter/material.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

class AppTextarea extends StatefulWidget {
  final String label;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? error;
  final int? maxLength;
  final bool isRequired;
  final String? helperText;
  final String? placeholder;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final VoidCallback? onBlur;
  final EdgeInsetsGeometry? margin;

  const AppTextarea({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.onBlur,
    this.error,
    this.maxLength,
    this.isRequired = false,
    this.helperText,
    this.placeholder,
    this.minLines = 4,
    this.maxLines = 8,
    this.enabled = true,
    this.margin,
  });

  @override
  State<AppTextarea> createState() => _AppTextareaState();
}

class _AppTextareaState extends State<AppTextarea> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.onBlur != null) {
        widget.onBlur!();
      }
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant AppTextarea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value!,
        selection: TextSelection.collapsed(offset: widget.value!.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textLabelColor = isDark ? AppColors.darkTextLabel : AppColors.lightTextLabel;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textPlaceholder = isDark ? AppColors.darkTextPlaceholder : AppColors.textPlaceholder;
    final bgInput = widget.enabled
        ? (isDark ? AppColors.darkBgInput : AppColors.bgInput)
        : (isDark ? AppColors.darkCard : AppColors.surface);

    final currentLength = _controller.text.length;
    final isNearLimit = widget.maxLength != null &&
        currentLength > (widget.maxLength! * 0.95).floor();

    return Padding(
      padding: widget.margin ?? const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Label on left, Counter on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeSm,
                          fontWeight: AppTypography.fontWeightMedium,
                          color: textLabelColor,
                        ),
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
              if (widget.maxLength != null)
                Text(
                  '$currentLength/${widget.maxLength}',
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeXs,
                    fontWeight: AppTypography.fontWeightMedium,
                    color: isNearLimit ? errorColor : textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Native Multiline Input Box with authentic 4-sided rounded border
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            style: TextStyle(
              fontSize: AppTypography.fontSizeSm,
              color: textPrimary,
              height: 1.4,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                fontSize: AppTypography.fontSizeSm,
                color: textPlaceholder,
              ),
              filled: true,
              fillColor: bgInput,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorderInput : AppColors.borderInput,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                borderSide: BorderSide(
                  color: widget.error != null
                      ? errorColor
                      : (isDark ? AppColors.darkBorderInput : AppColors.borderInput),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                borderSide: BorderSide(
                  color: widget.error != null
                      ? errorColor
                      : (isDark ? AppColors.darkTextPrimary : AppColors.accentPrimary),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                borderSide: BorderSide(
                  color: errorColor,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                borderSide: BorderSide(
                  color: errorColor,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (text) {
              widget.onChanged?.call(text);
              setState(() {});
            },
          ),

          // Error / Helper text
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
