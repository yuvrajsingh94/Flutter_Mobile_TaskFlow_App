import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;

  const OtpInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
  });

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get currentCode => _controllers.map((c) => c.text).join();

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
    widget.onChanged?.call('');
  }

  void setValue(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    for (int i = 0; i < widget.length; i++) {
      if (i < digits.length) {
        _controllers[i].text = digits[i];
      } else {
        _controllers[i].clear();
      }
    }
    final focusIndex = digits.length >= widget.length ? widget.length - 1 : digits.length;
    if (_focusNodes.isNotEmpty && focusIndex < _focusNodes.length) {
      _focusNodes[focusIndex].requestFocus();
    }
    final code = currentCode;
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      // Pasted full code
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < widget.length; i++) {
        if (i < digits.length) {
          _controllers[i].text = digits[i];
        }
      }
      final focusIndex = digits.length >= widget.length ? widget.length - 1 : digits.length;
      _focusNodes[focusIndex].requestFocus();
      final code = currentCode;
      widget.onChanged?.call(code);
      if (code.length == widget.length) {
        widget.onCompleted?.call(code);
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    final code = currentCode;
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final fillCol = isDark ? AppColors.darkBgInput : AppColors.surfaceStone;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.borderHairline;
    final activeCol = isDark ? AppColors.darkAccentPrimary : AppColors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        final hasValue = _controllers[index].text.isNotEmpty;

        return SizedBox(
          width: 46,
          height: 52,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  _controllers[index].text.isEmpty &&
                  index > 0) {
                _controllers[index - 1].clear();
                _focusNodes[index - 1].requestFocus();
                widget.onChanged?.call(currentCode);
              }
            },
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textCol,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: fillCol,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderCol),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: hasValue ? activeCol : borderCol,
                    width: hasValue ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: activeCol,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (val) => _onChanged(val, index),
            ),
          ),
        );
      }),
    );
  }
}
