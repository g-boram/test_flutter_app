import 'package:flutter/material.dart';
import 'package:test_app/core/common.dart';
import 'package:test_app/features/main/screen/s_home.dart';      // SHome = 컨텐츠 전용
import 'package:test_app/features/main/screen/s_main.dart';      // MainScreen.of(...) 사용

class HomeFragment extends StatelessWidget {
  const HomeFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appColors.seedColor.getMaterialColorValues[100],
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => MainScreen.of(context)?.openDrawer(),
                  icon: const Icon(Icons.menu),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SHome(),
          ],
        ),
      ),
    );
  }
}
