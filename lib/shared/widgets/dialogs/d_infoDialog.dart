import 'package:flutter/material.dart';

import 'd_baseDialog.dart';
import '../buttons/w_baseButton.dart';

class InfoDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final String buttonText;

  const InfoDialog({
    super.key,
    this.title,
    this.message,
    this.buttonText = '확인',
  });

  /// 권장 호출법: InfoDialog.show(context, ...)
  static Future<void> show(
      BuildContext context, {
        String? title,
        String? message,
        String buttonText = '확인',
        bool barrierDismissible = true,
      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => InfoDialog(
        title: title,
        message: message,
        buttonText: buttonText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: title,
      message: message,
      actions: [
        BaseButton(
          label: buttonText,
          variant: BaseBtnVariant.filled,
          size: BaseBtnSize.sm,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
