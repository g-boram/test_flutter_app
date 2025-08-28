import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:media_store_plus/media_store_plus.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../core/permissions/permission_service.dart';
import '../../../../shared/widgets/w_gap.dart';
import '../../../../shared/widgets/w_camera_box.dart';
import '../../../../shared/widgets/buttons/w_primary_button.dart';

import '../../fragments/f_photo_viewer.dart';
import '../../fragments/f_photo_strip.dart';

class CameraTestScreen extends StatefulWidget {
  const CameraTestScreen({super.key});

  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen>
    with WidgetsBindingObserver {
  // --- Camera ---
  CameraController? _cam;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  // --- Photo (max 10) ---
  static const int _maxPhotos = 10;
  final List<String> _photoPaths = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final ok = await PermissionService.ensureCamera(); // ✅ 카메라만 요청
    if (!ok) return;

    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    _cam = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.medium,
      enableAudio: false, // ✅ 오디오 비활성
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

  // ---------- Photo helpers ----------
  Future<String> _persistPhotoForPreview(XFile x) async {
    final docs = await getApplicationDocumentsDirectory();
    final ext = x.name.contains('.') ? x.name.split('.').last : 'jpg';
    final dstPath =
    p.join(docs.path, 'photo_${DateTime.now().millisecondsSinceEpoch}.$ext');
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

  Future<void> _saveImageToGallerySafe(String persistPath,
      {String album = 'MyApp'}) async {
    final copyForGallery = await _duplicateForGallery(persistPath);
    if (Platform.isAndroid) {
      await MediaStore.ensureInitialized();
      MediaStore.appFolder = album;
      await MediaStore().saveFile(
        tempFilePath: copyForGallery,
        dirType: DirType.photo,
        dirName: DirName.pictures,
        relativePath: album,
      );
    } else if (Platform.isIOS) {
      final perm = await PhotoManager.requestPermissionExtend();
      if (perm.hasAccess) {
        await PhotoManager.editor.saveImageWithPath(copyForGallery);
      }
    }
  }

  // ---------- Photo actions ----------
  Future<void> _takePhoto() async {
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized) return;

    try {
      final x = await cam.takePicture();

      // 1) 앱 내부 영속 사본 확보
      final previewPath = await _persistPhotoForPreview(x);

      // 2) 갤러리에 복사본 저장
      await _saveImageToGallerySafe(previewPath);

      // 3) 목록에 영속 사본 추가 (최대 10개 유지)
      setState(() {
        _photoPaths.add(previewPath);
        while (_photoPaths.length > _maxPhotos) {
          final removed = _photoPaths.removeAt(0);
          _deleteLocalFileSilently(removed);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 촬영 실패: $e')),
      );
    }
  }

  void _deleteLocalFileSilently(String path) {
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }

  void _openPhoto(String path) {
    if (!File(path).existsSync()) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => FPhotoViewer(path: path),
    );
  }

  void _deletePhoto(String path) {
    setState(() => _photoPaths.remove(path));
    _deleteLocalFileSilently(path);
  }

  // ---------- Lifecycle ----------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_cam == null) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await _cam?.dispose();
      _cam = null;
    } else if (state == AppLifecycleState.resumed) {
      await _initCamera();
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final camReady = _cam?.value.isInitialized == true;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('사진 촬영 테스트'),
          actions: [
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
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            const WGap.h(12),

            // ✅ 사진만 촬영
            WPrimaryButton(
              label: '📸 사진 촬영',
              onPressed: _takePhoto,
            ),

            if (_photoPaths.isNotEmpty) ...[
              const WGap.h(16),
              FPhotoStrip(
                title: '최근 사진 (${_photoPaths.length}/$_maxPhotos)',
                paths: _photoPaths,
                onTap: _openPhoto,
                onDelete: _deletePhoto,
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
    _cam?.dispose();
    super.dispose();
  }
}
