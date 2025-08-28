// lib/features/recoder/presentation/fragments/f_selection_bar.dart
import 'package:flutter/material.dart';

class FSelectionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onSelectAll;
  final VoidCallback onCancel;

  const FSelectionBar({
    super.key,
    required this.selectedCount,
    required this.onDelete,
    required this.onSelectAll,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text('선택됨: $selectedCount'),
              const Spacer(),
              IconButton(
                tooltip: '모두 선택',
                onPressed: onSelectAll,
                icon: const Icon(Icons.select_all),
              ),
              IconButton(
                tooltip: '삭제',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
              IconButton(
                tooltip: '취소',
                onPressed: onCancel,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
