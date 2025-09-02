// lib/shared/layout/app_page.dart
import 'package:flutter/material.dart';
import 'package:test_app/features/main/screen/s_main.dart';
import 'package:test_app/core/common.dart';

PreferredSizeWidget smartAppBar(
    BuildContext context, {
      required String titleText,
      List<Widget>? actions,
    }) {
  final canPop = Navigator.of(context).canPop();
  return AppBar(
    automaticallyImplyLeading: false,
    leading: canPop
        ? const BackButton()
        : IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () => MainScreen.of(context)?.openDrawer(),
      tooltip: 'Open menu',
    ),
    title: Text(titleText),
    actions: actions,
  );
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.fab,
    this.bottom,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Widget? fab;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? context.appColors.seedColor;

    final titleText = title;

    return Scaffold(
      appBar: bottom == null
          ? smartAppBar(context, titleText: titleText, actions: actions)
          : AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? const BackButton()
            : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainScreen.of(context)?.openDrawer(),
        ),
        title: Text(titleText),
        actions: actions,
        bottom: bottom,
      ),
      body: Container(
        color: bg,
        child: SafeArea(
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
      floatingActionButton: fab,
    );
  }
}
