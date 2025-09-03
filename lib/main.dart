import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // 시스템 UI 최소화(키오스크 몰입)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 세로고정 변경 가능
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // 기본 세로
    // DeviceOrientation.portraitDown, // 180도도 허용하려면 이 줄 추가
  ]);

  // 화면 꺼짐 방지
  await WakelockPlus.enable();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ko'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ko'),
      child: const KioskApp(), // ← MaterialApp은 app.dart에서
    ),
  );
}
