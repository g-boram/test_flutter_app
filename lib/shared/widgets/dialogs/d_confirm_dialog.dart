// lib/shared/widgets/dialogs/d_confirm_dialog.dart
import 'package:flutter/material.dart';
import '../buttons/w_base_button.dart'; // BaseButton: labelIsKey 지원
import 'd_base_dialog.dart';           // BaseDialog: titleIsKey / messageIsKey 지원

class ConfirmDialog extends StatelessWidget {
  final String? title;
  final String? message;

  // i18n 토글 (기본 true: 키로 번역)
  final bool titleIsKey;
  final bool messageIsKey;

  // 버튼 라벨과 i18n 토글(기본은 키)
  final String confirmText;
  final String cancelText;
  final bool confirmIsKey;
  final bool cancelIsKey;

  // 파괴적 액션(확인 버튼을 error 톤으로)
  final bool destructive;

  // (선택) 상단 아이콘
  final Widget? icon;

  const ConfirmDialog({
    super.key,
    this.title,
    this.message,
    this.titleIsKey = true,
    this.messageIsKey = true,
    this.confirmText = 'common.ok',      // 기본 키값
    this.cancelText  = 'common.cancel',  // 기본 키값
    this.confirmIsKey = true,
    this.cancelIsKey  = true,
    this.destructive = false,
    this.icon,
  });

  /// 일반 show (그대로 bool? 반환)
  static Future<bool?> show(
      BuildContext context, {
        String? title,
        String? message,
        bool titleIsKey = true,
        bool messageIsKey = true,
        String confirmText = 'common.ok',
        String cancelText  = 'common.cancel',
        bool confirmIsKey = true,
        bool cancelIsKey  = true,
        bool destructive = false,
        bool barrierDismissible = true,
        Widget? icon,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        titleIsKey: titleIsKey,
        messageIsKey: messageIsKey,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmIsKey: confirmIsKey,
        cancelIsKey: cancelIsKey,
        destructive: destructive,
        icon: icon,
      ),
    );
  }

  /// ✅ 기본 색상 확인 다이얼로그 (tonal) — null ⇒ false로 변환
  static Future<bool> confirm(
      BuildContext context, {
        String? title,
        String? message,
        bool titleIsKey = true,
        bool messageIsKey = true,
        String confirmText = 'common.ok',
        String cancelText  = 'common.cancel',
        bool confirmIsKey = true,
        bool cancelIsKey  = true,
        bool barrierDismissible = true,
        Widget? icon,
      }) async {
    final res = await show(
      context,
      title: title,
      message: message,
      titleIsKey: titleIsKey,
      messageIsKey: messageIsKey,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmIsKey: confirmIsKey,
      cancelIsKey: cancelIsKey,
      destructive: false, // ← 기본 색상
      barrierDismissible: barrierDismissible,
      icon: icon,
    );
    return res == true;
  }

  /// 🛑 삭제 전 확인 다이얼로그 (에러 색상 filled) — null ⇒ false로 변환
  static Future<bool> delete(
      BuildContext context, {
        String? title,
        String? message,
        bool titleIsKey = true,
        bool messageIsKey = true,
        String confirmText = 'common.delete', // 기본 키: 삭제
        String cancelText  = 'common.cancel',
        bool confirmIsKey = true,
        bool cancelIsKey  = true,
        bool barrierDismissible = true,
        Widget? icon,
      }) async {
    final res = await show(
      context,
      title: title,
      message: message,
      titleIsKey: titleIsKey,
      messageIsKey: messageIsKey,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmIsKey: confirmIsKey,
      cancelIsKey: cancelIsKey,
      destructive: true, // ← 에러 색상
      barrierDismissible: barrierDismissible,
      icon: icon ?? const Icon(Icons.warning_amber_rounded, size: 28),
    );
    return res == true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BaseDialog(
      icon: icon,
      title: title,
      titleIsKey: titleIsKey,
      message: message,
      messageIsKey: messageIsKey,
      actions: [
        // 취소
        BaseButton(
          label: cancelText,
          labelIsKey: cancelIsKey,
          variant: BaseBtnVariant.outlined,
          size: BaseBtnSize.sm,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        // 확인
        BaseButton(
          label: confirmText,
          labelIsKey: confirmIsKey,
          // destructive면 에러 톤 filled, 아니면 기본 tonal
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
}
