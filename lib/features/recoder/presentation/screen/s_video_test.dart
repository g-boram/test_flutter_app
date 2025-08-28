import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:media_store_plus/media_store_plus.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:test_app/core/media/media_saver_service.dart';
import 'package:test_app/features/recoder/fragments/f_video_controls.dart';
import 'package:test_app/features/recoder/fragments/f_video_player_dialog.dart';
import 'package:test_app/features/recoder/fragments/f_video_strip.dart';

import '../../../../core/permissions/permission_service.dart';
import '../../../../shared/widgets/w_camera_box.dart';
import '../../../../shared/widgets/w_gap.dart';


class VideoTestScreen extends StatefulWidget {
  const VideoTestScreen({super.key});

  @override
  State<VideoTestScreen> createState() => _VideoTestScreenState();
}

class _VideoTestScreenState extends State<VideoTestScreen> with WidgetsBindingObserver {
  CameraController? _cam;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  bool _isRecording = false;
  final List<String> _videoPaths = [];
  static const int _maxVideos = 5;

  // --- Timer(선택) ---
  Duration _elapsed = Duration.zero;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Ticker((dt) {
      if (_isRecording) {
        setState(() => _elapsed += dt);
      }
    });
    _initCamera();
  }

  Future<void> _initCamera() async {
    final ok = await PermissionService.ensureCameraAndMic();
    if (!ok) return;

    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용 가능한 카메라가 없습니다.')),
      );
      return;
    }

    _cam = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
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

  // ---------- Video helpers ----------
  Future<String> _persistVideoForPreview(XFile x) async {
    final docs = await getApplicationDocumentsDirectory();
    final ext = x.name.contains('.') ? x.name.split('.').last : 'mp4';
    final dstPath = p.join(docs.path, 'video_${DateTime.now().millisecondsSinceEpoch}.$ext');
    try {
      await x.saveTo(dstPath);
    } catch (_) {
      final bytes = await x.readAsBytes();
      await File(dstPath).writeAsBytes(bytes);
    }
    return dstPath;
  }

  Future<String> _duplicateForGallery(String srcPath) async {
    final cache = await getTemporaryDirectory();
    final name = 'gal_${p.basename(srcPath)}';
    final dstPath = p.join(cache.path, name);
    await File(srcPath).copy(dstPath);
    return dstPath;
  }

  Future<void> _saveVideoToGallerySafe(String persistPath, {String album = 'MyApp'}) async {
    final copyForGallery = await _duplicateForGallery(persistPath);
    if (Platform.isAndroid) {
      await MediaStore.ensureInitialized();
      MediaStore.appFolder = album;
      await MediaStore().saveFile(
        tempFilePath: copyForGallery,
        dirType: DirType.video,   // ✅ 비디오
        dirName: DirName.movies,  // Movies
        relativePath: album,      // Movies/MyApp
      );
    } else if (Platform.isIOS) {
      final perm = await PhotoManager.requestPermissionExtend();
      if (perm.hasAccess) {
        await PhotoManager.editor.saveVideo(File(copyForGallery));
      }
    }
  }

  void _deleteLocalFileSilently(String path) {
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }

  // ---------- Video record ----------
  Future<void> _startVideo() async {
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized) return;
    if (_isRecording || cam.value.isRecordingVideo) return;

    await cam.prepareForVideoRecording();
    await cam.startVideoRecording();
    setState(() {
      _isRecording = true;
      _elapsed = Duration.zero;
    });
    _ticker.start();
  }

  Future<void> _stopVideo() async {
    final cam = _cam;
    if (cam == null || !_isRecording || !cam.value.isRecordingVideo) return;

    final xfile = await cam.stopVideoRecording();

    // 프리뷰용 영속 사본 먼저 확보 (문서 폴더)
    final previewPath = await MediaSaverService.persistVideoForPreview(xfile.path);

    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _videoPaths.add(previewPath); // ✅ 저장보다 먼저 UI 반영
      while (_videoPaths.length > _maxVideos) {
        final removed = _videoPaths.removeAt(0);
        try { final f = File(removed); if (f.existsSync()) f.deleteSync(); } catch (_) {}
      }
    });

    // 갤러리에 비동기 저장 (에러 나도 UI는 이미 반영됨)
    try {
      await MediaSaverService.saveVideoToGallery(previewPath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('갤러리 저장 실패: $e')),
      );
    }
  }

  void _deleteVideo(String path) {
    setState(() => _videoPaths.remove(path));
    _deleteLocalFileSilently(path);
  }

  // ---------- Lifecycle ----------
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
    final timerText =
        '${_elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${_elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('영상 촬영 테스트'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  _isRecording ? 'REC $timerText' : '00:00',
                  style: TextStyle(
                    color: _isRecording
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (_cameras.length > 1)
              IconButton(
                tooltip: '카메라 전환',
                icon: const Icon(Icons.cameraswitch),
                onPressed: _switchCamera,
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            camReady
                ? WCameraBox(controller: _cam!, maxHeight: 360)
                : const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator())),
            const WGap.h(12),

            // ⏺/⏹ 컨트롤 (분리된 조각)
            FVideoControls(
              isRecording: _isRecording,
              onStart: _startVideo,
              onStop: _stopVideo,
            ),

            if (_videoPaths.isNotEmpty) ...[
              const WGap.h(16),
              FVideoStrip(
                title: '최근 영상 (${_videoPaths.length}/$_maxVideos)',
                paths: _videoPaths,
                onTap: (path) => showDialog(
                  context: context,
                  barrierColor: Colors.black87,
                  builder: (_) => FVideoPlayerDialog(path: path),
                ),
                onDelete: _deleteVideo,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _cam?.dispose();
    super.dispose();
  }
}

/// 간단 타이머용 Ticker (프레임마다 dt 콜백)
class Ticker {
  Ticker(this.onTick);
  final void Function(Duration) onTick;
  bool _running = false;
  DateTime? _last;

  void start() {
    if (_running) return;
    _running = true;
    _last = DateTime.now();
    _tick();
  }

  void _tick() async {
    while (_running) {
      await Future.delayed(const Duration(milliseconds: 200));
      final now = DateTime.now();
      final dt = now.difference(_last!);
      _last = now;
      onTick(dt);
    }
  }

  void stop() => _running = false;
  void dispose() => _running = false;
}
