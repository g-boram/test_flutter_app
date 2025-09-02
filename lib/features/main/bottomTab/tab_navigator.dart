import 'package:flutter/material.dart';
import 'package:test_app/features/main/bottomTab/tab_item.dart';
import 'package:test_app/features/main/screen/s_home.dart';
import 'package:test_app/features/example/newScreen/screen/s_newScreen.dart';

class TabNavigator extends StatelessWidget {
  const TabNavigator({
    super.key,
    required this.navigatorKey,
    required this.tabItem,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        Widget page;
        switch (tabItem) {
          case TabItem.home:
            page = const HomeScreen(); // 홈 탭 루트
            break;
          case TabItem.new_screen:
            page = const NewScreen(); // 즐겨찾기 탭 루트
            break;
        }
        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}
