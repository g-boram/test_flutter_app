import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class WAudioPlayer extends StatefulWidget {
  final String filePath;
  const WAudioPlayer({super.key, required this.filePath});

  @override
  State<WAudioPlayer> createState() => _WAudioPlayerState();
}

class _WAudioPlayerState extends State<WAudioPlayer> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _player.setFilePath(widget.filePath);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        IconButton(icon: const Icon(Icons.play_arrow), onPressed: _player.play),
        IconButton(icon: const Icon(Icons.pause), onPressed: _player.pause),
        IconButton(icon: const Icon(Icons.stop), onPressed: _player.stop),
      ]),
      Text(widget.filePath, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
  }
}
