import 'package:flutter/material.dart';
import 'package:test_app/features/recoder/presentation/widgets/w_video_preview.dart';

class FVideoList extends StatelessWidget {
  final String title;
  final List<String> paths;
  final void Function(String path) onDelete; // ✅ 단일 삭제 콜백

  const FVideoList({
    super.key,
    required this.title,
    required this.paths,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Column(
          children: paths.map((p) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: WVideoPreview(filePath: p)),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: '삭제',
                      onPressed: () => onDelete(p),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
