import 'dart:io';
import 'package:flutter/material.dart';

class FPhotoGrid extends StatelessWidget {
  final String title;
  final List<String> paths;
  final void Function(String path) onTap;       // 썸네일 탭 → 보기(다이얼로그)
  final void Function(String path) onDelete;    // X 아이콘 → 단일 삭제

  const FPhotoGrid({
    super.key,
    required this.title,
    required this.paths,
    required this.onTap,
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paths.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (_, i) {
            final path = paths[i];
            return GestureDetector(
              onTap: () => onTap(path),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      // 파일이 없거나 디코딩 실패 시 안전 표시
                      errorBuilder: (context, error, stack) => Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),

                  // 우상단 삭제 버튼
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Material(
                      color: Colors.black45,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => onDelete(path),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
