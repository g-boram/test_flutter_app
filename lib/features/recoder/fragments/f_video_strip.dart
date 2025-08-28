import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// 가로 스크롤 동영상 썸네일 스트립
/// - paths: 로컬 동영상 파일 경로 목록
/// - onTap: 썸네일 탭 시 (재생 다이얼로그 등)
/// - onDelete: 우상단 X 버튼 탭 시 단일 삭제
class FVideoStrip extends StatelessWidget {
  final String title;
  final List<String> paths;
  final void Function(String path) onTap;
  final void Function(String path) onDelete;
  final double itemSize;

  const FVideoStrip({
    super.key,
    required this.title,
    required this.paths,
    required this.onTap,
    required this.onDelete,
    this.itemSize = 110,
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
          height: itemSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: paths.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final path = paths[i];
              return _VideoThumbTile(
                path: path,
                size: itemSize,
                onTap: () => onTap(path),
                onDelete: () => onDelete(path),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VideoThumbTile extends StatefulWidget {
  final String path;
  final double size;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _VideoThumbTile({
    required this.path,
    required this.size,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_VideoThumbTile> createState() => _VideoThumbTileState();
}

class _VideoThumbTileState extends State<_VideoThumbTile> {
  String? _thumbPath;

  @override
  void initState() {
    super.initState();
    _genThumb();
  }

  Future<void> _genThumb() async {
    try {
      final cache = await getTemporaryDirectory();
      final name = 'thumb_${p.basename(widget.path)}.jpg';
      final out = await VideoThumbnail.thumbnailFile(
        video: widget.path,
        thumbnailPath: cache.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: widget.size.toInt(), // 높이에 맞게
        quality: 75,
      );
      if (!mounted) return;
      setState(() => _thumbPath = out);
    } catch (_) {
      if (!mounted) return;
      setState(() => _thumbPath = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: _thumbPath == null
                  ? Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Icon(Icons.movie_outlined),
              )
                  : Image.file(
                File(_thumbPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.movie_outlined),
                ),
              ),
            ),
          ),
          // 재생 아이콘
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
              ),
            ),
          ),
          // 우상단 삭제
          Positioned(
            right: 4,
            top: 4,
            child: Material(
              color: Colors.black45,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.onDelete,
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
  }
}
