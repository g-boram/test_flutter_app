import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// AppBar 우측에 두는 "언어 선택" 팝업 액션
class LocaleMenuAction extends StatelessWidget {
  /// 명시적으로 사용할 언어 목록(순서 포함). null이면 context.supportedLocales 사용
  final List<Locale>? locales;

  /// 버튼 변형
  final LocaleActionVariant variant;

  /// 버튼 내부 표현
  final bool showIcon;   // 🌐 아이콘
  final bool showFlag;   // 🇰🇷 같은 플래그 이모지
  final bool showCode;   // KO/EN 코드
  final bool showLabel;  // 한국어 / English 라벨

  /// 버튼 크기/여백
  final bool compact; // true면 더 촘촘하게

  /// 선택 시 스낵바 안내
  final bool showSnackBar;

  /// 선택 후 콜백
  final ValueChanged<Locale>? onChanged;

  const LocaleMenuAction({
    super.key,
    this.locales,
    this.variant = LocaleActionVariant.filled,
    this.showIcon = true,
    this.showFlag = true,
    this.showCode = true,
    this.showLabel = false,
    this.compact = false,
    this.showSnackBar = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final supported = (locales ?? context.supportedLocales).toList();
    if (supported.isEmpty) return const SizedBox.shrink();

    final current = context.locale;
    final cs = Theme.of(context).colorScheme;

    final (bg, fg, border) = switch (variant) {
      LocaleActionVariant.filled => (cs.primaryContainer, cs.onPrimaryContainer, null),
      LocaleActionVariant.tonal => (cs.secondaryContainer, cs.onSecondaryContainer, null),
      LocaleActionVariant.outlined => (Colors.transparent, cs.onSurface, cs.outline),
      LocaleActionVariant.text => (Colors.transparent, cs.onSurface, null),
    };

    Future<void> select(Locale next) async {
      await context.setLocale(next);
      onChanged?.call(next);
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (showSnackBar && messenger != null) {
        messenger.showSnackBar(SnackBar(content: Text('언어 변경: ${_label(next)}')));
      }
    }

    final child = _LocalePill(
      icon: showIcon ? const Icon(Icons.language, size: 20) : null,
      flag: showFlag ? _flagEmoji(next: null, current: current) : null, // 현재 언어 플래그
      code: showCode ? _code(current) : null,
      label: showLabel ? _label(current) : null,
      bg: bg,
      fg: fg,
      borderColor: border,
      compact: compact,
    );

    return PopupMenuButton<Locale>(
      tooltip: '언어 선택',
      onSelected: select,
      itemBuilder: (ctx) => [
        for (final l in supported)
          PopupMenuItem<Locale>(
            value: l,
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: (l == current)
                      ? const Icon(Icons.check, size: 18)
                      : const SizedBox.shrink(),
                ),
                if (showFlag) Text(_flagEmoji(locale: l) ?? '', style: const TextStyle(fontSize: 18)),
                if (showFlag) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _label(l),
                    style: TextStyle(
                      fontWeight: l == current ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (showCode) ...[
                  const SizedBox(width: 8),
                  Text('(${_code(l)})', style: Theme.of(ctx).textTheme.bodySmall),
                ],
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: child,
      ),
    );
  }

  String _code(Locale l) => (l.languageCode == 'ko')
      ? 'KO'
      : l.languageCode.toUpperCase();

  String _label(Locale l) {
    switch (l.languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      default:
        return l.languageCode.toUpperCase();
    }
  }

  /// 현재/지정 로케일의 국기 이모지 생성
  /// - countryCode 있는 경우 우선 사용, 없으면 언어→대표국 매핑
  String? _flagEmoji({Locale? locale, Locale? next, Locale? current}) {
    final l = locale ?? next ?? current;
    if (l == null) return null;
    final cc = (l.countryCode?.toUpperCase() ?? _defaultCountryForLang(l.languageCode));
    if (cc == null || cc.length != 2) return null;
    const base = 0x1F1E6; // 'A'
    final first = base + (cc.codeUnitAt(0) - 65);
    final second = base + (cc.codeUnitAt(1) - 65);
    return String.fromCharCodes([first, second]);
  }

  String? _defaultCountryForLang(String lang) {
    switch (lang) {
      case 'ko':
        return 'KR';
      case 'en':
        return 'US';
      case 'ja':
        return 'JP';
      case 'zh':
        return 'CN';
      case 'fr':
        return 'FR';
      case 'es':
        return 'ES';
      case 'de':
        return 'DE';
      default:
        return null;
    }
  }
}

enum LocaleActionVariant { filled, tonal, outlined, text }

/// 내부: pill 모양 버튼
class _LocalePill extends StatelessWidget {
  final Widget? icon;
  final String? flag;
  final String? code;
  final String? label;
  final Color bg;
  final Color fg;
  final Color? borderColor;
  final bool compact;

  const _LocalePill({
    required this.bg,
    required this.fg,
    this.borderColor,
    this.icon,
    this.flag,
    this.code,
    this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final padH = compact ? 10.0 : 14.0;
    final padV = compact ? 6.0 : 10.0;

    final children = <Widget>[];
    if (icon != null) {
      children.add(IconTheme.merge(
        data: IconThemeData(color: fg, size: icon is Icon ? (icon as Icon).size ?? 20 : 20),
        child: icon!,
      ));
    }
    if (flag != null && flag!.isNotEmpty) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 6));
      children.add(Text(flag!, style: const TextStyle(fontSize: 16)));
    }
    if (code != null && code!.isNotEmpty) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 6));
      children.add(Text(code!, style: TextStyle(fontWeight: FontWeight.w800, color: fg)));
    }
    if (label != null && label!.isNotEmpty) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 6));
      children.add(Text(label!, style: TextStyle(color: fg)));
    }

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: bg,
        shape: StadiumBorder(
          side: (borderColor == null)
              ? BorderSide.none
              : BorderSide(color: borderColor!),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
