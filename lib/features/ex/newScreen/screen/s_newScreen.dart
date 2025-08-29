import 'package:flutter/material.dart';
import 'package:test_app/features/ex/newScreen/fragments/f_newScreen.dart';
import 'package:test_app/shared/layout/app_page.dart';
import 'package:test_app/core/common.dart';


/// 스크린은 '레이아웃'만: AppPage + Fragment 조합
class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'title.new_screen'.tr(),        // AppBar: 햄버거/뒤로가기 자동
      actions: [
        IconButton(
          tooltip: 'refresh'.tr(),
          icon: const Icon(Icons.refresh),
          onPressed: () {
            // TODO: 새로고침/리로드
          },
        ),
      ],
      // 필요 시 AppBar에 탭/검색 붙이려면 bottom: PreferredSize(...) 전달
      // bottom: PreferredSize(preferredSize: Size.fromHeight(56), child: ...),

      // 배경/패딩은 AppPage 기본값 사용. 바꾸려면 backgroundColor/padding 전달
      child: const NewScreenFragments(),
      // fab: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }
}
