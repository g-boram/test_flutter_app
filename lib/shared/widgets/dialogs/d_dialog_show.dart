import 'package:flutter/material.dart';
import 'd_dialog.dart';

/// 공통 다이얼로그 호출(중앙/상단 위치 + 전환 애니메이션)
Future<T?> showAppDialog<T>(
    BuildContext context, {
      required AppDialogParams params,
      bool useRootNavigator = true,
    }) {
  final alignment = params.position == DialogPosition.top
      ? Alignment.topCenter
      : Alignment.center;

  final beginOffset = params.position == DialogPosition.top
      ? const Offset(0, -0.05)
      : const Offset(0, 0.05);

  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: params.barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (ctx, _, __) {
      final card = AppDialogCard(params: params);

      final positioned = params.position == DialogPosition.top
          ? Padding(
        padding: EdgeInsets.only(top: params.topOffset),
        child: Align(alignment: alignment, child: card),
      )
          : Align(alignment: alignment, child: card);

      return SafeArea(
        child: Material(
          type: MaterialType.transparency,
          child: positioned,
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// 자주 쓰는 프리셋들 ───────────────────────────────────────────

Future<void> showInfoDialog(
    BuildContext context, {
      required String title,
      required String message,
      DialogPosition position = DialogPosition.center,
      String okText = 'OK',
      Widget? leading,
    }) {
  return showAppDialog<void>(
    context,
    params: AppDialogParams(
      title: title,
      message: message,
      leading: leading ??
          const Icon(Icons.info_outline_rounded, size: 28),
      okText: okText,
      showCancel: false,
      position: position,
    ),
  );
}

Future<bool> showConfirmDialog(
    BuildContext context, {
      required String title,
      required String message,
      String okText = 'OK',
      String cancelText = 'Cancel',
      bool destructive = false,
      DialogPosition position = DialogPosition.center, required String confirmText,
    }) async {
  final result = await showAppDialog<bool>(
    context,
    params: AppDialogParams(
      title: title,
      message: message,
      okText: okText,
      cancelText: cancelText,
      destructive: destructive,
      position: position,
    ),
  );
  return result == true;
}

Future<String?> showInputDialog(
    BuildContext context, {
      required String title,
      String? message,
      String okText = 'OK',
      String cancelText = 'Cancel',
      String initial = '',
      String hintText = '',
      DialogPosition position = DialogPosition.center,
    }) {
  final controller = TextEditingController(text: initial);

  return showAppDialog<String>(
    context,
    params: AppDialogParams(
      title: title,
      message: message,
      position: position,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(null),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).maybePop(controller.text),
          child: Text(okText),
        ),
      ],
    ),
  ).then((value) => value).whenComplete(controller.dispose).then((_) => null);
}
