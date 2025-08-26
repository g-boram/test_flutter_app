import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class AppKeyboardUtil {
  static void hide(BuildContext context) {
    FocusScope.of(context).unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static void show(BuildContext context, FocusNode node) {
    FocusScope.of(context).unfocus();
    Timer(const Duration(milliseconds: 1), () {
      FocusScope.of(context).requestFocus(node);
    });
  }
}
mixin KeyboardDetector<T extends StatefulWidget> on State<T> {
  late final KeyboardVisibilityController _kv;
  StreamSubscription<bool>? _sub;
  bool isKeyboardOn = false;
  final bool useDefaultKeyboardDetectorInit = true;

  @override
  void initState() {
    super.initState();
    if (useDefaultKeyboardDetectorInit) {
      initKeyboardDetector();
    }
  }

  @override
  void dispose() {
    disposeKeyboardDetector();
    super.dispose();
  }

  /// 키보드 show/hide 감지 시작
  /// willShowKeyboard: 키보드가 뜰 때, 현재 키보드 높이(논리 px)를 넘김
  /// willHideKeyboard: 키보드가 내려갈 때 호출
  void initKeyboardDetector({
    void Function(double height)? willShowKeyboard,
    void Function()? willHideKeyboard,
  }) {
    _kv = KeyboardVisibilityController();
    isKeyboardOn = _kv.isVisible;

    _sub = _kv.onChange.listen((visible) {
      if (!mounted) return;

      setState(() => isKeyboardOn = visible);

      if (visible) {
        // viewInsets는 프레임 반영 뒤에 정확하므로 다음 프레임에서 읽기
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final height = MediaQuery.of(context).viewInsets.bottom;
          willShowKeyboard?.call(height);
        });
      } else {
        willHideKeyboard?.call();
      }
    });
  }

  void disposeKeyboardDetector() {
    _sub?.cancel();
    _sub = null;
  }

  /// 필요 시 어디서든 현재 키보드 높이를 얻고 싶을 때
  double get keyboardHeight => MediaQuery.of(context).viewInsets.bottom;
}


// ***** 사용 예시 *****
// class MyPage extends StatefulWidget {
//   const MyPage({super.key});
//   @override
//   State<MyPage> createState() => _MyPageState();
// }
//
// class _MyPageState extends State<MyPage> with KeyboardDetector {
//   @override
//   void initState() {
//     super.initState();
//     initKeyboardDetector(
//       willShowKeyboard: (h) {
//         // 키보드 높이 h 사용
//       },
//       willHideKeyboard: () {
//         // 키보드 내려감 처리
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       // 예: 키보드 올라오면 하단 여백 주기
//       padding: EdgeInsets.only(bottom: isKeyboardOn ? keyboardHeight : 0),
//       child: const TextField(),
//     );
//   }
// }

// ***** 위젯빌더로 간단히 사용할 경우 ******
// import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
//
// KeyboardVisibilityBuilder(
//  builder: (context, visible) {
//  final height = MediaQuery.of(context).viewInsets.bottom;
//
//    return Padding(
//      padding: EdgeInsets.only(bottom: visible ? height : 0),
//      child: const TextField(),
//    );
//   },
// );
