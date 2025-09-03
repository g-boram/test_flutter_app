import 'package:flutter/material.dart';

class BaseDialog extends StatelessWidget {
  final Widget? icon;
  final String? title;
  final Widget? titleWidget;   // 커스텀 타이틀 사용 시
  final String? message;
  final Widget? content;       // 커스텀 본문 (폼/리스트 등)
  final List<Widget> actions;  // 아무 위젯이나 가능(TextButton, BaseButton 등)

  final EdgeInsets insetPadding;
  final EdgeInsets contentPadding;
  final double radius;

  const BaseDialog({
    super.key,
    this.icon,
    this.title,
    this.titleWidget,
    this.message,
    this.content,
    this.actions = const [],
    this.insetPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.contentPadding = const EdgeInsets.fromLTRB(24, 16, 24, 12),
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final body = content ??
        (message != null
            ? Text(message!, style: Theme.of(context).textTheme.bodyLarge)
            : const SizedBox.shrink());

    final titleNode = titleWidget ??
        (title != null
            ? Text(title!, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))
            : null);

    return Dialog(
      insetPadding: insetPadding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Padding(
        padding: contentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(height: 12)],
            if (titleNode != null) ...[titleNode, const SizedBox(height: 8)],
            Flexible(child: body),
            const SizedBox(height: 16),
            Row(
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  Expanded(child: actions[i]),
                  if (i != actions.length - 1) const SizedBox(width: 12),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
