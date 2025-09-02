import 'package:flutter/material.dart';
import 'package:test_app/shared/widgets/buttons/w_base_button.dart';
import 'package:test_app/shared/widgets/primitives/w_gap.dart';

import 'package:test_app/features/recoder/presentation/screen/s_camera_test.dart';
import 'package:test_app/features/recoder/presentation/screen/s_video_test.dart';
import 'package:test_app/features/recoder/presentation/screen/s_mic_test.dart';
import 'package:test_app/shared/widgets/typography/w_base_text.dart';

/// Scaffold/AppBar 없이 '본문'만 그리는 프래그먼트
class HomeActionsFragment extends StatelessWidget {
  const HomeActionsFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: BaseText('title.home'),
    );
  }
}
