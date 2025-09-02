import 'package:flutter/material.dart';
import 'package:test_app/features/example/newScreen/fragments/f_newScreen.dart';
import 'package:test_app/shared/layout/app_page.dart';
import 'package:test_app/core/common.dart';


class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return AppPage(
      title: 'title.new_screen'.tr(),
      actions: [
        IconButton(
          tooltip: 'refresh'.tr(),
          icon: const Icon(Icons.refresh),
          onPressed: () {},
        ),
      ],
      // 프레그먼트(기능) 조각들을 import해서 구현
      child: const NewScreenFragments(),
    );
  }
}
