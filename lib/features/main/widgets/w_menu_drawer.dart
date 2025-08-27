import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_app/features/main/screen/s_main.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:simple_shadow/simple_shadow.dart';

// 알림창 리스트 페이지
import 'package:test_app/features/alertList/fragments/f_alertList.dart';
import 'package:test_app/features/dialogList/fragments/f_smaple_dialogs.dart';

import '../../../core/common.dart';
import '../../../core/language/language.dart';
import '../../../shared/theme/theme_util.dart';
import '../../../shared/widget/w_mode_switch.dart';

class MenuDrawer extends StatefulWidget {
  static const minHeightForScrollView = 380;

  const MenuDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Tap(
          onTap: () {
            closeDrawer(context);
          },
          child: Tap(
            onTap: () {},
            child: Container(
              width: 300,
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                  color: context.colors.background),
              child: isSmallScreen(context)
                  ? SingleChildScrollView(
                      child: getMenus(context),
                    )
                  : getMenus(context),
            ),
          ),
        ),
      ),
    );
  }

  bool isSmallScreen(BuildContext context) =>
      context.deviceHeight < MenuDrawer.minHeightForScrollView;

  Container getMenus(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: context.deviceHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(EvaIcons.close),
                  onPressed: () {
                    closeDrawer(context);
                  },
                  padding: const EdgeInsets.only(
                    top: 0,
                    right: 20,
                    left: 20,
                  ),
                ),
              )
            ],
          ),
          const Height(10),
          // 여기에 페이지 이동 추가
          const Line(),
          _MenuWidget(
            'alertList'.tr(),
            onTap: () async {
              // 1) 드로어 닫기
              Navigator.of(context).pop();

              // 2) 한 프레임 뒤에 현재 탭 스택으로 push
              WidgetsBinding.instance.addPostFrameCallback((_) {
                MainScreen.of(context)
                    ?.pushOnCurrentTab(const AlertList());
                // 특정 탭으로 강제하고 싶다면:
                // MainScreen.of(context)?.pushOnTab(TabItem.home, const AlertList());
              });
            },
          ),
          const Line(),
          _MenuWidget(
            'sample_dialogs'.tr(),
            onTap: () async {
              Navigator.of(context).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                MainScreen.of(context)
                    ?.pushOnCurrentTab(const SampleDialogs());
              });
            },
          ),
          const Line(),
          isSmallScreen(context) ? const Height(10) : const EmptyExpanded(),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ModeSwitch(
              value: context.isDarkMode,
              onChanged: (value) {
                ThemeUtil.toggleTheme(context);
              },
              height: 30,
              activeThumbImage: Image.asset('$basePath/darkmode/moon.png'),
              inactiveThumbImage: Image.asset('$basePath/darkmode/sun.png'),
              activeThumbColor: Colors.transparent,
              inactiveThumbColor: Colors.transparent,
            ).pOnly(left: 20),
          ),
          const Height(10),
          getLanguageOption(context),
          const Height(10),
          Row(
            children: [
              Expanded(
                child: Tap(
                  child: Container(
                      height: 30,
                      width: 100,
                      padding: const EdgeInsets.only(left: 15),
                      child: '© 2025. DataEum Flutter Test App'
                          .selectableText
                          .size(10)
                          .makeWithDefaultFont()),
                  onTap: () async {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void toggleTheme() {
    ThemeUtil.toggleTheme(context);
  }

  void closeDrawer(BuildContext context) {
    final s1 = Scaffold.maybeOf(context);
    if (s1?.isDrawerOpen == true) {
      s1!.closeDrawer();
      return;
    }
    // 메인 스캐폴드 직접 제어 (드로어 열려있다면 닫힘)
    final main = MainScreen.of(context)?.scaffoldKey.currentState;
    if (main?.isDrawerOpen == true) {
      main!.closeDrawer();
    }
  }

  Widget getLanguageOption(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Tap(
            child: Container(
                padding: const EdgeInsets.only(left: 5, right: 5),
                margin: const EdgeInsets.only(left: 15, right: 20),
                decoration: BoxDecoration(
                    border: Border.all(color: context.appColors.veryBrightGrey),
                    borderRadius: BorderRadius.circular(10),
                    color: context.appColors.drawerBg,
                    boxShadow: [context.appShadows.buttonShadowSmall]),
                child: Row(
                  children: [
                    const Width(10),
                    DropdownButton<String>(
                      items: [
                        menu(currentLanguage),
                        menu(Language.values.where((element) => element != currentLanguage).first),
                      ],
                      onChanged: (value) async {
                        if (value == null) {
                          return;
                        }
                        await context.setLocale(Language.find(value.toLowerCase()).locale);
                      },
                      value: describeEnum(currentLanguage).capitalizeFirst,
                      underline: const SizedBox.shrink(),
                      elevation: 1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                )),
            onTap: () async {},
          ),
        ],
      );

  DropdownMenuItem<String> menu(Language language) {
    return DropdownMenuItem(
      value: describeEnum(language).capitalizeFirst,
      child: Row(
        children: [
          flag(language.flagPath),
          const Width(8),
          describeEnum(language)
              .capitalizeFirst!
              .text
              .color(Theme.of(context).textTheme.bodyLarge?.color)
              .size(12)
              .makeWithDefaultFont(),
        ],
      ),
    );
  }

  Widget flag(String path) {
    return SimpleShadow(
      opacity: 0.5,
      // Default: 0.5
      color: Colors.grey,
      // Default: Black
      offset: const Offset(2, 2),
      // Default: Offset(2, 2)
      sigma: 2,
      // Default: 2
      child: Image.asset(
        path,
        width: 20,
      ),
    );
  }
}

class _MenuWidget extends StatelessWidget {
  final String text;
  final Function() onTap;

  const _MenuWidget(this.text, {Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Tap(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 20),
          child: Row(
            children: [
              Expanded(
                  child: text.text
                      .textStyle(defaultFontStyle())
                      .color(context.appColors.drawerText)
                      .size(15)
                      .make()),
            ],
          ),
        ),
      ),
    );
  }
}
