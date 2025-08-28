// lib/core/media/media_saver_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaSaverService {
  /// ✅ 오디오 파일을 앱 문서 폴더에 안전하게 복사(보관용)
  /// 반환: 복사된 최종 경로
  static Future<String> copyAudioToAppDocs(
      String srcPath, {
        String subdir = 'audio',
      }) async {
    final src = File(srcPath);
    if (!src.existsSync()) {
      throw Exception('원본 오디오가 존재하지 않습니다: $srcPath');
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(docsDir.path, subdir));
    if (!audioDir.existsSync()) {
      audioDir.createSync(recursive: true);
    }

    // 파일명/확장자 유지, 없으면 .m4a 기본값
    final origName = p.basename(src.path);
    final ext = p.extension(origName).isNotEmpty ? p.extension(origName) : '.m4a';
    final base = (p.basenameWithoutExtension(origName).isNotEmpty)
        ? p.basenameWithoutExtension(origName)
        : 'audio_${DateTime.now().millisecondsSinceEpoch}';

    String dstPath = p.join(audioDir.path, '$base$ext');
    if (File(dstPath).existsSync()) {
      dstPath = p.join(audioDir.path, '${base}_${DateTime.now().millisecondsSinceEpoch}$ext');
    }

    await src.copy(dstPath);
    return dstPath;
  }

  /// ✅ (비디오) 갤러리에 저장
  /// - Android: MediaStore 사용 (Movies/album)
  /// - iOS: PhotoManager 사용
  static Future<void> saveVideoToGallery(String srcPath, {String album = 'MyApp'}) async {
    final tempMp4 = await _duplicateWithMp4(srcPath); // 확장자 보장

    if (Platform.isAndroid) {
      await MediaStore.ensureInitialized();
      MediaStore.appFolder = album;
      await MediaStore().saveFile(
        tempFilePath: tempMp4,
        dirType: DirType.video,
        dirName: DirName.movies,
        relativePath: album, // Movies/MyApp
      );
    } else if (Platform.isIOS) {
      final perm = await PhotoManager.requestPermissionExtend();
      if (perm.hasAccess) {
        await PhotoManager.editor.saveVideo(File(tempMp4));
      }
    }
  }

  /// (선택) 앱 프리뷰용 비디오 영속 사본 경로 반환
  static Future<String> persistVideoForPreview(String srcPath) async {
    final docs = await getApplicationDocumentsDirectory();
    final name = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final dst = p.join(docs.path, name);
    await File(srcPath).copy(dst);
    return dst;
  }

  /// 갤러리 저장을 위해 .mp4 확장자를 강제 보장한 임시 사본 생성
  static Future<String> _duplicateWithMp4(String srcPath) async {
    final tmp = await getTemporaryDirectory();
    final name = 'gal_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final dst = p.join(tmp.path, name);
    await File(srcPath).copy(dst);
    return dst;
  }
}
