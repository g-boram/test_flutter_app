import 'package:flutter/material.dart';

/// 앱 전역 색 팔레트 (블루 베이스)
/// - 브랜드: 파란색 계열 중심
/// - 세만틱: 성공/경고/정보/에러
/// - Light/Dark ColorScheme 포함
class AppPalette {
  // ── Brand (원하면 여기 값만 갈아끼우면 전역 테마 색감이 바뀜)
  // Tailwind 느낌의 안정적인 톤 조합
  static const Color brandPrimary   = Color(0xFF2563EB); // Blue 600
  static const Color brandSecondary = Color(0xFF6366F1); // Indigo 500
  static const Color brandTertiary  = Color(0xFF06B6D4); // Cyan 500

  // ── Semantic
  static const Color success = Color(0xFF22C55E); // Green 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info    = Color(0xFF0EA5E9); // Sky 500
  static const Color error   = Color(0xFFB3261E); // M3 기본 톤 (명시적 에러)

  // ── Light ColorScheme (Material 3 키 위주)
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary
    primary: brandPrimary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDBEAFE),      // Blue 100
    onPrimaryContainer: Color(0xFF0B255F),

    // Secondary
    secondary: brandSecondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE0E7FF),   // Indigo 100
    onSecondaryContainer: Color(0xFF1E1B4B),

    // Tertiary
    tertiary: brandTertiary,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFCFFAFE),    // Cyan 100
    onTertiaryContainer: Color(0xFF083344),

    // Error
    error: error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),

    // Surfaces
    surface: Colors.white,
    onSurface: Color(0xFF1C1B1F),
    surfaceVariant: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),

    // Etc
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFF9DB8FF),

    background: Color(0xFFF7F9FC),
    onBackground: Color(0xFF1C1B1F),
  );

  // ── Dark ColorScheme
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary
    primary: Color(0xFF93C5FD),              // Blue 300
    onPrimary: Color(0xFF0B255F),
    primaryContainer: Color(0xFF1E3A8A),     // Blue 800
    onPrimaryContainer: Colors.white,

    // Secondary
    secondary: Color(0xFFC7BFFF),            // 인디고의 밝은 톤
    onSecondary: Color(0xFF1E1B4B),
    secondaryContainer: Color(0xFF3730A3),   // Indigo 800
    onSecondaryContainer: Colors.white,

    // Tertiary
    tertiary: Color(0xFFA5F3FC),             // Cyan 200
    onTertiary: Color(0xFF083344),
    tertiaryContainer: Color(0xFF155E75),    // Cyan 800-ish
    onTertiaryContainer: Colors.white,

    // Error
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Colors.white,

    // Surfaces
    surface: Color(0xFF111318),
    onSurface: Color(0xFFE6E1E5),
    surfaceVariant: Color(0xFF49454F),
    onSurfaceVariant: Color(0xFFCAC4D0),

    // Etc
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    shadow: Colors.black,
    scrim: Colors.black87,
    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF1C1B1F),
    inversePrimary: brandPrimary,

    background: Color(0xFF0F1116),
    onBackground: Color(0xFFE6E1E5),
  );
}
