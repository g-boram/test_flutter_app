import 'package:permission_handler/permission_handler.dart';


class PermissionService {
  // 카메라 권한
  static Future<bool> ensureCamera() async {
    final st = await Permission.camera.request();
    return st.isGranted;
  }
  // 마이크 권한
  static Future<bool> ensureMic() async {
    final st = await Permission.microphone.request();
    return st.isGranted;
  }

  static Future<bool> ensureCameraAndMic() async {
    final cam = await ensureCamera();
    final mic = await ensureMic();
    return cam && mic;
  }
}
