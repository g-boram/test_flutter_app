import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/permissions/permission_service.dart';
import '../../../../core/media/media_saver_service.dart';
import '../../../../shared/widgets/buttons/w_primary_button.dart';
import '../../../../shared/widgets/w_gap.dart';
import '../widgets/w_audio_player.dart';

class MicTestScreen extends StatefulWidget {
  const MicTestScreen({super.key});

  @override
  State<MicTestScreen> createState() => _MicTestScreenState();
}

class _MicTestScreenState extends State<MicTestScreen> {
  final AudioRecorder _audio = AudioRecorder();
  bool _isRecording = false;
  String? _lastAudioPath;

  Future<void> _start() async {
    final hasPerm = await _audio.hasPermission();
    if (!hasPerm) {
      final ok = await PermissionService.ensureMic();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('마이크 권한이 필요합니다.')),
          );
        }
        return;
      }
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );

    await _audio.start(config, path: path);
    if (!mounted) return;
    setState(() => _isRecording = true);
  }

  Future<void> _stop() async {
    if (!_isRecording) return;
    final path = await _audio.stop();
    if (!mounted) return;
    String? savedPath = path;

    if (savedPath != null) {
      savedPath = await MediaSaverService.copyAudioToAppDocs(savedPath);
    }

    setState(() {
      _isRecording = false;
      _lastAudioPath = savedPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('마이크 테스트')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Expanded(
                child: WPrimaryButton(
                  label: '녹음 시작',
                  onPressed: _isRecording ? null : _start,
                ),
              ),
              const WGap.w(8),
              Expanded(
                child: WPrimaryButton(
                  label: '녹음 종료',
                  onPressed: _isRecording ? _stop : null,
                ),
              ),
            ]),
            if (_lastAudioPath != null) ...[
              const WGap.h(12),
              const Text('최근 오디오', style: TextStyle(fontWeight: FontWeight.bold)),
              WAudioPlayer(filePath: _lastAudioPath!),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }
}
