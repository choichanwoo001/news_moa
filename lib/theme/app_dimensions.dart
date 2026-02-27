import 'package:flutter/material.dart';

/// rem 기반 스페이싱/폰트 크기 상수 (1rem = 16px)
class AppDimensions {
  AppDimensions._();

  static const double remBase = 16.0;

  /// rem 값을 픽셀로 (예: rem(1) => 16, rem(0.875) => 14)
  static double rem(double value) => value * remBase;

  // ─── Spacing ────────────────────────────────────────
  static const double spacingXs = 4;   // 0.25rem
  static const double spacingSm = 8;   // 0.5rem
  static const double spacingMd = 16;  // 1rem
  static const double spacingLg = 24; // 1.5rem
  static const double spacingXl = 32;  // 2rem

  // ─── Font size ─────────────────────────────────────
  static const double fontSizeXs = 9;   // 0.5625rem
  static const double fontSizeSm = 11;  // 0.6875rem
  static const double fontSizeMd = 14;  // 0.875rem
  static const double fontSizeLg = 15;  // 0.9375rem
  static const double fontSizeXl = 17;  // 1.0625rem
  static const double fontSizeTitle = 26; // 1.625rem

  // ─── Border radius ──────────────────────────────────
  static const double radiusSm = 5;   // 0.3125rem
  static const double radiusMd = 12;  // 0.75rem
  static const double radiusLg = 14;  // 0.875rem
  static const double radiusXl = 24;  // 1.5rem
}
