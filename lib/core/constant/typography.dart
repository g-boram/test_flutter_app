import 'package:flutter/material.dart';

/// 크기 토큰
enum TxtSize { xs, sm, md, lg, xl, display }

/// 두께(가중치) 토큰
enum TxtWeight { regular, medium, semibold, bold, extrabold }

class TTypography {
  /// 폰트 사이즈(px)
  static const Map<TxtSize, double> sizes = {
    TxtSize.xs: 12,
    TxtSize.sm: 14,
    TxtSize.md: 16,
    TxtSize.lg: 18,
    TxtSize.xl: 22,
    TxtSize.display: 42,
  };

  /// 라인높이(배수) — 필요 시 여기서 통일 조정
  static const Map<TxtSize, double> lineHeights = {
    TxtSize.xs: 1.35,
    TxtSize.sm: 1.35,
    TxtSize.md: 1.35,
    TxtSize.lg: 1.35,
    TxtSize.xl: 1.25,
    TxtSize.display: 1.15,
  };

  /// 폰트웨이트 매핑
  static const Map<TxtWeight, FontWeight> weights = {
    TxtWeight.regular: FontWeight.w400,
    TxtWeight.medium: FontWeight.w500,
    TxtWeight.semibold: FontWeight.w600,
    TxtWeight.bold: FontWeight.w700,
    TxtWeight.extrabold: FontWeight.w800,
  };
}
