import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

/// 1-to-1 replica of `src/components/ui/Input.tsx` and `PasswordInput.tsx`
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? placeholder;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isRequired;
  final bool showCounter;
  final int? maxLength;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onBlur;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? errorText;
  final String? helperText;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? margin;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.placeholder,
    this.controller,
    bool? isPassword,
    bool? obscureText,
    this.isRequired = false,
    this.showCounter = false,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onBlur,
    this.prefixIcon,
    this.suffixIcon,
    this.leftIcon,
    this.rightIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    String? error,
    String? errorText,
    this.helperText,
    this.focusNode,
    this.margin,
  }) : isPassword = obscureText ?? isPassword ?? false,
       errorText = error ?? errorText;

  const AppTextField.password({
    super.key,
    this.label,
    this.hint,
    this.placeholder,
    this.controller,
    this.isRequired = false,
    this.showCounter = false,
    this.maxLength = 64,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onBlur,
    this.prefixIcon,
    this.suffixIcon,
    this.leftIcon,
    this.rightIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    String? error,
    String? errorText,
    this.helperText,
    this.focusNode,
    this.margin,
  }) : isPassword = true,
       errorText = error ?? errorText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isInternalFocusNode = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.onBlur != null) {
      widget.onBlur!();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textLabelColor = isDark ? AppColors.darkTextLabel : AppColors.lightTextLabel;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;
    final effectiveHint = widget.placeholder ?? widget.hint;
    final effectiveLeft = widget.leftIcon ?? widget.prefixIcon;
    final effectiveRight = widget.rightIcon ?? widget.suffixIcon;

    final currentLen = widget.controller?.text.length ?? 0;

    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: widget.label!,
                    style: TextStyle(
                      color: textLabelColor,
                      fontSize: AppTypography.sm,
                      fontWeight: AppTypography.medium,
                    ),
                    children: [
                      if (widget.isRequired)
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: errorColor,
                            fontSize: AppTypography.sm,
                            fontWeight: AppTypography.medium,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.showCounter && widget.maxLength != null)
                Text(
                  '$currentLen/${widget.maxLength}',
                  style: TextStyle(
                    color: currentLen >= widget.maxLength! ? errorColor : textSecColor,
                    fontSize: AppTypography.xs,
                    fontWeight: AppTypography.medium,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: [
            if (widget.maxLength != null)
              LengthLimitingTextInputFormatter(widget.maxLength),
            ...?widget.inputFormatters,
          ],
          validator: widget.validator,
          onChanged: (val) {
            if (widget.showCounter) setState(() {});
            widget.onChanged?.call(val);
          },
          onFieldSubmitted: widget.onSubmitted,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.showCounter ? widget.maxLength : null,
          buildCounter: widget.showCounter ? (context, {required currentLength, required isFocused, maxLength}) => null : null,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          style: TextStyle(
            color: textPrimaryColor,
            fontSize: AppTypography.base,
          ),
          decoration: InputDecoration(
            hintText: effectiveHint,
            errorText: null,
            border: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    borderSide: BorderSide(color: errorColor, width: 1.0),
                  )
                : null,
            enabledBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    borderSide: BorderSide(color: errorColor, width: 1.0),
                  )
                : null,
            focusedBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    borderSide: BorderSide(color: errorColor, width: 1.5),
                  )
                : null,
            prefixIcon: effectiveLeft != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: effectiveLeft,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : effectiveRight,
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              widget.errorText!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: errorColor,
                fontSize: AppTypography.xs,
                fontWeight: AppTypography.medium,
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
                color: textSecColor,
                fontSize: AppTypography.xs,
              ),
            ),
          ),
      ],
    );

    if (widget.margin != null) {
      return Padding(
        padding: widget.margin!,
        child: content,
      );
    }
    return content;
  }
}

