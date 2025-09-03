import 'package:flutter/material.dart';
import 'package:test_app/shared/widgets/dialogs/d_baseDialog.dart';
import '../buttons/w_baseButton.dart';


Future<void> showInfoDialog(
    BuildContext context, {
      String? title,
      String? message,
      String buttonText = '확인',
      bool barrierDismissible = true,
    }) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => BaseDialog(
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
    ),
  );
}
