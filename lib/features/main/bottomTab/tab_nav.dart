// lib/features/main/widgets/w_menu_drawer.dart
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:simple_shadow/simple_shadow.dart';

import 'package:test_app/features/dialogList/screen/s_dialog.dart';
import 'package:test_app/features/newScreen/screen/s_newScreen.dart';

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

    // 이동할 스크린 리스트
    final entries = <_MenuEntry>[
      _MenuEntry(
        icon: EvaIcons.messageSquareOutline,
        titleKey: 'title.sample_dialogs',
        builder: () => const DialogsScreen(),
      ),
      _MenuEntry(
        icon: EvaIcons.bookOutline,
        titleKey: 'title.new_screen',
        builder: () => const NewScreen(),
      ),
    ];

    // 🔑 루트 컨텍스트(EasyLocalization/Theme 적용 트리)
    final rootCtx = Navigator.of(context, rootNavigator: true).context;

    // 공통: 드로어 닫기
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
                      icon: const Icon(EvaIcons.close),
                      tooltip: 'close'.tr(context: rootCtx), // ✅ 루트 컨텍스트로 번역
                      onPressed: _closeDrawer,
                    ),
                  ],
                ),
              ),

              // ───────── 메뉴 리스트 ─────────
              Expanded(
                child: NavigationDrawer(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (i) {
                    // 1) 드로어 먼저 닫고
                    _closeDrawer();
                    // 2) 다음 프레임에 push (겹치는 애니메이션/컨텍스트 이슈 방지)
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
                        // ✅ 루트 컨텍스트로 번역(드로어 트리 분리 이슈 방지)
                        label: Text(e.titleKey.tr(context: rootCtx)),
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
                          const Icon(EvaIcons.moonOutline, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ModeSwitch(
                              value: context.isDarkMode,
                              onChanged: (_) => ThemeUtil.toggleTheme(rootCtx),
                              height: 30,
                              activeThumbColor: Colors.transparent,
                              inactiveThumbColor: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 다국어 선택 (루트 컨텍스트로 setLocale)
                    _LanguagePicker(rootCtx: rootCtx, onAfterChange: _closeDrawer),

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
  const _LanguagePicker({required this.rootCtx, required this.onAfterChange});
  final BuildContext rootCtx;
  final VoidCallback onAfterChange;

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
                  // 기존 UX 유지: 현재 언어 외 1개만 노출
                  _menu(
                    context,
                    Language.values.firstWhere(
                          (e) => e != currentLang,
                      orElse: () => currentLang,
                    ),
                  ),
                ],
                onChanged: (value) async {
                  if (value == null) return;
                  final chosen = Language.find(value.toLowerCase());
                  // ✅ 루트 컨텍스트로 setLocale → 앱 전체 재빌드
                  await rootCtx.setLocale(chosen.locale);
                  // ✅ 즉시 반영 위해 드로어 닫기
                  onAfterChange();
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
    return Language.values.firstWhere(
          (e) => e.locale.languageCode.toLowerCase() == code,
      orElse: () => Language.english,
    );
  }
}
