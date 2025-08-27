import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WVideoPreview extends StatefulWidget {
  final String filePath;
  const WVideoPreview({super.key, required this.filePath});

  @override
  State<WVideoPreview> createState() => _WVideoPreviewState();
}

class _WVideoPreviewState extends State<WVideoPreview> {
  VideoPlayerController? _vp;

  @override
  void initState() {
    super.initState();
    _vp = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _vp?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_vp == null || !_vp!.value.isInitialized) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(aspectRatio: _vp!.value.aspectRatio, child: VideoPlayer(_vp!)),
        Row(children: [
          IconButton(icon: const Icon(Icons.play_arrow), onPressed: _vp!.play),
          IconButton(icon: const Icon(Icons.pause), onPressed: _vp!.pause),
          IconButton(icon: const Icon(Icons.stop), onPressed: () async { await _vp!.pause(); await _vp!.seekTo(Duration.zero); }),
        ]),
        Text(widget.filePath, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
