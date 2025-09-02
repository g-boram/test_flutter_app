import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:test_app/features/example/baseText/fragments/f_baseText.dart';

import 'package:test_app/features/example/dialogList/screen/s_dialog.dart';
import 'package:test_app/features/recoder/presentation/screen/s_move_recoder.dart';

import '../../../core/common.dart';
import '../../../core/language/language.dart';
import '../../../shared/theme/theme_util.dart';
import '../../../shared/widgets/w_mode_switch.dart';

class _MenuEntry {
  final IconData icon;
  final String titleKey;
  final Widget Function() builder;
  const _MenuEntry({required this.icon, required this.titleKey, required this.builder});
}

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({
    super.key,
    required this.onNavigate,
    this.selectedIndex = 0,
  });

  final void Function(Widget page) onNavigate;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final bg = context.appColors.seedColor;
    // 이동할 스크린 리스트
    final entries = <_MenuEntry>[
      _MenuEntry(
        icon: Icons.message_outlined,
        titleKey: 'title.sample_dialogs',
        builder: () => const DialogsScreen(),
      ),
      _MenuEntry(
        icon: Icons.paste,
        titleKey: 'title.recoder',
        builder: () => const MoveRecoderScreen(),
      ),
      _MenuEntry(
        icon: Icons.text_fields,
        titleKey: 'title.base_text',
        builder: () => const BaseTextShowcase(),
      ),
    ];

    // 🔑 앱 루트 컨텍스트 (EasyLocalization/Theme가 붙어있는 상위)
    final rootCtx = Navigator.of(context, rootNavigator: true).context;

    // 공통: 드로어 닫기 함수
    void _closeDrawer() {
      final scaffold = Scaffold.maybeOf(context);
      if (scaffold?.isDrawerOpen == true) {
        scaffold?.closeDrawer();
      } else if (scaffold?.isEndDrawerOpen == true) {
        scaffold?.closeEndDrawer();
      } else {
        Navigator.of(context).maybePop();
      }
    }

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Column(
            children: [
              // ───────── 상단 헤더: 로고 placeholder + 닫기(X) ─────────
              Container(
                height: kToolbarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // 앱 로고 자리(이미지 없음 → 빈 박스)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: context.appColors.veryBrightGrey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'close'.tr(),
                      onPressed: _closeDrawer, // ← 안전하게 닫기
                    ),
                  ],
                ),
              ),

              // ───────── 메뉴 리스트 ─────────
              Expanded(
                child: NavigationDrawer(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (i) {

                    _closeDrawer();

                    final page = entries[i].builder();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onNavigate(page);
                    });
                  },
                  children: [
                    const SizedBox(height: 4),
                    for (final e in entries)
                      NavigationDrawerDestination(
                        icon: Icon(e.icon),
                        selectedIcon:
                        Icon(e.icon, color: Theme.of(context).colorScheme.primary),
                        label: Text(e.titleKey.tr()),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ───────── 하단: 테마 토글 + 언어 선택 + 카피라이트 ─────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 테마 스위치 (루트 컨텍스트로 토글 → 앱 전체 반영)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Row(
                        children: [
                          const Icon(Icons.star_border, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ModeSwitch(
                              value: Theme.of(rootCtx).brightness == Brightness.dark,
                              onChanged: (_) => ThemeUtil.toggleTheme(rootCtx),
                              height: 30,
                              activeThumb: Image.asset('$basePath/darkmode/moon.png', fit: BoxFit.cover),
                              inactiveThumb: Image.asset('$basePath/darkmode/sun.png', fit: BoxFit.cover),
                              activeThumbColor: Colors.transparent,
                              inactiveThumbColor: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 다국어 선택 (루트 컨텍스트로 setLocale)
                    _LanguagePicker(rootCtx: rootCtx),

                    const SizedBox(height: 8),

                    // 카피라이트
                    SizedBox(
                      height: 28,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '© 2025. DataEum Flutter Test App',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 언어 선택 영역 (EasyLocalization 동기화)
class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.rootCtx});
  final BuildContext rootCtx;

  @override
  Widget build(BuildContext context) {

    final currentLocale = rootCtx.locale;
    final currentLang = LanguageX.fromLocale(currentLocale);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 5, right: 5),
          margin: const EdgeInsets.only(left: 15, right: 20),
          decoration: BoxDecoration(
            border: Border.all(color: context.appColors.veryBrightGrey),
            borderRadius: BorderRadius.circular(10),
            color: context.appColors.drawerBg,
            boxShadow: [context.appShadows.buttonShadowSmall],
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              DropdownButton<String>(
                items: [
                  _menu(context, currentLang),
                  _menu(
                    context,
                    Language.values.firstWhere((e) => e != currentLang, orElse: () => currentLang),
                  ),
                ],
                onChanged: (value) async {
                  if (value == null) return;
                  final chosen = Language.find(value.toLowerCase());
                  // 루트 컨텍스트로 setLocale → 앱 전체 재빌드
                  await rootCtx.setLocale(chosen.locale);
                  // 즉시 반영 보려면 드로어 닫기도 가능:
                  // Navigator.of(context).maybePop();
                },
                value: describeEnum(currentLang).capitalizeFirst,
                underline: const SizedBox.shrink(),
                elevation: 1,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _menu(BuildContext context, Language language) {
    return DropdownMenuItem(
      value: describeEnum(language).capitalizeFirst,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            describeEnum(language).capitalizeFirst!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

}

/// Language 유틸 (현재 로케일 → Language enum 역매핑)
extension LanguageX on Language {
  static Language fromLocale(Locale locale) {
    final code = locale.languageCode.toLowerCase();
    // 프로젝트의 Language 정의에 맞춰 보정
    return Language.values.firstWhere(
          (e) => e.locale.languageCode.toLowerCase() == code,
      orElse: () => Language.english,
    );
  }
}
