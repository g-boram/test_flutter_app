import 'package:flutter/widgets.dart';
import 'package:test_app/features/main/bottomTab/tab_item.dart';

sealed class DrawerAction {
  const DrawerAction();
}

class SwitchTab extends DrawerAction {
  final TabItem tab;
  const SwitchTab(this.tab);
}

class PushOnCurrent extends DrawerAction {
  final WidgetBuilder builder; // 필요할 때만 생성
  const PushOnCurrent(this.builder);
}
