// features/main/fragments/f_favorite.dart
import 'package:flutter/material.dart';
import 'package:test_app/core/common.dart';
import 'package:test_app/features/main/screen/s_home.dart';
import 'package:test_app/shared/widgets/round_button_theme.dart';
import 'package:test_app/shared/widgets/w_round_button.dart';

import 'package:test_app/features/main/screen/s_main.dart'; // 필요 시 MainScreen 네비 API 사용

class FavoriteFragment extends StatelessWidget {
  const FavoriteFragment({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Scaffold/SafeArea/BackButton 없음 — 화면 레이아웃은 Screen(AppPage)이 담당
    return Container(
      color: context.appColors.seedColor.getMaterialColorValues[100],
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundButton(
            text: '홈 화면 이동',
            theme: RoundButtonTheme.blue,
            onTap: () {

            },
          ),
        ],
      ),
    );
  }
}
