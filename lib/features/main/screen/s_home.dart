import 'package:flutter/material.dart';
import 'package:test_app/features/recoder/presentation/screen/s_video_test.dart';

import '../../../../shared/widgets/buttons/w_primary_button.dart';
import '../../../../shared/widgets/w_gap.dart';

import 'package:test_app/features/recoder/presentation/screen/s_camera_test.dart';
import 'package:test_app/features/recoder/presentation/screen/s_mic_test.dart';

class SHome extends StatefulWidget {
  const SHome({super.key});

  @override
  State<SHome> createState() => _SHomeState();
}

class _SHomeState extends State<SHome> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Expanded(
            child: WPrimaryButton(
              label: '사진 촬영 테스트 페이지',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraTestScreen()),
              ),
            ),
          ),
        ]),
        const WGap.h(15),
        Row(children: [
          Expanded(
            child: WPrimaryButton(
              label: '동영상 촬영 테스트 페이지',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VideoTestScreen()),
              ),
            ),
          ),
        ]),
        const WGap.h(15),
        Row(children: [
          Expanded(
            child: WPrimaryButton(
              label: '마이크 녹음 테스트 페이지',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MicTestScreen()),
              ),
            ),
          ),
        ])
      ],
    );
  }
}

