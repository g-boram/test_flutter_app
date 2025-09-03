// lib/shared/widgets/dialogs/d_confirmDialog.dart
import 'package:flutter/material.dart';
import '../buttons/w_baseButton.dart';
import 'd_baseDialog.dart';

class ConfirmDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final String confirmText;
  final String cancelText;
  final bool destructive;

  const ConfirmDialog({
    super.key,
    this.title,
    this.message,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.destructive = false,
  });

  static Future<bool?> show(
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
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        destructive: destructive,
      )._build(cs, context),
    );
  }

  // 내부적으로 BaseDialog를 조합
  Widget _build(ColorScheme cs, BuildContext context) {
    return BaseDialog(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // 직접 위젯으로 트리에 넣고 싶을 때도 사용 가능
    final cs = Theme.of(context).colorScheme;
    return _build(cs, context);
  }
}
