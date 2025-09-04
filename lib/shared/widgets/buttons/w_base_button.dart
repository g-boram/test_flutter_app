import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:test_app/core/constant/colors.dart';

enum BaseBtnVariant { filled, tonal, outlined, text }
enum BaseBtnSize { sm, md, lg }

class BaseButton extends StatefulWidget {
  final String label;
  final bool labelIsKey;
  final VoidCallback? onPressed;

  final BaseBtnVariant variant;
  final BaseBtnSize size;
  final bool fullWidth;
  final bool loading;

  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// 파괴적(위험) 느낌으로 색상 전환 (filled/tonal/outlined/text 각각에 맞게 적용)
  final bool destructive;

  /// 빠른 연타 방지 (0이면 비활성)
  final Duration debounce;

  /// 버튼 스타일 커스터마이즈 (shape, padding, 색상 등)
  final ButtonStyle? styleOverride;

  const BaseButton({
    super.key,
    required this.label,
    this.labelIsKey = true,
    this.onPressed,
    this.variant = BaseBtnVariant.filled,
    this.size = BaseBtnSize.md,
    this.fullWidth = true,
    this.loading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.destructive = false,
    this.debounce = const Duration(milliseconds: 400),
    this.styleOverride,
  });

  @override
  State<BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<BaseButton> {
  bool _locked = false;

  double get _height => switch (widget.size) {
    BaseBtnSize.sm => 44,
    BaseBtnSize.md => 56,
    BaseBtnSize.lg => 64,
  };

  TextStyle get _textStyle => switch (widget.size) {
    BaseBtnSize.sm => const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    BaseBtnSize.md => const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    BaseBtnSize.lg => const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
  };

  EdgeInsetsGeometry get _padding => switch (widget.size) {
    BaseBtnSize.sm => const EdgeInsets.symmetric(horizontal: 12),
    BaseBtnSize.md => const EdgeInsets.symmetric(horizontal: 16),
    BaseBtnSize.lg => const EdgeInsets.symmetric(horizontal: 20),
  };

  Future<void> _handlePressed() async {
    if (_locked || widget.loading || widget.onPressed == null) return;
    if (widget.debounce > Duration.zero) setState(() => _locked = true);
    try {
      widget.onPressed!.call();
    } finally {
      if (mounted && widget.debounce > Duration.zero) {
        await Future.delayed(widget.debounce);
        if (mounted) setState(() => _locked = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1) 라벨 (i18n 기본)
    final String labelText = widget.labelIsKey ? widget.label.tr() : widget.label;

    // 2) variant + destructive에 따른 기본 색상 결정 (simple_colors.dart 사용)
    final bool d = widget.destructive;
    final Color bg = switch (widget.variant) {
      BaseBtnVariant.filled   => d ? context.btnDestructiveBg : context.btnPrimaryBg,
      BaseBtnVariant.tonal    => d ? context.btnDestructiveBg : context.btnTonalBg,
      BaseBtnVariant.outlined => Colors.transparent,
      BaseBtnVariant.text     => Colors.transparent,
    };
    final Color fg = switch (widget.variant) {
      BaseBtnVariant.filled   => d ? context.btnOnDestructive : context.btnOnPrimary,
      BaseBtnVariant.tonal    => d ? context.btnOnDestructive : context.btnOnTonal,
      BaseBtnVariant.outlined => d ? context.btnDestructiveBg : context.btnTextFg,
      BaseBtnVariant.text     => d ? context.btnDestructiveBg : context.btnTextFg,
    };
    final BorderSide? side = switch (widget.variant) {
      BaseBtnVariant.outlined => BorderSide(color: d ? context.btnDestructiveBg : context.btnOutlinedBorder),
      _ => null,
    };

    // 3) 공통 child
    final child = _BtnChild(
      label: labelText,
      style: _textStyle.copyWith(color: fg),
      loading: widget.loading,
      leadingIcon: widget.leadingIcon,
      trailingIcon: widget.trailingIcon,
      progressColor: fg, // 로딩 인디케이터 색도 전경색에 맞춤
    );

    // 4) 기본 스타일 + 사용자 오버라이드 merge
    final base = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(widget.fullWidth ? double.infinity : 0, _height)),
      padding: WidgetStatePropertyAll(_padding),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      foregroundColor: WidgetStatePropertyAll(fg),
      backgroundColor: WidgetStatePropertyAll(bg),
      side: side != null ? WidgetStatePropertyAll(side) : null,
    );
    final style = (widget.styleOverride ?? const ButtonStyle()).merge(base);

    // 5) 로딩 중엔 비활성
    final onPressed = (widget.onPressed == null || widget.loading) ? null : _handlePressed;

    // 6) variant에 맞는 실제 버튼
    return switch (widget.variant) {
      BaseBtnVariant.filled   => FilledButton(style: style, onPressed: onPressed, child: child),
      BaseBtnVariant.tonal    => FilledButton.tonal(style: style, onPressed: onPressed, child: child),
      BaseBtnVariant.outlined => OutlinedButton(style: style, onPressed: onPressed, child: child),
      BaseBtnVariant.text     => TextButton(style: style, onPressed: onPressed, child: child),
    };
  }
}

class _BtnChild extends StatelessWidget {
  final String label;
  final TextStyle style;
  final bool loading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color progressColor;

  const _BtnChild({
    required this.label,
    required this.style,
    required this.loading,
    this.leadingIcon,
    this.trailingIcon,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(width: 10),
          Text(label, style: style),
        ],
      );
    }

    final kids = <Widget>[
      if (leadingIcon != null) ...[Icon(leadingIcon, size: 20, color: style.color), const SizedBox(width: 8)],
      Flexible(child: Text(label, style: style, overflow: TextOverflow.ellipsis)),
      if (trailingIcon != null) ...[const SizedBox(width: 8), Icon(trailingIcon, size: 20, color: style.color)],
    ];

    return Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: kids);
  }
}
