// lib/features/auth/screens/verification/widgets/pin_code_input.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bansigo_customer/core/theme/app_colors.dart';
import 'package:bansigo_customer/core/theme/app_text_styles.dart';

class PinCodeInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const PinCodeInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<PinCodeInput> createState() => _PinCodeInputState();
}

class _PinCodeInputState extends State<PinCodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getCode() {
    return _controllers.map((c) => c.text).join();
  }

  void _onFieldChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (value.length > 1) {
        // Handled pasted code
        final clean = value.replaceAll(RegExp(r'\D'), '');
        for (int i = 0; i < widget.length && i < clean.length; i++) {
          _controllers[i].text = clean[i];
        }
        _focusNodes[widget.length - 1].requestFocus();
      } else if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    }

    final code = _getCode();
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 48,
          height: 54,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  _controllers[index].text.isEmpty &&
                  index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: AppTextStyles.h2.copyWith(
                fontSize: 20,
                color: AppColors.slateDark,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.inputBg,
                contentPadding: EdgeInsets.zero,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (val) => _onFieldChanged(index, val),
            ),
          ),
        );
      }),
    );
  }
}
