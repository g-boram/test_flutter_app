// lib/core/media/media_saver_service.dart
import 'dart:io';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';

class MediaSaverService {
  /// 영상 갤러리 저장
  static Future<void> saveVideoToGallery(String path, {String album = 'MyApp'}) async {
    if (!File(path).existsSync()) return;

    if (Platform.isAndroid) {
      await MediaStore.ensureInitialized();
      MediaStore.appFolder = album;
      await MediaStore().saveFile(
        tempFilePath: path,
        dirType: DirType.video,
        dirName: DirName.movies,
        relativePath: album, // Movies/album
      );
    } else if (Platform.isIOS) {
      // iOS 권한 체크 (수정 전: perm.isAuth || perm.isLimited)
      final perm = await PhotoManager.requestPermissionExtend();
      if (perm.hasAccess) { // 부분/전체 접근 모두 true
        await PhotoManager.editor.saveVideo(File(path));
      } else {
        // 권한 거부/제한에서 추가 선택 유도 (iOS 14+)
        // 제한 상태면 PhotoManager.presentLimited()를 띄워 사용자에게 더 선택하게 할 수 있어요.
        // if (perm == PermissionState.limited) {
        //   await PhotoManager.presentLimited();
        // }
        // 아니면 설정 앱으로 유도:
        // await PhotoManager.openSetting();
      }

    }
  }

  /// 오디오를 앱 문서 폴더로 복사 (갤러리 노출 대신 보관용)
  static Future<String> copyAudioToAppDocs(String srcPath, {String? fileName}) async {
    final src = File(srcPath);
    if (!src.existsSync()) return srcPath;
    final dir = await getApplicationDocumentsDirectory();
    final name = fileName ?? 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final dst = File('${dir.path}/$name');
    return (await src.copy(dst.path)).path;
  }
}
