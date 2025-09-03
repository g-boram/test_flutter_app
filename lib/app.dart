// lib/app.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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

      // === 테마 ===
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.light, // 교실 환경이면 보통 Light 권장

      // 스크롤 글로우 제거(키오스크 느낌)
      scrollBehavior: const _NoGlowScrollBehavior(),

      home: const HomeScreen(),
    );
  }
}

// -------------------- THEME --------------------
final _lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  visualDensity: VisualDensity.comfortable,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
    headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontSize: 20),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
  ),
);

final _darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.dark,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
    headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontSize: 20),
  ),
);

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
