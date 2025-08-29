// features/main/screen/s_favorite.dart
import 'package:flutter/material.dart';
import 'package:test_app/shared/layout/app_page.dart';
import '../fragments/f_favorite.dart';
import 'package:test_app/core/common.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'title.favorite'.tr(),
      // actions: [ ... ], // 필요 시 AppBar 우측 액션 추가
      child: const FavoriteFragment(), // ⬅ 본문은 Fragment가 담당
    );
  }
}
