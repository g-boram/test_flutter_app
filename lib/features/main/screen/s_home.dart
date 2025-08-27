import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:test_app/features/recoder/presentation/screen/s_recorder.dart';
import 'package:test_app/features/recoder/presentation/widgets/w_audio_player.dart';

import '../../../../core/permissions/permission_service.dart';
import '../../../../shared/widgets/buttons/w_primary_button.dart';
import '../../../../shared/widgets/w_gap.dart';
import '../../../../shared/widgets/w_camera_box.dart';

class SHome extends StatefulWidget {
  const SHome({super.key});

  @override
  State<SHome> createState() => _SHomeState();
}

class _SHomeState extends State<SHome> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Expanded(
            child: WPrimaryButton(
              label: '카메라 테스트',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _QuickCameraSheet(),
              ),
            ),
          ),
          const WGap.w(8),
          Expanded(
            child: WPrimaryButton(
              label: '마이크 테스트',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _QuickMicSheet(),
              ),
            ),
          ),
        ]),
        const WGap.h(12),
        WPrimaryButton(
          label: '녹화/녹음 화면으로 이동',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SRecorder()),
          ),
        ),
      ],
    );
  }
}

class _QuickCameraSheet extends StatefulWidget {
  const _QuickCameraSheet();

  @override
  State<_QuickCameraSheet> createState() => _QuickCameraSheetState();
}

class _QuickCameraSheetState extends State<_QuickCameraSheet> {
  CameraController? _cam;
  List<CameraDescription> _cams = [];
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final ok = await PermissionService.ensureCamera();
    if (!ok) {
      if (mounted) Navigator.pop(context);
      return;
    }
    _cams = await availableCameras();
    if (_cams.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }
    _cam = CameraController(_cams[_idx], ResolutionPreset.medium, enableAudio: false);
    await _cam!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _switch() async {
    if (_cams.length < 2) return;
    _idx = (_idx + 1) % _cams.length;
    await _cam?.dispose();
    _cam = CameraController(_cams[_idx], ResolutionPreset.medium, enableAudio: false);
    await _cam!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('카메라 미리보기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_cam == null || !_cam!.value.isInitialized)
              const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
            else
              WCameraBox(controller: _cam!, maxHeight: 320),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                ),
                const SizedBox(width: 8),
                if (_cams.length > 1)
                  Expanded(
                    child: FilledButton(
                      onPressed: _switch,
                      child: const Text('전/후면 전환'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickMicSheet extends StatefulWidget {
  const _QuickMicSheet();

  @override
  State<_QuickMicSheet> createState() => _QuickMicSheetState();
}

class _QuickMicSheetState extends State<_QuickMicSheet> {
  final AudioRecorder _rec = AudioRecorder();
  bool _isRec = false;
  String? _lastPath;

  Future<void> _start() async {
    final ok = await _rec.hasPermission() || await PermissionService.ensureMic();
    if (!ok) return;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/mic_${DateTime.now().millisecondsSinceEpoch}.m4a';
    const cfg = RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100);
    await _rec.start(cfg, path: path);
    if (mounted) setState(() => _isRec = true);
  }

  Future<void> _stop() async {
    final p = await _rec.stop();
    if (!mounted) return;
    setState(() {
      _isRec = false;
      _lastPath = p;
    });
  }

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('마이크 테스트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FilledButton(onPressed: _isRec ? null : _start, child: const Text('녹음 시작'))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton(onPressed: _isRec ? _stop : null, child: const Text('녹음 종료'))),
          ]),
          if (_lastPath != null) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: Text('최근 녹음', style: Theme.of(context).textTheme.titleMedium)),
            WAudioPlayer(filePath: _lastPath!),
          ],
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
        ]),
      ),
    );
  }
}
