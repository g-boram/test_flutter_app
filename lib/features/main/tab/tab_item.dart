import 'package:test_app/core/common.dart';
import 'package:test_app/features/favorite/fragments/f_favorite.dart';
import 'package:flutter/material.dart';
import 'package:test_app/features/main/screen/s_home.dart';


enum TabItem {
  home(Icons.home, '홈', HomeScreen()),
  // alert(Icons.notifications, '알림창 모음', AlertFragment(), inActiveIcon: Icons.notifications_none),
  favorite(Icons.star, '즐겨찾기', FavoriteFragment());

  final IconData activeIcon;
  final IconData inActiveIcon;
  final String tabName;
  final Widget firstPage;

  const TabItem(this.activeIcon, this.tabName, this.firstPage, {IconData? inActiveIcon})
      : inActiveIcon = inActiveIcon ?? activeIcon;

  BottomNavigationBarItem toNavigationBarItem(BuildContext context, {required bool isActivated}) {
    return BottomNavigationBarItem(
        icon: Icon(
          key: ValueKey(tabName),
          isActivated ? activeIcon : inActiveIcon,
          color:
              isActivated ? context.appColors.iconButton : context.appColors.iconButtonInactivate,
        ),
        label: tabName);
  }
}
