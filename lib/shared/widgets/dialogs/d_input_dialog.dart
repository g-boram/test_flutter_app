import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'd_base_dialog.dart';                 // BaseDialog: titleIsKey / messageIsKey 지원
import '../buttons/w_base_button.dart';      // BaseButton: labelIsKey 지원
import '../inputs/w_app_text_field.dart';    // 재사용 인풋

/// 하나로 통합된 다이얼로그:
/// - maxLines == 0  → 입력 없이 텍스트 전용 (확인/취소)   → Future<bool?>
/// - maxLines >= 1  → 입력 다이얼로그 (한 줄/멀티라인)     → Future<String?>
class InputDialog extends StatefulWidget {
  // 타이틀/설명 (기본: i18n 키)
  final String? title;
  final String? message;
  final bool titleIsKey;
  final bool messageIsKey;

  // 입력 박스 설정 (maxLines==0이면 입력박스 없음)
  final int maxLines;                 // 0=입력없음, 1=싱글라인, 2+=멀티라인(Enter=줄바꿈)
  final String initial;
  final String? hintText;
  final bool hintIsKey;

  // 검증
  final bool required;                // true면 비어있을 때 에러 표기
  final String requiredErrorText;     // 기본 에러 문구(키)
  final bool requiredErrorIsKey;
  final String? Function(String value)? validator; // 추가 커스텀 검증(평문/키는 직접 처리)

  // 버튼 라벨 (기본: 키)
  final String confirmText;
  final String cancelText;
  final bool confirmIsKey;
  final bool cancelIsKey;

  // 아이콘
  final Widget? icon;

  const InputDialog({
    super.key,
    this.title,
    this.message,
    this.titleIsKey = true,
    this.messageIsKey = true,
    this.maxLines = 1,                       // 기본은 입력 1줄
    this.initial = '',
    this.hintText,
    this.hintIsKey = true,
    this.required = false,
    this.requiredErrorText = 'validation.required', // "필수 입력입니다" 같은 키
    this.requiredErrorIsKey = true,
    this.validator,
    this.confirmText = 'common.ok',
    this.cancelText  = 'common.cancel',
    this.confirmIsKey = true,
    this.cancelIsKey  = true,
    this.icon,
  });

  /// 입력 다이얼로그 (maxLines >= 1)
  static Future<String?> prompt(
      BuildContext context, {
        String? title,
        String? message,
        bool titleIsKey = true,
        bool messageIsKey = true,
        int maxLines = 1,
        String initial = '',
        String? hintText,
        bool hintIsKey = true,
        bool required = false,
        String requiredErrorText = 'validation.required',
        bool requiredErrorIsKey = true,
        String confirmText = 'common.save',
        String cancelText  = 'common.cancel',
        bool confirmIsKey = true,
        bool cancelIsKey  = true,
        String? Function(String value)? validator,
        Widget? icon,
        bool barrierDismissible = true,
      }) {
    assert(maxLines >= 1, 'prompt()는 maxLines >= 1 이어야 합니다.');
    return showDialog<String?>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => InputDialog(
        title: title,
        message: message,
        titleIsKey: titleIsKey,
        messageIsKey: messageIsKey,
        maxLines: maxLines,
        initial: initial,
        hintText: hintText,
        hintIsKey: hintIsKey,
        required: required,
        requiredErrorText: requiredErrorText,
        requiredErrorIsKey: requiredErrorIsKey,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmIsKey: confirmIsKey,
        cancelIsKey: cancelIsKey,
        validator: validator,
        icon: icon,
      ),
    );
  }

  /// 텍스트 전용 다이얼로그 (입력 없음, maxLines=0)
  static Future<bool?> info(
      BuildContext context, {
        String? title,
        String? message,
        bool titleIsKey = true,
        bool messageIsKey = true,
        String confirmText = 'common.ok',
        String cancelText  = 'common.cancel',
        bool confirmIsKey = true,
        bool cancelIsKey  = true,
        Widget? icon,
        bool barrierDismissible = true,
      }) {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => InputDialog(
        title: title,
        message: message,
        titleIsKey: titleIsKey,
        messageIsKey: messageIsKey,
        maxLines: 0, // 입력 없음
        confirmText: confirmText,
        cancelText: cancelText,
        confirmIsKey: confirmIsKey,
        cancelIsKey: cancelIsKey,
        icon: icon,
      ),
    );
  }

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late final TextEditingController _controller;
  String? _errorText; // 평문(이미 tr() 처리된 상태를 넣을 예정)

  bool get _isInput => widget.maxLines > 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _runValidate(String value) {
    // required 검사
    if (widget.required && value.trim().isEmpty) {
      return widget.requiredErrorIsKey ? widget.requiredErrorText.tr() : widget.requiredErrorText;
    }
    // 커스텀 검사
    if (widget.validator != null) {
      final raw = widget.validator!(value);
      // validator가 키를 반환하고 싶다면 직접 tr()해서 넘겨도 되고, 여기서 처리하고 싶다면 규칙 추가 가능
      return raw;
    }
    return null;
  }

  void _onConfirm() {
    if (!_isInput) {
      Navigator.of(context).maybePop(true);
      return;
    }
    final val = _controller.text;
    final err = _runValidate(val);
    if (err != null) {
      setState(() => _errorText = err);
      return;
    }
    Navigator.of(context).maybePop(val);
  }

  @override
  Widget build(BuildContext context) {
    // 본문(content) 구성
    final List<Widget> bodyChildren = [];

    if (widget.message != null) {
      final msg = widget.messageIsKey ? widget.message!.tr() : widget.message!;
      bodyChildren.add(Text(msg, style: Theme.of(context).textTheme.bodyLarge));
      if (_isInput) bodyChildren.add(const SizedBox(height: 12));
    }

    if (_isInput) {
      bodyChildren.add(
        AppTextField(
          controller: _controller,
          maxLines: widget.maxLines,
          hintText: widget.hintText,
          hintIsKey: widget.hintIsKey,
          errorText: _errorText,
          errorIsKey: false, // _errorText는 이미 평문 처리된 상태
          onChanged: (_) {
            if (_errorText != null) setState(() => _errorText = null);
          },
        ),
      );
    }

    return BaseDialog(
      icon: widget.icon,
      title: widget.title,
      titleIsKey: widget.titleIsKey,
      message: null, // 위에서 content로 처리
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: bodyChildren,
      ),
      actions: [
        BaseButton(
          label: widget.cancelText,
          labelIsKey: widget.cancelIsKey,
          variant: BaseBtnVariant.outlined,
          size: BaseBtnSize.sm,
          onPressed: () => Navigator.of(context).maybePop(_isInput ? null : false),
        ),
        BaseButton(
          label: widget.confirmText,
          labelIsKey: widget.confirmIsKey,
          variant: _isInput ? BaseBtnVariant.filled : BaseBtnVariant.tonal,
          size: BaseBtnSize.sm,
          onPressed: _onConfirm,
        ),
      ],
    );
  }
}
