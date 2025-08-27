import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/permissions/permission_service.dart';
import '../../../../core/media/media_saver_service.dart';
import '../../../../shared/widgets/buttons/w_primary_button.dart';
import '../../../../shared/widgets/w_gap.dart';
import '../../../../shared/widgets/w_camera_box.dart';
import '../widgets/w_video_preview.dart';
import '../widgets/w_audio_player.dart';

class SRecorder extends StatefulWidget {
  const SRecorder({super.key});
  @override
  State<SRecorder> createState() => _SRecorderState();
}

class _SRecorderState extends State<SRecorder> with WidgetsBindingObserver {
  // Audio (record 5.x)
  final AudioRecorder _audio = AudioRecorder();
  bool _isAudioRecording = false;
  String? _lastAudioPath;

  // Camera/Video
  CameraController? _cam;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _isVideoRecording = false;
  String? _lastVideoPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final ok = await PermissionService.ensureCameraAndMic();
    if (!ok) return;

    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용 가능한 카메라가 없습니다.')),
        );
      }
      return;
    }

    _cam = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.medium, // 높이 부담 줄이기
      enableAudio: true,
    );
    await _cam!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _cam?.dispose();
    _cam = null;
    if (mounted) setState(() {});
    await _initCamera();
  }

  // ---------- Video ----------
  Future<void> _startVideo() async {
    if (_cam == null) return;
    if (!_cam!.value.isInitialized) return;
    if (_isVideoRecording || _cam!.value.isRecordingVideo) return;

    await _cam!.prepareForVideoRecording();
    await _cam!.startVideoRecording();
    if (!mounted) return;
    setState(() => _isVideoRecording = true);
  }

  Future<void> _stopVideo() async {
    if (_cam == null) return;
    if (!_isVideoRecording || !_cam!.value.isRecordingVideo) return;

    final file = await _cam!.stopVideoRecording();
    if (!mounted) return;
    setState(() {
      _isVideoRecording = false;
      _lastVideoPath = file.path;
    });

    await MediaSaverService.saveVideoToGallery(_lastVideoPath!);
    if (mounted) setState(() {});
  }

  // ---------- Audio ----------
  Future<void> _startAudio() async {
    if (_isAudioRecording) return;

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
    setState(() => _isAudioRecording = true);
  }

  Future<void> _stopAudio() async {
    if (!_isAudioRecording) return;
    final path = await _audio.stop();
    if (!mounted) return;
    setState(() {
      _isAudioRecording = false;
      _lastAudioPath = path;
    });

    if (_lastAudioPath != null) {
      _lastAudioPath = await MediaSaverService.copyAudioToAppDocs(_lastAudioPath!);
      if (mounted) setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_cam == null) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      await _cam?.dispose();
      _cam = null;
    } else if (state == AppLifecycleState.resumed) {
      await _initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final camReady = _cam?.value.isInitialized == true;
    return SafeArea( // ✅ 오버플로 방지
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recorder'),
          actions: [
            if (_cameras.length > 1)
              IconButton(
                icon: const Icon(Icons.cameraswitch),
                onPressed: _switchCamera,
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            camReady
                ? WCameraBox(controller: _cam!, maxHeight: 360) // ✅ 높이 제한
                : const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator())),
            const WGap.h(12),
            Row(children: [
              Expanded(
                child: WPrimaryButton(
                  label: '영상 시작',
                  onPressed: _isVideoRecording ? null : _startVideo,
                ),
              ),
              const WGap.w(8),
              Expanded(
                child: WPrimaryButton(
                  label: '영상 종료',
                  onPressed: _isVideoRecording ? _stopVideo : null,
                ),
              ),
            ]),
            if (_lastVideoPath != null) ...[
              const WGap.h(12),
              const Text('최근 영상', style: TextStyle(fontWeight: FontWeight.bold)),
              WVideoPreview(filePath: _lastVideoPath!),
            ],
            const Divider(height: 32),
            Row(children: [
              Expanded(
                child: WPrimaryButton(
                  label: '녹음 시작',
                  onPressed: _isAudioRecording ? null : _startAudio,
                ),
              ),
              const WGap.w(8),
              Expanded(
                child: WPrimaryButton(
                  label: '녹음 종료',
                  onPressed: _isAudioRecording ? _stopAudio : null,
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
    WidgetsBinding.instance.removeObserver(this);
    _cam?.dispose();
    _audio.dispose();
    super.dispose();
  }
}
