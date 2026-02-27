/// 숫자/비율 포맷 유틸 (히트맵 등 공통 사용)
class FormatUtils {
  FormatUtils._();

  /// 큰 숫자를 축약 형식으로 변환 (574090 → 57.4만)
  static String formatVolume(double volume) {
    if (volume >= 10000) {
      final man = volume / 10000;
      if (man >= 100) {
        return '${man.toInt()}만';
      }
      return '${man.toStringAsFixed(1)}만';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}천';
    }
    return '${volume.toInt()}';
  }

  /// 변화율 표시 문자열 (▲/▼ 대신 +/-, % 표시)
  static String formatChangeRate(double rate) {
    if (rate > 0) return '+${rate.toStringAsFixed(1)}%';
    if (rate < 0) return '-${rate.abs().toStringAsFixed(1)}%';
    return '0.0%';
  }
}
