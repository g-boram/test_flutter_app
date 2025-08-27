import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// 카메라 프리뷰를 가로 폭에 맞추고, 높이는 maxHeight를 넘지 않도록 제한.
/// 화면 오버플로 방지용.
class WCameraBox extends StatelessWidget {
  final CameraController controller;
  final double maxHeight; // 예: 320~400 권장
  const WCameraBox({super.key, required this.controller, this.maxHeight = 360});

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final ar = controller.value.aspectRatio == 0 ? 1.0 : controller.value.aspectRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final idealHeight = width / ar;
        final height = math.min(idealHeight, maxHeight);

        return Center(
          child: SizedBox(
            height: height,
            child: AspectRatio(
              aspectRatio: ar,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }
}
