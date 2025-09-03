import 'dart:async';
import 'package:flutter/material.dart';

enum BaseBtnVariant { filled, tonal, outlined, text }
enum BaseBtnSize { sm, md, lg }

class BaseButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  final BaseBtnVariant variant;
  final BaseBtnSize size;
  final bool fullWidth;
  final bool loading;

  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// 빠른 연타 방지 (0이면 비활성)
  final Duration debounce;

  /// 버튼 스타일 커스터마이즈 (shape, padding, 색상 등)
  final ButtonStyle? styleOverride;

  const BaseButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BaseBtnVariant.filled,
    this.size = BaseBtnSize.md,
    this.fullWidth = true,
    this.loading = false,
    this.leadingIcon,
    this.trailingIcon,
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
    if (widget.debounce > Duration.zero) {
      setState(() => _locked = true);
    }
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
    final child = _BtnChild(
      label: widget.label,
      style: _textStyle,
      loading: widget.loading,
      leadingIcon: widget.leadingIcon,
      trailingIcon: widget.trailingIcon,
    );

    final style = (widget.styleOverride ?? const ButtonStyle()).merge(
      ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(widget.fullWidth ? double.infinity : 0, _height)),
        padding: WidgetStatePropertyAll(_padding),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );

    final onPressed = (widget.onPressed == null) ? null : _handlePressed;

    return switch (widget.variant) {
      BaseBtnVariant.filled => FilledButton(style: style, onPressed: onPressed, child: child),
      BaseBtnVariant.tonal => FilledButton.tonal(style: style, onPressed: onPressed, child: child),
      BaseBtnVariant.outlined => OutlinedButton(style: style, onPressed: onPressed, child: child),
      BaseBtnVariant.text => TextButton(style: style, onPressed: onPressed, child: child),
    };
  }
}

class _BtnChild extends StatelessWidget {
  final String label;
  final TextStyle style;
  final bool loading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const _BtnChild({
    required this.label,
    required this.style,
    required this.loading,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Text(label, style: style),
        ],
      );
    }

    final kids = <Widget>[
      if (leadingIcon != null) ...[Icon(leadingIcon, size: 20), const SizedBox(width: 8)],
      Flexible(child: Text(label, style: style, overflow: TextOverflow.ellipsis)),
      if (trailingIcon != null) ...[const SizedBox(width: 8), Icon(trailingIcon, size: 20)],
    ];

    return Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: kids);
  }
}
