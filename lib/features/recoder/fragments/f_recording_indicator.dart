// lib/features/recoder/fragments/f_recording_indicator.dart
import 'package:flutter/material.dart';

class FRecordingIndicator extends StatelessWidget {
  const FRecordingIndicator({
    super.key,
    required this.elapsed,
    required this.level,
  });

  final Duration elapsed; // 녹음 경과 시간
  final double level;     // 0.0 ~ 1.0 (음압 레벨)

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // 빨간 점 애니메이션
          _BlinkingDot(color: color),
          const SizedBox(width: 8),
          Text(
            _fmt(elapsed),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 16),
          // 레벨 바
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: level.clamp(0.0, 1.0),
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot({required this.color});
  final Color color;

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}
