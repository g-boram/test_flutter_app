// lib/features/recoder/fragments/f_audio_player_sheet.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;

class FAudioPlayerSheet extends StatefulWidget {
  const FAudioPlayerSheet({super.key, required this.filePath});
  final String filePath;

  @override
  State<FAudioPlayerSheet> createState() => _FAudioPlayerSheetState();
}

class _FAudioPlayerSheetState extends State<FAudioPlayerSheet> {
  late final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _player.setFilePath(widget.filePath);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration? d) {
    if (d == null) return '--:--';
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
        EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              p.basename(widget.filePath),
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // 진행바 + 시간
            StreamBuilder<Duration?>(
              stream: _player.durationStream,
              builder: (context, durSnap) {
                return StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, posSnap) {
                    final total = durSnap.data ?? Duration.zero;
                    final pos = posSnap.data ?? Duration.zero;
                    final max = total.inMilliseconds.toDouble().clamp(0.0, double.infinity);
                    final value = pos.inMilliseconds.toDouble().clamp(0.0, max);

                    return Column(
                      children: [
                        Slider(
                          value: value,
                          min: 0,
                          max: max == 0 ? 1 : max,
                          onChanged: (v) {
                            _player.seek(Duration(milliseconds: v.toInt()));
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(pos), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
                            Text(_fmt(total), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 8),

            // 재생/일시정지 버튼
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snap) {
                final ps = snap.data;
                final playing = ps?.playing == true;
                final processing = ps?.processingState;

                final isEnded = processing == ProcessingState.completed;
                final isLoading = processing == ProcessingState.loading || processing == ProcessingState.buffering;

                return Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isLoading
                            ? null
                            : () async {
                          if (isEnded) {
                            await _player.seek(Duration.zero);
                            await _player.play();
                          } else {
                            playing ? await _player.pause() : await _player.play();
                          }
                        },
                        icon: Icon(
                          isEnded
                              ? Icons.replay
                              : (playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                        ),
                        label: Text(isEnded ? '다시재생' : (playing ? '일시정지' : '재생')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('닫기'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
