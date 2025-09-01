import 'dart:async';
import 'package:flutter/material.dart';
import 'package:test_app/features/main/bottomTab/tab_item.dart';
import 'package:test_app/features/main/bottomTab/tab_navigator.dart';
import 'package:test_app/features/main/widgets/w_menu_drawer.dart';

import '../../../core/common.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static MainScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainScreenState>();

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TabItem _currentTab = TabItem.home;
  final tabs = [TabItem.home, TabItem.new_screen];
  final List<GlobalKey<NavigatorState>> navigatorKeys = [];

  int get _currentIndex => tabs.indexOf(_currentTab);
  GlobalKey<NavigatorState> get currentTabNavigatorKey => navigatorKeys[_currentIndex];

  void openDrawer() => scaffoldKey.currentState?.openDrawer();
  void closeDrawer() => scaffoldKey.currentState?.closeDrawer();

  Future<T?> pushOnCurrentTab<T>(Widget page) {
    final key = currentTabNavigatorKey;
    return key.currentState!.push<T>(MaterialPageRoute(builder: (_) => page));
  }

  Future<T?> pushOnTab<T>(TabItem tab, Widget page) async {
    final targetIndex = tabs.indexOf(tab);
    if (targetIndex == -1) return null;

    if (_currentTab != tab) {
      _changeTab(targetIndex);
      final c = Completer<T?>();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final key = navigatorKeys[targetIndex];
        final r =
        await key.currentState!.push<T>(MaterialPageRoute(builder: (_) => page));
        c.complete(r);
      });
      return c.future;
    } else {
      final key = navigatorKeys[targetIndex];
      return key.currentState!.push<T>(MaterialPageRoute(builder: (_) => page));
    }
  }

  bool get extendBody => true;
  static double get bottomNavigationBarBorderRadius => 30.0;

  @override
  void initState() {
    super.initState();
    for (final _ in tabs) {
      navigatorKeys.add(GlobalKey<NavigatorState>());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isRootPage,
      onPopInvoked: _handleBackPressed,
      child: Scaffold(
        key: scaffoldKey,
        extendBody: extendBody,

        // 왼쪽 사이드바 정의
        drawer: MenuDrawer(
          selectedIndex: _currentIndex, // 하이라이트 인덱스
          onNavigate: (page) {
            // 여기서는 굳이 closeDrawer 안 해도 됨(드로어 내부에서 닫음)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              pushOnCurrentTab(page);
            });
          },
        ),

        body: Container(
          color: context.appColors.seedColor.getMaterialColorValues[200],
          padding: EdgeInsets.only(
            bottom: extendBody ? 60 - bottomNavigationBarBorderRadius : 0,
          ),
          child: SafeArea(bottom: !extendBody, child: pages),
        ),

        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  bool get isRootPage =>
      _currentTab == TabItem.home &&
          currentTabNavigatorKey.currentState?.canPop() == false;

  IndexedStack get pages => IndexedStack(
    index: _currentIndex,
    children: [
      for (int i = 0; i < tabs.length; i++)
        Offstage(
          offstage: _currentIndex != i,
          child: TabNavigator(
            navigatorKey: navigatorKeys[i],
            tabItem: tabs[i],
          ),
        ),
    ],
  );

  void _handleBackPressed(bool didPop) {
    if (!didPop) {
      if (currentTabNavigatorKey.currentState?.canPop() == true) {
        currentTabNavigatorKey.currentState!.pop();
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
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
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
        .map((tab) => tab.toNavigationBarItem(
      context,
      isActivated: _currentTab == tab,
    ))
        .toList();
  }

  void _changeTab(int index) {
    setState(() => _currentTab = tabs[index]);
  }

  void _handleOnTapNavigationBarItem(int index) {
    if (tabs[index] == _currentTab) {
      final nav = currentTabNavigatorKey;
      // 같은 탭을 다시 탭 → 루트까지 pop (스크롤-투-탑은 여기서 추가도 가능)
      while (nav.currentState?.canPop() == true) {
        nav.currentState!.pop();
      }
    }
    _changeTab(index);
  }
}
