import 'dart:io';
import 'package:flutter/material.dart';

/// 가로 스크롤 한 줄 썸네일 스트립
/// - [paths]: 보여줄 파일 경로 목록 (실제 파일 경로)
/// - [onTap]: 썸네일 탭 시 (예: 보기 다이얼로그)
/// - [onDelete]: 우상단 X 버튼 탭 시 단일 삭제
/// - [itemSize]: 썸네일 한 칸의 정사각 크기
class FPhotoStrip extends StatelessWidget {
  final String title;
  final List<String> paths;
  final void Function(String path) onTap;
  final void Function(String path) onDelete;
  final double itemSize;

  const FPhotoStrip({
    super.key,
    required this.title,
    required this.paths,
    required this.onTap,
    required this.onDelete,
    this.itemSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: itemSize, // 한 줄 높이
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: paths.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final path = paths[i];
              return GestureDetector(
                onTap: () => onTap(path),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: itemSize,
                        height: itemSize,
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
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
        ),
      ],
    );
  }
}
