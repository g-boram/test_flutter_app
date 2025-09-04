import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/setting/w_locale_menu_action.dart';

class FeatureLayout extends StatelessWidget {
  final String titleKey;                 // i18n key 또는 평문
  final Widget child;                    // 본문
  final String? bottomDescKey;           // 하단 설명(옵션)
  final EdgeInsetsGeometry padding;      // 패딩
  final List<Widget>? actions;           // 우측 상단 액션(옵션)
  final bool? showBackButton;            // null=자동(Navigator.canPop), true/false로 강제 가능
  final VoidCallback? onBack;            // 커스텀 뒤로가기 핸들러(옵션)
  final PreferredSizeWidget? bottom;     // (옵션) TabBar 등 AppBar bottom에 꽂기
  final bool showLocaleToggle;           // 기본 true
  final List<Locale>? localeList;        // 특정 순서/언어 제한 시

  const FeatureLayout({
    super.key,
    required this.titleKey,
    required this.child,
    this.bottomDescKey,
    this.padding = const EdgeInsets.all(20),
    this.actions,
    this.showBackButton, // null이면 자동
    this.onBack,
    this.bottom,
    this.showLocaleToggle = true,     // 전역 토글 기본 ON
    this.localeList,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBackButton ?? canPop;
    final t = _maybeTr(titleKey);
    final d = bottomDescKey == null ? null : _maybeTr(bottomDescKey!);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 우리가 직접 leading 제어
        leading: shouldShowBack
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        )
            : null,
        // title: Text(t, overflow: TextOverflow.ellipsis),
        actions: const [
          LocaleMenuAction(
            // locales: [Locale('ko'), Locale('en')], // 순서 고정하고 싶을 때
            variant: LocaleActionVariant.filled, // filled | tonal | outlined | text
            showIcon: false,
            showFlag: true,
            showCode: true,
            showLabel: false,
            compact: false,
            showSnackBar: true,
          ),
        ],
        bottom: bottom, // 필요하면 TabBar 등 부착
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // 본문
            Expanded(
              child: Padding(
                padding: padding,
                child: Material( // TabBar/Ink 등 머터리얼 효과 보장
                  color: Colors.transparent,
                  child: child,
                ),
              ),
            ),
            // 하단 설명
            if (d != null && d.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(d, style: Theme.of(context).textTheme.bodyLarge),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _maybeTr(String keyOrText) {
    final trd = tr(keyOrText);
    return trd == keyOrText ? keyOrText : trd;
  }
}
