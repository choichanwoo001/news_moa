import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import '../config/api_config.dart';

class ApiService {
  // 싱글톤
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  static Duration get _timeout => const Duration(seconds: 60);

  // ─── 히트맵 전체 데이터 ───────────────────────────

  /// 전체 섹터 히트맵 데이터 로드 (캐시 자동 활용됨)
  Future<HeatmapData> fetchHeatmapData({String market = 'KR'}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news/heatmap?market=$market');
    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return HeatmapData.fromJson(json);
      } else {
        throw ApiException('히트맵 데이터 로드 실패 (${response.statusCode})');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('서버에 연결할 수 없습니다: $e');
    }
  }

  // ─── 섹터별 뉴스 ──────────────────────────────────

  /// 특정 섹터의 뉴스 목록 로드 (페이지네이션 지원)
  Future<SectorNewsResult> fetchSectorNews(String sectorId, {int page = 1}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news/sector/$sectorId?page=$page');
    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return SectorNewsResult.fromJson(json);
      } else if (response.statusCode == 404) {
        throw ApiException('알 수 없는 섹터: $sectorId');
      } else {
        throw ApiException('뉴스 로드 실패 (${response.statusCode})');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('서버에 연결할 수 없습니다: $e');
    }
  }

  // ─── 캐시 강제 갱신 (관리용) ──────────────────────

  Future<void> refreshCache() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/cache/refresh');
    try {
      await http.post(uri).timeout(_timeout);
    } catch (_) {
      // 백그라운드 작업이므로 에러 무시
    }
  }
}

/// API 호출 오류 클래스
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}
