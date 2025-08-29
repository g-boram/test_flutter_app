// w_menu_drawer.dart
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart'; // capitalizeFirst
import 'package:simple_shadow/simple_shadow.dart';

import 'package:test_app/features/alertList/fragments/f_alertList.dart';
import 'package:test_app/features/dialogList/screen/s_dialog.dart';
import 'package:test_app/features/ex/newScreen/screen/s_newScreen.dart';
import 'package:test_app/features/study/study_main.dart';

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
    final bg = context.colors.background;
    final entries = <_MenuEntry>[
      _MenuEntry(icon: EvaIcons.bellOutline,           titleKey: 'title.alertList',      builder: () => const AlertList()),
      _MenuEntry(icon: EvaIcons.messageSquareOutline,  titleKey: 'title.sample_dialogs', builder: () => const DialogsScreen()),
      _MenuEntry(icon: EvaIcons.bookOutline,           titleKey: 'title.study_flutter',  builder: () => const StudyMain()),
      _MenuEntry(icon: EvaIcons.bookOutline,           titleKey: 'title.new_screen',  builder: () => const NewScreen()),
    ];

    // 🔑 앱 루트 컨텍스트 (MaterialApp/EasyLocalization가 붙어있는 쪽)
    final rootCtx = Navigator.of(context, rootNavigator: true).context;

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
              // 상단 닫기
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(EvaIcons.close),
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'close'.tr(),
                ),
              ),

              // 메뉴 리스트
              Expanded(
                child: NavigationDrawer(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (i) => onNavigate(entries[i].builder()),
                  children: [
                    const SizedBox(height: 4),
                    for (final e in entries)
                      NavigationDrawerDestination(
                        icon: Icon(e.icon),
                        selectedIcon: Icon(e.icon, color: Theme.of(context).colorScheme.primary),
                        label: Text(e.titleKey.tr()),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 하단: 테마 토글 + 언어 선택 + 카피라이트
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 테마 스위치 (루트 컨텍스트로 토글!)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Row(
                        children: [
                          const Icon(EvaIcons.moonOutline, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ModeSwitch(
                              value: context.isDarkMode,
                              onChanged: (_) {
                                // ✅ 반드시 루트 컨텍스트로 토글해야 전체 리빌드
                                ThemeUtil.toggleTheme(rootCtx);
                              },
                              height: 30,
                              activeThumbImage: Image.asset('$basePath/darkmode/moon.png'),
                              inactiveThumbImage: Image.asset('$basePath/darkmode/sun.png'),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
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
    // ✅ 현재 로케일을 루트에서 읽어와 드롭다운 value로 사용
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
                  // 하나만 고르게 하던 기존 UX를 유지하려면 아래처럼 1개만 대안으로,
                  // 여러 언어 모두 보여주려면 for (final l in Language.values) 로 바꾸세요.
                  _menu(
                    context,
                    Language.values.firstWhere((e) => e != currentLang, orElse: () => currentLang),
                  ),
                ],
                onChanged: (value) async {
                  if (value == null) return;
                  final chosen = Language.find(value.toLowerCase());
                  // ✅ 루트 컨텍스트로 setLocale → 앱 전체 재빌드
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
          _flag(language.flagPath),
          const SizedBox(width: 8),
          Text(
            describeEnum(language).capitalizeFirst!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _flag(String path) {
    return SimpleShadow(
      opacity: 0.5,
      color: Colors.grey,
      offset: const Offset(2, 2),
      sigma: 2,
      child: Image.asset(path, width: 20),
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
      orElse: () => Language.english, // 기본값은 앱 정책에 맞게
    );
  }
}
