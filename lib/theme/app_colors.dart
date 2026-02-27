import 'package:flutter/material.dart';

class AppColors {
  // ─── Background & Surface (Deep Dark Theme) ───────────────
  static const Color background = Color(0xFF000000);      // 완전한 블랙 배경
  static const Color surface = Color(0xFF0E1117);          // 딥 차콜 서페이스
  static const Color surfaceElevated = Color(0xFF111827);  // 살짝 올라온 서페이스
  static const Color surfaceHighlight = Color(0xFF1F2933); // 인터랙션/보더용 차분한 딥 그레이

  // ─── Text Colors (검은 배경 대비 확보) ────────────────────
  static const Color textPrimary = Color(0xFFF9FAFB);   // 거의 화이트
  static const Color textSecondary = Color(0xFFB0B8C4);  // 밝은 그레이 (가독성)
  static const Color textTertiary = Color(0xFF8B92A0);   // 보조 텍스트도 어두운 배경에서 식별 가능
  static const Color divider = Color(0xFF1F2933);        // 은은한 구분선

  // ─── Accent & Brand (검은 배경에서도 잘 보이는 밝은 톤) ─────
  static const Color primary = Color(0xFF818CF8);        // 인디고 (대비 확보)
  static const Color accent = Color(0xFFEC4899);         // 살짝 톤다운된 핑크 액센트
  static const Color neonGlow = Color(0xFFA5B4FC);       // 밝은 인디고 (텍스트/강조용)

  // ─── Tab Bar (primary 인디고 톤, 검은 배경에서 선명하게) ───
  static const Color tabSelectedBg = Color(0xFF1E1B36);   // 선택 탭 배경 (딥 인디고)
  static const Color tabSelectedBorder = Color(0xFF4F46B8); // 선택 탭 테두리 (더 선명)
  static const Color tabSelectedText = Color(0xFFA5B4FC);  // neonGlow와 동일 (잘 보이는 인디고)
  static const Color tabUnselectedText = Color(0xFFB0B8C4); // 비선택 = textSecondary 톤

  // ─── Semantic Colors ──────────────────────────────────────
  static const Color positive = Color(0xFF10B981);       // 톤다운된 에메랄드
  static const Color negative = Color(0xFFEF4444);       // 차분한 레드
  static const Color warning = Color(0xFFF59E0B);        // 톤다운된 앰버

  // ─── Heatmap Colors (검은/어두운 배경에서 잘 보이게) ───────
  static const Color heatHigh = Color(0xFFB91C1C);        // 강한 상승 → 딥 레드
  static const Color heatMediumHigh = Color(0xFFEF4444);  // 상승 → 레드
  static const Color heatMediumLow = Color(0xFF60A5FA);  // 하락 → 밝은 블루
  static const Color heatLow = Color(0xFF3B82F6);        // 강한 하락 → 블루 (선명)
  static const Color heatLowest = Color(0xFF6B7280);     // 중립 → 그레이 (대비 확보)

  // ─── 감성 기반 히트맵 색상 ────────────────────────────────
  /// 상승(+, 양수)은 레드 계열, 하락(-, 음수)은 블루 계열로 매핑
  static Color getColorForChangeRate(double changeRate) {
    if (changeRate >= 3.0) return heatHigh;                      // 강한 상승 → 딥 레드
    if (changeRate >= 1.0) return heatMediumHigh;                // 상승 → 레드
    if (changeRate > -1.0) return heatLowest;                    // 거의 변동 없음 → 그레이 톤
    if (changeRate > -3.0) return heatMediumLow;                 // 하락 → 블루
    return heatLow;                                              // 강한 하락 → 딥 블루
  }

  // ─── 볼륨 기반 색상 ──────────────────────────────────────
  static Color getColorForVolume(double volume) {
    if (volume >= 90) return heatHigh;
    if (volume >= 70) return heatMediumHigh;
    if (volume >= 30) return heatLow;
    return heatLowest;
  }

  // ─── 섹터별 고유 색상 ────────────────────────────────────
  static Color getSectorColor(String sectorName) {
    if (sectorName.contains("반도체")) return heatHigh;
    if (sectorName.contains("2차전지")) return heatMediumHigh;
    if (sectorName.contains("바이오") || sectorName.contains("자동차")) return heatMediumLow;
    if (sectorName.contains("IT") || sectorName.contains("SW")) return heatLow;
    if (sectorName.contains("금융") || sectorName.contains("건설") || sectorName.contains("유통")) return heatLowest;
    return textSecondary;
  }
}
