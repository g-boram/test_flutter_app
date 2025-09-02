import 'package:flutter/material.dart';
import '../../../../shared/widgets/buttons/w_base_button.dart';
import '../../../shared/widgets/primitives/w_gap.dart';

/// 영상 녹화 컨트롤(⏺ 시작 / ⏹ 종료)
class FVideoControls extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const FVideoControls({
    super.key,
    required this.isRecording,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: BaseButton(
          label: '⏺ 영상 시작',
          onPressed: isRecording ? null : onStart,
        ),
      ),
      const WGap.w(8),
      Expanded(
        child: BaseButton(
          label: '⏹ 영상 종료',
          onPressed: isRecording ? onStop : null,
        ),
      ),
    ]);
  }
}
