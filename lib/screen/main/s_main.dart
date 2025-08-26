// s_main.dart
import 'package:test_app/screen/main/tab/tab_item.dart';
import 'package:test_app/screen/main/tab/tab_navigator.dart';
import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'w_menu_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // ▼ 어디서든 MainScreenState 찾기 위한 helper
  static MainScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainScreenState>();

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  // ▼ 메인 Scaffold 제어용 key (드로어 열기/닫기 등)
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TabItem _currentTab = TabItem.home;
  final tabs = [TabItem.home, TabItem.favorite];
  final List<GlobalKey<NavigatorState>> navigatorKeys = [];

  int get _currentIndex => tabs.indexOf(_currentTab);

  // 현재 탭 네비게이터 key (외부에서 사용)
  GlobalKey<NavigatorState> get currentTabNavigatorKey => navigatorKeys[_currentIndex];

  // 드로어 제어
  void openDrawer() => scaffoldKey.currentState?.openDrawer();
  void closeDrawer() => scaffoldKey.currentState?.closeDrawer();

  // 탭 전환 (공용)
  void switchTo(TabItem tab) {
    final i = tabs.indexOf(tab);
    if (i != -1) _changeTab(i);
  }

  // 현재 탭 스택에 push
  Future<T?> pushOnCurrentTab<T>(Widget page) {
    final key = currentTabNavigatorKey;
    return key.currentState!.push<T>(MaterialPageRoute(builder: (_) => page));
  }

  // 특정 탭으로 전환 후 그 탭 스택에 push (이미 해당 탭이면 곧바로 push)
  Future<T?> pushOnTab<T>(TabItem tab, Widget page) async {
    final targetIndex = tabs.indexOf(tab);
    if (targetIndex == -1) return null;

    if (_currentTab != tab) {
      switchTo(tab);
      // 다음 프레임에서 push (전환 직후 context/키 안정화 보장)
      final c = Completer<T?>();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final key = navigatorKeys[targetIndex];
        final r = await key.currentState!.push<T>(MaterialPageRoute(builder: (_) => page));
        c.complete(r);
      });
      return c.future;
    } else {
      final key = navigatorKeys[targetIndex];
      return key.currentState!.push<T>(MaterialPageRoute(builder: (_) => page));
    }
  }

  // 현재 탭 스택을 루트까지 비우기
  Future<void> popToRootCurrentTab() async {
    final key = currentTabNavigatorKey;
    while (key.currentState?.canPop() == true) {
      key.currentState!.pop();
    }
  }

  bool get extendBody => true;
  static double get bottomNavigationBarBorderRadius => 30.0;

  @override
  void initState() {
    super.initState();
    initNavigatorKeys();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isRootPage,
      onPopInvoked: _handleBackPressed,
      child: Scaffold(
        key: scaffoldKey, // ★ 중요: 스캐폴드 키 연결
        extendBody: extendBody,
        drawer: const MenuDrawer(),
        body: Container(
          color: context.appColors.seedColor.getMaterialColorValues[200],
          padding: EdgeInsets.only(bottom: extendBody ? 60 - bottomNavigationBarBorderRadius : 0),
          child: SafeArea(
            bottom: !extendBody,
            child: pages,
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  bool get isRootPage =>
      _currentTab == TabItem.home && currentTabNavigatorKey.currentState?.canPop() == false;

  IndexedStack get pages => IndexedStack(
    index: _currentIndex,
    children: tabs
        .mapIndexed((tab, index) => Offstage(
      offstage: _currentTab != tab,
      child: TabNavigator(
        navigatorKey: navigatorKeys[index],
        tabItem: tab,
      ),
    ))
        .toList(),
  );

  void _handleBackPressed(bool didPop) {
    if (!didPop) {
      if (currentTabNavigatorKey.currentState?.canPop() == true) {
        Nav.pop(currentTabNavigatorKey.currentContext!);
        return;
      }
      if (_currentTab != TabItem.home) {
        _changeTab(tabs.indexOf(TabItem.home));
      }
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 0, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bottomNavigationBarBorderRadius),
          topRight: Radius.circular(bottomNavigationBarBorderRadius),
        ),
        child: BottomNavigationBar(
          items: navigationBarItems(context),
          currentIndex: _currentIndex,
          selectedItemColor: context.appColors.text,
          unselectedItemColor: context.appColors.iconButtonInactivate,
          onTap: _handleOnTapNavigationBarItem,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> navigationBarItems(BuildContext context) {
    return tabs
        .mapIndexed(
          (tab, index) => tab.toNavigationBarItem(
        context,
        isActivated: _currentIndex == index,
      ),
    )
        .toList();
  }

  void _changeTab(int index) {
    setState(() {
      _currentTab = tabs[index];
    });
  }

  void _handleOnTapNavigationBarItem(int index) {
    final oldTab = _currentTab;
    final targetTab = tabs[index];
    if (oldTab == targetTab) {
      final navigationKey = currentTabNavigatorKey;
      while (navigationKey.currentState?.canPop() == true) {
        navigationKey.currentState!.pop();
      }
    }
    _changeTab(index);
  }

  void initNavigatorKeys() {
    for (final _ in tabs) {
      navigatorKeys.add(GlobalKey<NavigatorState>());
    }
  }
}
