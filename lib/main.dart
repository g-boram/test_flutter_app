import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';

import 'app.dart';
import 'core/data/preference/app_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await AppPreferences.init();

  if (Platform.isAndroid) {
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = "MyApp"; // 갤러리 가상 폴더명
  }

  runApp(EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')],
      fallbackLocale: const Locale('en'),
      path: 'assets/translations',
      useOnlyLangCode: true,
      child: const App()));
}


/// EasyLocalization로 감싼 뒤 App 실행.
/// supportedLocales: [en, ko], fallback: en, path: assets/translations(키 기반 번역 파일 경로).