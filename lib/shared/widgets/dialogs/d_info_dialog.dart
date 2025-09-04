import 'package:flutter/material.dart';

import 'd_base_dialog.dart';          // BaseDialog: titleIsKey / messageIsKey 지원 버전
import '../buttons/w_base_button.dart'; // BaseButton: labelIsKey 지원 버전

class InfoDialog extends StatelessWidget {
  final String? title;         // 기본: i18n 키
  final String? message;       // 기본: i18n 키

  final bool titleIsKey;
  final bool messageIsKey;

  /// 버튼 라벨(기본 키값)
  final String buttonText;
  final bool buttonIsKey;

  const InfoDialog({
    super.key,
    this.title,
    this.message,
    this.titleIsKey = true,
    this.messageIsKey = true,
    this.buttonText = 'common.ok', // 기본 키값
    this.buttonIsKey = true,
  });

  /// 권장 호출법
  static Future<void> show(
      BuildContext context, {
        String? title,
        String? message,
        bool titleIsKey = true,
        bool messageIsKey = true,
        String buttonText = 'common.ok',
        bool buttonIsKey = true,
        bool barrierDismissible = true,
      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => InfoDialog(
        title: title,
        message: message,
        titleIsKey: titleIsKey,
        messageIsKey: messageIsKey,
        buttonText: buttonText,
        buttonIsKey: buttonIsKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: title,
      titleIsKey: titleIsKey,
      message: message,
      messageIsKey: messageIsKey,
      actions: [
        BaseButton(
          label: buttonText,
          labelIsKey: buttonIsKey,
          variant: BaseBtnVariant.filled,
          size: BaseBtnSize.sm,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
