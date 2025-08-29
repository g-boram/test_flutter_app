// tab_navigator.dart
import 'package:flutter/material.dart';
import 'package:test_app/features/favorite/fragments/f_favorite.dart';
import 'package:test_app/features/main/screen/s_home.dart';
import 'tab_item.dart';


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
      key: navigatorKey, // ✅ 필수
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => _rootFor(tabItem),
        );
      },
    );
  }

  // 각 탭의 루트 화면(여기에 메뉴 버튼이 있어야 Drawer를 열 수 있음)
  Widget _rootFor(TabItem tab) {
    switch (tab) {
      case TabItem.home:
        return const HomeScreen();       // ✅ AppBar leading에 Drawer 토글 포함
      case TabItem.favorite:
        return const FavoriteFragment();   // ✅ 동일
    }
  }
}
