import 'package:flutter/material.dart';
import 'package:test_app/features/home/fragments/f_home.dart';
import 'package:test_app/shared/layout/l_feature_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureLayout(
      titleKey: 'home.title',          // 상단 타이틀
      child: const HomeFragment(),    // 본문
    );
  }
}
