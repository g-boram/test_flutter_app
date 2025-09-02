// lib/shared/ui/typography/base_text.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum BaseTextKind { title, subtitle, body, labelSm }

class BaseText extends StatelessWidget {
  const BaseText(
      this.label, {
        super.key,
        this.translate = true,
        this.kind = BaseTextKind.title, // ✅ 기본을 "타이틀"로!
        this.size,
        this.weight,
        this.color,
        this.align = TextAlign.center,
        this.maxLines,
        this.height = 1.2,
      });

  final String label;          // 번역 키 or 이미 번역된 문자열
  final bool translate;        // true면 label.tr()
  final BaseTextKind kind;     // ✅ variant (기본: title)
  final double? size;          // 지정 시 kind 기본값보다 우선
  final FontWeight? weight;    // 지정 시 kind 기본값보다 우선
  final Color? color;
  final TextAlign align;
  final int? maxLines;
  final double? height;

  // (선택) 과거 팩토리와의 호환 유지용
  factory BaseText.title(String label, {bool translate = true}) =>
      BaseText(label, translate: translate, kind: BaseTextKind.title);

  factory BaseText.subtitle(String label, {bool translate = true}) =>
      BaseText(label, translate: translate, kind: BaseTextKind.subtitle);

  factory BaseText.body(String label, {bool translate = true}) =>
      BaseText(label, translate: translate, kind: BaseTextKind.body);

  factory BaseText.labelSm(String label, {bool translate = true}) =>
      BaseText(label, translate: translate, kind: BaseTextKind.labelSm);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // kind 기본값들
    double defaultSize;
    FontWeight defaultWeight;
    switch (kind) {
      case BaseTextKind.title:
        defaultSize = 32;
        defaultWeight = FontWeight.w800;
        break;
      case BaseTextKind.subtitle:
        defaultSize = 20;
        defaultWeight = FontWeight.w700;
        break;
      case BaseTextKind.body:
        defaultSize = 16;
        defaultWeight = FontWeight.w500;
        break;
      case BaseTextKind.labelSm:
        defaultSize = 12;
        defaultWeight = FontWeight.w600;
        break;
    }

    final resolvedText = translate ? label.tr() : label;

    return Text(
      resolvedText,
      textAlign: align,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: size ?? defaultSize,           // 지정값 > kind 기본값
        fontWeight: weight ?? defaultWeight,
        color: color ?? cs.onSurface,
        height: height,
      ),
    );
  }
}
