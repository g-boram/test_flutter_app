import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FVideoPlayerDialog extends StatefulWidget {
  final String path; // 로컬 파일 경로
  const FVideoPlayerDialog({super.key, required this.path});

  @override
  State<FVideoPlayerDialog> createState() => _FVideoPlayerDialogState();
}

class _FVideoPlayerDialogState extends State<FVideoPlayerDialog> {
  late final VideoPlayerController _ctrl;
  bool _ready = false;
  Duration _pos = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.file(File(widget.path))
      ..addListener(() {
        if (!mounted) return;
        setState(() => _pos = _ctrl.value.position);
      })
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _ctrl.play();
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = _ctrl.value.duration;
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: _ready ? _ctrl.value.aspectRatio : 16 / 9,
            child: _ready
                ? VideoPlayer(_ctrl)
                : const Center(child: CircularProgressIndicator()),
          ),
          // 상단 닫기
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // 하단 컨트롤
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: _pos.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble()),
                  max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                  onChanged: (v) => _ctrl.seekTo(Duration(milliseconds: v.toInt())),
                ),
                Row(
                  children: [
                    IconButton(
                      color: Colors.white,
                      icon: Icon(_ctrl.value.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        if (_ctrl.value.isPlaying) {
                          _ctrl.pause();
                        } else {
                          _ctrl.play();
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_fmt(_pos)} / ${_fmt(duration)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.replay_10),
                      onPressed: () => _ctrl.seekTo(_ctrl.value.position - const Duration(seconds: 10)),
                    ),
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.forward_10),
                      onPressed: () => _ctrl.seekTo(_ctrl.value.position + const Duration(seconds: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
