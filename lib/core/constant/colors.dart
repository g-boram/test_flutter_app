import 'package:flutter/material.dart';
import 'package:test_app/core/constant/palette.dart';


/// 아주 간단 색상 모음: context.XXX 형태로 바로 호출
extension AppColorsX on BuildContext {
  ColorScheme get _cs => Theme.of(this).colorScheme;
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  // ───────── Base (배경/텍스트/경계) ─────────
  Color get baseBg => _cs.background;
  Color get baseOnBg => _cs.onBackground;
  Color get baseSurface => _cs.surface;
  Color get baseOnSurface => _cs.onSurface;
  Color get baseSurfaceVariant => _cs.surfaceVariant;
  Color get baseOnSurfaceVariant => _cs.onSurfaceVariant;
  Color get baseOutline => _cs.outline;

  // ───────── Input (TextField/폼) ─────────
  Color get inputFill => _cs.surfaceVariant.withOpacity(_isDark ? .20 : .35);
  Color get inputBorder => _cs.outline;
  Color get inputFocusedBorder => _cs.primary;
  Color get inputFocusRing => _cs.primary.withOpacity(.25);
  Color get inputPlaceholder => _cs.onSurfaceVariant.withOpacity(.8);
  Color get inputLabel => _cs.onSurfaceVariant;

  // ───────── Button (Primary/Tonal/Outlined/Text/Destructive) ─────────
  Color get btnPrimaryBg => _cs.primary;
  Color get btnOnPrimary => _cs.onPrimary;
  Color get btnTonalBg => _cs.secondaryContainer;
  Color get btnOnTonal => _cs.onSecondaryContainer;
  Color get btnOutlinedBorder => _cs.outline;
  Color get btnTextFg => _cs.primary;
  Color get btnDestructiveBg => _cs.error;
  Color get btnOnDestructive => _cs.onError;

  // ───────── Status (성공/경고/정보) ─────────
  Color get statusSuccess => AppPalette.success;
  Color get statusWarning => AppPalette.warning;
  Color get statusInfo    => AppPalette.info;

  // 컨테이너 톤(배경으로 깔 때): 아주 가볍게 투명도만
  Color get statusSuccessContainer => AppPalette.success.withOpacity(_isDark ? .28 : .14);
  Color get statusWarningContainer => AppPalette.warning.withOpacity(_isDark ? .26 : .16);
  Color get statusInfoContainer    => AppPalette.info.withOpacity(_isDark ? .28 : .14);

  // 컨테이너 위 글자색(간단히 대비만 맞춤)
  Color get onStatusSuccessContainer => Colors.white;
  Color get onStatusWarningContainer => Colors.black;
  Color get onStatusInfoContainer    => Colors.white;
}
