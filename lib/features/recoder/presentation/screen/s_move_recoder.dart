import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:test_app/shared/layout/app_page.dart';
import 'package:test_app/shared/widgets/buttons/w_base_button.dart';
import 'package:test_app/shared/widgets/primitives/w_gap.dart';

import 'package:test_app/features/recoder/presentation/screen/s_camera_test.dart';
import 'package:test_app/features/recoder/presentation/screen/s_video_test.dart';
import 'package:test_app/features/recoder/presentation/screen/s_mic_test.dart';


class MoveRecoderScreen extends StatelessWidget {
  const MoveRecoderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return AppPage(
      title: 'title.recoder'.tr(), // 혹시 키가 'recorder'가 맞는지도 한번 확인!
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: BaseButton(
                  label: '사진 촬영 테스트 페이지',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CameraTestScreen()),
                  ),
                ),
              ),
            ],
          ),
          const WGap.h(15),
          Row(
            children: [
              Expanded(
                child: BaseButton(
                  label: '동영상 촬영 테스트 페이지',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VideoTestScreen()),
                  ),
                ),
              ),
            ],
          ),
          const WGap.h(15),
          Row(
            children: [
              Expanded(
                child: BaseButton(
                  label: '마이크 녹음 테스트 페이지',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MicTestScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
