import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// 앱바 액션용: 탭 한 번에 다음 언어로 "토글" (ko <-> en 처럼 2개일 때 특히 간단)
class LocaleToggleAction extends StatelessWidget {
  final List<Locale>? locales;          // null이면 context.supportedLocales 사용
  final bool showCode;                  // 현재 언어 코드(KO/EN 등) 표시
  final EdgeInsetsGeometry padding;

  const LocaleToggleAction({
    super.key,
    this.locales,
    this.showCode = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 6),
  });

  @override
  Widget build(BuildContext context) {
    final supported = (locales ?? context.supportedLocales).toList();
    if (supported.isEmpty) return const SizedBox.shrink();

    final current = context.locale;

    String _code(Locale l) => (l.languageCode == 'ko') ? 'KO' : l.languageCode.toUpperCase();
    String _label(Locale l) {
      switch (l.languageCode) {
        case 'ko':
          return '한국어';
        case 'en':
          return 'English';
        default:
          return l.toLanguageTag();
      }
    }

    void _cycle() async {
      final idx = supported.indexWhere((l) =>
      l.languageCode == current.languageCode && l.countryCode == current.countryCode);
      final next = supported[(idx + 1) % supported.length];
      await context.setLocale(next); // EasyLocalization 설정 (saveLocale: true 권장)
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('언어 변경: ${_label(next)}')),
      );
    }

    return Padding(
      padding: padding,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _cycle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language),
            if (showCode) ...[
              const SizedBox(width: 6),
              Text(_code(current), style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}
