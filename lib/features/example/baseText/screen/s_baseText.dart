import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:test_app/features/example/baseText/fragments/f_baseText.dart';
import 'package:test_app/shared/layout/app_page.dart';

class BaseTextScreen extends StatelessWidget {
  const BaseTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return AppPage(
      title: 'title.baseText'.tr(),
      actions: [
        IconButton(
          tooltip: 'refresh'.tr(),
          icon: const Icon(Icons.refresh),
          onPressed: () {},
        ),
      ],
      child: const BaseTextShowcase(),
    );
  }
}
