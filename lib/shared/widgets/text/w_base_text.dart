import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:test_app/core/constant/typography.dart';

class AppText extends StatelessWidget {
  final String text;

  // 토큰
  final TxtSize size;
  final TxtWeight weight;

  // 스타일
  final Color? color;
  final TextAlign? align;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool muted;
  final bool underline;
  final bool italic;
  final double? letterSpacing;

  /// ✅ 기본 true: text를 i18n 키로 간주하여 tr() 적용
  /// false면 text를 평문 그대로 표시
  final bool isKey;

  const AppText(
      this.text, {
        super.key,
        this.size = TxtSize.md,
        this.weight = TxtWeight.regular,
        this.color,
        this.align,
        this.overflow,
        this.maxLines,
        this.muted = false,
        this.underline = false,
        this.italic = false,
        this.letterSpacing,
        this.isKey = true, // 기본은 키
      });

  // ---- 프리셋(기본은 키) ----
  factory AppText.title(String text,
      {TxtSize size = TxtSize.xl, TxtWeight weight = TxtWeight.extrabold, Key? key, bool isKey = true}) =>
      AppText(text, key: key, size: size, weight: weight, isKey: isKey);

  factory AppText.subtitle(String text,
      {TxtSize size = TxtSize.lg, TxtWeight weight = TxtWeight.semibold, Key? key, bool isKey = true, bool muted = true}) =>
      AppText(text, key: key, size: size, weight: weight, isKey: isKey, muted: muted);

  factory AppText.body(String text,
      {TxtSize size = TxtSize.md, TxtWeight weight = TxtWeight.regular, Key? key, bool isKey = true}) =>
      AppText(text, key: key, size: size, weight: weight, isKey: isKey);

  factory AppText.caption(String text,
      {TxtSize size = TxtSize.xs, TxtWeight weight = TxtWeight.medium, Key? key, bool isKey = true, bool muted = true}) =>
      AppText(text, key: key, size: size, weight: weight, isKey: isKey, muted: muted);

  @override
  Widget build(BuildContext context) {
    // 1) 텍스트 결정
    final display = isKey ? text.tr() : text;

    // 2) 스타일(토큰 기반)
    final cs = Theme.of(context).colorScheme;
    final style = TextStyle(
      fontSize: TTypography.sizes[size]!,
      height: TTypography.lineHeights[size]!,
      fontWeight: TTypography.weights[weight]!,
      color: (color ?? cs.onSurface).withOpacity(muted ? 0.68 : 1),
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: letterSpacing,
    );

    return Text(
      display,
      textAlign: align,
      overflow: overflow,
      maxLines: maxLines,
      style: style,
    );
  }
}
