import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:test_app/features/main/fragments/f_home.dart';
import 'package:test_app/shared/layout/app_page.dart';
import 'package:test_app/core/common.dart';


/// 스크린은 레이아웃 전용: AppPage + Fragment 조합
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return AppPage(
      title: 'title.home'.tr(), // AppBar: 루트면 햄버거, push면 뒤로가기 자동 처리
      actions: [
        IconButton(
          tooltip: 'refresh'.tr(),
          icon: const Icon(Icons.refresh),
          onPressed: () {
            // TODO: 필요시 새로고침
          },
        ),
      ],
      child: ListView(
        children: const [
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: HomeActionsFragment(),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
