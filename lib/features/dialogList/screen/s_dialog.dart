import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:test_app/core/common.dart';
import 'package:test_app/features/dialogList/fragments/f_smaple_dialogs.dart';
import 'package:test_app/shared/layout/app_page.dart';

class DialogsScreen extends StatelessWidget {
  const DialogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return AppPage(
      title: 'title.sample_dialogs'.tr(), // AppBar 제목, 뒤로가기/햄버거 자동 처리
      child: const SampleDialogsFragment(), // ← 방금 만든 프래그먼트
    );
  }
}