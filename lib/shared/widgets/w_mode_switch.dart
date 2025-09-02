// lib/shared/widgets/mode_switch.dart
import 'package:flutter/material.dart';

class ModeSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double height;


  final Color activeThumbColor;
  final Widget? activeThumb;
  final Color inactiveThumbColor;
  final Widget? inactiveThumb;

  @Deprecated('Use activeThumb instead')
  final Image? activeThumbImage;
  @Deprecated('Use inactiveThumb instead')
  final Image? inactiveThumbImage;

  final String lightLabel;
  final String darkLabel;

  const ModeSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 30,
    this.activeThumbColor = Colors.white,
    this.activeThumb,
    this.inactiveThumbColor = Colors.white,
    this.inactiveThumb,
    this.activeThumbImage,     // ⬅️ 추가
    this.inactiveThumbImage,   // ⬅️ 추가
    this.lightLabel = 'Light',
    this.darkLabel = 'Dark',
  });

  @override
  State<ModeSwitch> createState() => _ModeSwitchState();
}

class _ModeSwitchState extends State<ModeSwitch> {
  static const _duration = Duration(milliseconds: 250);



  @override
  Widget build(BuildContext context) {
    const aspectRatio = 40 / 25;
    const activeBg = Color(0xFF00091B);
    const inactiveBg = Color(0xFF6A9EFF);

    // 새/구 API 중 우선순위: 새(activeThumb) → 구(activeThumbImage)
    final activeChild = widget.activeThumb ?? widget.activeThumbImage;
    final inactiveChild = widget.inactiveThumb ?? widget.inactiveThumbImage;

    final cs = Theme.of(context).colorScheme;
    final labelActiveColor = cs.onSurface;
    final labelInactiveColor = cs.outline;

    return InkWell(
      borderRadius: BorderRadius.circular(widget.height / 2),
      onTap: () => widget.onChanged(!widget.value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.lightLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: widget.value ? labelInactiveColor : labelActiveColor,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: widget.height,
            width: aspectRatio * widget.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: _duration,
                  decoration: BoxDecoration(
                    color: widget.value ? activeBg : inactiveBg,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
                AnimatedAlign(
                  duration: _duration,
                  alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
                  curve: Curves.easeInOut,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: widget.height * (2 / 25)),
                    child: Container(
                      height: widget.height * 0.75,
                      width: widget.height * 0.75,
                      decoration: BoxDecoration(
                        color: widget.value ? widget.activeThumbColor : widget.inactiveThumbColor,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AnimatedSwitcher(
                        duration: _duration,
                        child: widget.value
                            ? (activeChild ?? const SizedBox.shrink())
                            : (inactiveChild ?? const SizedBox.shrink()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.darkLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: widget.value ? labelActiveColor : labelInactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
