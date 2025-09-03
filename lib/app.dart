// lib/app.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// 팔레트 기반 테마
import 'package:test_app/core/theme/app_theme.dart';

import 'features/home/screen/s_home.dart';

class KioskApp extends StatelessWidget {
  const KioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 런타임에 다국어로 앱 타이틀 갱신
      onGenerateTitle: (_) => 'app.title'.tr(),
      debugShowCheckedModeBanner: false,

      // === i18n 연결 (main.dart에서 EasyLocalization로 감싼 상태) ===
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      // === 테마(팔레트 기반) ===
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light, // 교실 환경이면 보통 Light 권장 (필요 시 system/다크로 변경)

      // 스크롤 글로우 제거(키오스크 느낌)
      scrollBehavior: const _NoGlowScrollBehavior(),

      home: const HomeScreen(),
    );
  }
}

// -------------------- UTILS --------------------
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) {
    return child; // 글로우 제거
  }
}
