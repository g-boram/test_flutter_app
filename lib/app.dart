import 'package:test_app/common/common.dart';
import 'package:test_app/common/theme/custom_theme_app.dart';
import 'package:test_app/screen/main/s_main.dart';
import 'package:flutter/material.dart';

import 'common/theme/custom_theme.dart';

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  ///light, dark 테마가 준비되었고, 시스템 테마를 따라가게 하려면 해당 필드를 제거.
  static const defaultTheme = CustomTheme.light;
  static bool isForeground = true;

  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> with Nav, WidgetsBindingObserver {
  @override
  GlobalKey<NavigatorState> get navigatorKey => App.navigatorKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomThemeApp(
      child: Builder(builder: (context) {
        return MaterialApp(
          navigatorKey: App.navigatorKey,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          title: 'Image Finder',
          theme: context.themeType.themeData,
          home: const MainScreen(),
        );
      }),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        App.isForeground = true;
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        App.isForeground = false;
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden: //Flutter 3.13 이하 버전을 쓰신다면 해당 라인을 삭제.
        break;
    }
    super.didChangeAppLifecycleState(state);
  }
}


// App.navigatorKey를 제공하고 with Nav 믹스인으로 네비 유틸 사용.
// CustomThemeApp으로 감싸서 테마 확장을 context에서 쓸 수 있게 함.
//
// MaterialApp 속성:
// - navigatorKey: 전역 네비게이터 접근
// - localizationsDelegates/supportedLocales/locale: EasyLocalization 연동
// - theme: context.themeType.themeData(커스텀 테마)
// - home: MainScreen
//
// 앱 생명주기에서 App.isForeground 업데이트.