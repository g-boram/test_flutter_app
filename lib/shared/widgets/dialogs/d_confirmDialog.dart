import 'package:flutter/material.dart';
import 'package:test_app/shared/widgets/dialogs/d_baseDialog.dart';
import '../buttons/w_baseButton.dart';


Future<bool?> showConfirmDialog(
    BuildContext context, {
      String? title,
      String? message,
      String confirmText = '확인',
      String cancelText = '취소',
      bool destructive = false,
      bool barrierDismissible = true,
    }) {
  final cs = Theme.of(context).colorScheme;
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => BaseDialog(
      title: title,
      message: message,
      actions: [
        BaseButton(
          label: cancelText,
          variant: BaseBtnVariant.outlined,
          size: BaseBtnSize.sm,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        BaseButton(
          label: confirmText,
          variant: destructive ? BaseBtnVariant.filled : BaseBtnVariant.tonal,
          size: BaseBtnSize.sm,
          styleOverride: destructive
              ? ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(cs.error),
            foregroundColor: WidgetStatePropertyAll(cs.onError),
          )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}
