import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> ensureCamera() async {
    final st = await Permission.camera.request();
    return st.isGranted;
  }

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
