// lib/features/recoder/presentation/fragments/f_camera_controls.dart
import 'package:flutter/material.dart';

import '../../../../shared/widgets/buttons/w_primary_button.dart';
import '../../../../shared/widgets/w_gap.dart';

/// 카메라 조작 컨트롤 묶음(사진 촬영 / 영상 시작 / 영상 종료).
/// 상태는 가지지 않고, 부모에서 전달한 콜백만 호출합니다.
class FCameraControls extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTakePhoto;
  final VoidCallback onStartVideo;
  final VoidCallback onStopVideo;

  const FCameraControls({
    super.key,
    required this.isRecording,
    required this.onTakePhoto,
    required this.onStartVideo,
    required this.onStopVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(
            child: WPrimaryButton(
              label: '📸 사진 촬영',
              onPressed: onTakePhoto,
            ),
          ),
        ]),
        const WGap.h(8),
        Row(children: [
          Expanded(
            child: WPrimaryButton(
              label: '⏺ 영상 시작',
              onPressed: isRecording ? null : onStartVideo,
            ),
          ),
          const WGap.w(8),
          Expanded(
            child: WPrimaryButton(
              label: '⏹ 영상 종료',
              onPressed: isRecording ? onStopVideo : null,
            ),
          ),
        ]),
      ],
    );
  }
}
