import 'package:flutter/material.dart';

/// 이 파일의 값만 바꾸면 앱 전역 색이 바뀜
class AppPalette {
  // 브랜드 핵심 컬러 (원하는 값으로 교체)
  static const Color brandPrimary   = Color(0xFF3E7BFA);
  static const Color brandSecondary = Color(0xFF6C5CE7);
  static const Color brandTertiary  = Color(0xFF00C2A8);

  // 상태/세만틱
  static const Color success = Color(0xFF2BB673);
  static const Color warning = Color(0xFFFFB020);
  static const Color info    = Color(0xFF2DB7F5);

  // 에러(머티리얼 기본과 유사 톤)
  static const Color error = Color(0xFFB3261E);

  // ──────────────────────────────────────────────────────────────────
  // Light / Dark ColorScheme (필요시 값 조정)
  // 머티리얼3 가이드에 맞춰 핵심 키들만 브랜드 중심으로 세팅
  // ──────────────────────────────────────────────────────────────────
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: brandPrimary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDCE6FF),
    onPrimaryContainer: Color(0xFF0B1E66),

    secondary: brandSecondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE5E0FF),
    onSecondaryContainer: Color(0xFF231B6B),

    tertiary: brandTertiary,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFCCF5EE),
    onTertiaryContainer: Color(0xFF003A33),

    error: error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),

    surface: Colors.white,
    onSurface: Color(0xFF1C1B1F),
    surfaceVariant: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),

    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),

    shadow: Colors.black,
    scrim: Colors.black54,

    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFFB9C7FF),

    background: Color(0xFFF9F9FB),
    onBackground: Color(0xFF1C1B1F),
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB9C7FF),
    onPrimary: Color(0xFF0B1E66),
    primaryContainer: Color(0xFF2B3D8C),
    onPrimaryContainer: Colors.white,

    secondary: Color(0xFFC7BFFF),
    onSecondary: Color(0xFF231B6B),
    secondaryContainer: Color(0xFF3B317F),
    onSecondaryContainer: Colors.white,

    tertiary: Color(0xFFAAF0E5),
    onTertiary: Color(0xFF003A33),
    tertiaryContainer: Color(0xFF005047),
    onTertiaryContainer: Colors.white,

    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Colors.white,

    surface: Color(0xFF121316),
    onSurface: Color(0xFFE6E1E5),
    surfaceVariant: Color(0xFF49454F),
    onSurfaceVariant: Color(0xFFCAC4D0),

    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),

    shadow: Colors.black,
    scrim: Colors.black87,

    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF1C1B1F),
    inversePrimary: brandPrimary,

    background: Color(0xFF0F1012),
    onBackground: Color(0xFFE6E1E5),
  );
}
