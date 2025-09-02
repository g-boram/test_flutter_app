// lib/features/recoder/screen/s_mic_test.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:test_app/features/recoder/fragments/f_audio_player_sheet.dart';
import 'package:test_app/features/recoder/fragments/f_recording_indicator.dart';

import '../../../../core/permissions/permission_service.dart';
import '../../../../core/media/media_saver_service.dart';
import '../../../../shared/widgets/buttons/w_base_button.dart';
import '../../../../shared/widgets/primitives/w_gap.dart';

class MicTestScreen extends StatefulWidget {
  const MicTestScreen({super.key});

  @override
  State<MicTestScreen> createState() => _MicTestScreenState();
}

class _MicTestScreenState extends State<MicTestScreen> {
  // ⬇️ final → late로 변경 (사이클마다 재생성)
  late AudioRecorder _audio;

  bool _isRecording = false;
  String? _lastAudioPath;

  // 목록
  final List<String> _audioPaths = [];

  // 타이머/레벨
  Timer? _ticker;
  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  StreamSubscription<Amplitude>? _ampSub;
  double _level = 0.0; // 0.0 ~ 1.0

  @override
  void initState() {
    super.initState();
    _audio = AudioRecorder(); // ← 최초 생성
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'audio'));
    if (!dir.existsSync()) {
      setState(() => _audioPaths.clear());
      return;
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) {
      final ext = p.extension(f.path).toLowerCase();
      return ['.m4a', '.aac', '.mp3', '.wav'].contains(ext);
    })
        .toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    setState(() {
      _audioPaths
        ..clear()
        ..addAll(files.map((f) => f.path));
    });
  }

  // ========= Recorder lifecycle helpers =========
  Future<void> _resetRecorder() async {
    // 안전하게 정리 후 새 인스턴스
    try {
      if (await _audio.isRecording()) {
        await _audio.stop();
      }
    } catch (_) {}
    try {
      await _audio.dispose();
    } catch (_) {}
    _audio = AudioRecorder(); // 새로 생성
  }

  void _startTickers() {
    _startedAt = DateTime.now();
    _elapsed = Duration.zero;
    _level = 0.0;

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _startedAt == null) return;
      setState(() => _elapsed = DateTime.now().difference(_startedAt!));
    });

    _ampSub?.cancel();
    _ampSub = _audio
        .onAmplitudeChanged(const Duration(milliseconds: 200))
        .listen((amp) {
      // amp.current ≈ dB (-45 ~ 0). 0~1 스케일로 정규화
      final norm = ((amp.current + 45.0) / 45.0).clamp(0.0, 1.0);
      if (mounted) setState(() => _level = norm);
    });
  }

  Future<void> _stopTickers() async {
    _ticker?.cancel();
    _ticker = null;
    _startedAt = null;
    await _ampSub?.cancel();
    _ampSub = null;
    _level = 0.0;
  }

  // ---------------- Record ----------------
  Future<void> _start() async {
    // 혹시 잔여 상태 있으면 정리
    if (await _audio.isRecording()) {
      await _audio.stop();
      await _resetRecorder();
    }

    final hasPerm = await _audio.hasPermission();
    if (!hasPerm) {
      final ok = await PermissionService.ensureMic();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('마이크 권한이 필요합니다.')));
        }
        return;
      }
    }

    final tmp = await getTemporaryDirectory();
    final path = p.join(tmp.path, 'rec_${DateTime.now().millisecondsSinceEpoch}.m4a');

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );

    try {
      await _audio.start(config, path: path);
    } catch (_) {
      // 내부 상태 꼬임 방지: 재생성 후 1회 재시도
      await _resetRecorder();
      await _audio.start(config, path: path);
    }

    _startTickers();

    if (!mounted) return;
    setState(() => _isRecording = true);
  }

  Future<void> _stop() async {
    if (!_isRecording) return;

    String? path;
    try {
      path = await _audio.stop();
    } catch (_) {
      // 이미 멈춰있거나 에러 시 무시
    }

    await _stopTickers();

    // 다음 녹음을 위해 즉시 재생성
    await _resetRecorder();

    if (!mounted) return;
    String? savedPath = path;
    if (savedPath != null) {
      savedPath = await MediaSaverService.copyAudioToAppDocs(savedPath);
    }

    setState(() {
      _isRecording = false;
      _lastAudioPath = savedPath;
      if (savedPath != null) {
        _audioPaths.insert(0, savedPath);
      }
    });
  }

  // ---------------- UI helpers ----------------
  void _openPlayer(String filePath) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FAudioPlayerSheet(filePath: filePath),
    );
  }

  void _deleteRecording(String filePath) {
    try {
      final f = File(filePath);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
    setState(() {
      _audioPaths.remove(filePath);
      if (_lastAudioPath == filePath) _lastAudioPath = null;
    });
  }

  String _fmtBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int idx = 0;
    while (size >= 1024 && idx < units.length - 1) {
      size /= 1024;
      idx++;
    }
    return '${size.toStringAsFixed(1)} ${units[idx]}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('마이크 테스트'),
          actions: [
            IconButton(
              tooltip: '새로고침',
              onPressed: _loadRecordings,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- 녹음 컨트롤
            Row(children: [
              Expanded(
                child: BaseButton(
                  label: '녹음 시작',
                  onPressed: _isRecording ? null : _start,
                ),
              ),
              const WGap.w(8),
              Expanded(
                child: BaseButton(
                  label: '녹음 종료',
                  onPressed: _isRecording ? _stop : null,
                ),
              ),
            ]),

            // --- 진행중 UI (타이머/레벨)
            if (_isRecording) ...[
              const WGap.h(16),
              FRecordingIndicator(
                elapsed: _elapsed,
                level: _level,
              ),
            ],

            // --- 최근 항목
            if (_lastAudioPath != null) ...[
              const WGap.h(16),
              Text('최근 녹음', style: Theme.of(context).textTheme.titleMedium),
              const WGap.h(8),
              ListTile(
                leading: const Icon(Icons.audiotrack),
                title: Text(
                  p.basename(_lastAudioPath!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _openPlayer(_lastAudioPath!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteRecording(_lastAudioPath!),
                ),
              ),
            ],

            // --- 저장된 목록
            if (_audioPaths.isNotEmpty) ...[
              const WGap.h(20),
              Text(
                '저장된 녹음 (${_audioPaths.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const WGap.h(8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _audioPaths.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final path = _audioPaths[i];
                  final name = p.basename(path);
                  int? bytes;
                  try {
                    final f = File(path);
                    if (f.existsSync()) bytes = f.lengthSync();
                  } catch (_) {}
                  return ListTile(
                    leading: const Icon(Icons.audiotrack),
                    title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: bytes != null ? Text(_fmtBytes(bytes)) : null,
                    onTap: () => _openPlayer(path),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteRecording(path),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ampSub?.cancel();
    _audio.dispose();
    super.dispose();
  }
}
