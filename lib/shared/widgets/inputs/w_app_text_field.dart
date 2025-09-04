import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// 간단 재사용 TextField
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;                  // 1 = 싱글라인, 2이상 = 멀티라인(Enter=줄바꿈)
  final String? hintText;
  final bool hintIsKey;

  final String? errorText;             // 표기할 에러문구 (null이면 미표시)
  final bool errorIsKey;

  final TextInputType? keyboardType;   // 미지정 시 maxLines에 맞춰 자동
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.controller,
    this.maxLines = 1,
    this.hintText,
    this.hintIsKey = true,
    this.errorText,
    this.errorIsKey = true,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.onChanged,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMultiline = maxLines > 1;

    final resolvedHint = hintText == null
        ? null
        : (hintIsKey ? hintText!.tr() : hintText!);

    final resolvedError = errorText == null
        ? null
        : (errorIsKey ? errorText!.tr() : errorText!);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType ?? (isMultiline ? TextInputType.multiline : TextInputType.text),
      textInputAction: isMultiline ? TextInputAction.newline : TextInputAction.done,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      autofocus: autofocus,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: resolvedHint,
        errorText: resolvedError,
        filled: true,
        fillColor: cs.surfaceVariant.withOpacity(Theme.of(context).brightness == Brightness.dark ? .20 : .35),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
      ),
      // 싱글라인일 때만 Enter로 완료
      onSubmitted: isMultiline ? null : (v) => FocusScope.of(context).unfocus(),
    );
  }
}
