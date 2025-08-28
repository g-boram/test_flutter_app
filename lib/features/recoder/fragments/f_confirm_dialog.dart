// lib/features/recoder/presentation/fragments/f_confirm_dialog.dart
import 'package:flutter/material.dart';

class FConfirmDialog extends StatelessWidget {
  final String title;
  final String message;

  const FConfirmDialog({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
      ],
    );
  }
}
