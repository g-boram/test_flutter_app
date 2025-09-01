import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum TabItem { home, new_screen }

extension TabItemX on TabItem {
  IconData get icon => switch (this) {
    TabItem.home => EvaIcons.homeOutline,
    TabItem.new_screen => EvaIcons.heartOutline,
  };

  /// 다국어 처리 키 입력
  String get labelKey => switch (this) {
    TabItem.home => 'title.home',
    TabItem.new_screen => 'title.new_screen',
  };

  BottomNavigationBarItem toNavigationBarItem(
      BuildContext context, {
        bool isActivated = false,
      }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      label: labelKey.tr(),
      tooltip: labelKey.tr(),
    );
  }
}
