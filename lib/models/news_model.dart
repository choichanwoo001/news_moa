/// 네이버 API 응답 기반 Flutter 데이터 모델
library;

// ─── 리스트 파싱 헬퍼 (null / 비리스트 시 빈 리스트 반환) ──
List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is! List) return [];
  return value
      .map((e) => e?.toString() ?? '')
      .where((s) => s.isNotEmpty)
      .toList();
}

// ─── 뉴스 기사 ───────────────────────────────────
class NewsArticle {
  final String title;
  final String link;
  final String description;
  final String pubDate;
  final String source;
  final String? originalLink;
  final List<String> relatedCompanies;
  final String? classificationReason;
  final String? summary;  // AI 생성 요약 (1-2문장)

  const NewsArticle({
    required this.title,
    required this.link,
    required this.description,
    required this.pubDate,
    required this.source,
    this.originalLink,
    this.relatedCompanies = const [],
    this.classificationReason,
    this.summary,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title:        json['title']       as String? ?? '',
      link:         json['link']        as String? ?? '',
      description:  json['description'] as String? ?? '',
      pubDate:      json['pubDate']     as String? ?? '',
      source:       json['source']      as String? ?? 'Naver',
      originalLink: json['original_link'] as String?,
      relatedCompanies: _parseStringList(json['related_companies']),
      classificationReason: json['ai_classification_reason'] as String?,
      summary:      json['summary'] as String?,
    );
  }

  /// 표시용 요약: AI 요약이 있으면 사용, 없으면 description
  String get displaySummary {
    if (summary != null && summary!.isNotEmpty) return summary!;
    return description;
  }

  /// pubDate에서 추출한 시간 문자열 (HH:mm). 파싱 실패 시 빈 문자열
  String get displayTime {
    try {
      final parts = pubDate.split(' ');
      if (parts.length >= 5) return parts[4].substring(0, 5);
    } catch (_) {}
    return '';
  }

  /// pubDate에서 추출한 날짜 문자열 (e.g. "26 Feb 2025"). 파싱 실패 시 빈 문자열
  String get displayDate {
    try {
      final parts = pubDate.split(' ');
      if (parts.length >= 5) return '${parts[1]} ${parts[2]} ${parts[3]}';
    } catch (_) {}
    return '';
  }
}

// ─── 섹터별 뉴스 결과 ─────────────────────────────
class SectorNewsResult {
  final String sectorId;
  final String sectorName;
  final String categoryId;
  final String categoryName;
  final List<NewsArticle> articles;
  final double newsVolume;   // 히트맵 크기
  final double changeRate;   // 히트맵 색상 (-5 ~ +5)
  final String? cachedAt;
  final String? sectorBriefing;  // AI 생성 섹터 한 줄 브리핑
  final List<String> risingKeywords;  // 섹터 내 급상승 키워드

  const SectorNewsResult({
    required this.sectorId,
    required this.sectorName,
    required this.categoryId,
    required this.categoryName,
    required this.articles,
    required this.newsVolume,
    required this.changeRate,
    this.cachedAt,
    this.sectorBriefing,
    this.risingKeywords = const [],
  });

  factory SectorNewsResult.fromJson(Map<String, dynamic> json) {
    final rawArticles = json['articles'] as List<dynamic>? ?? [];
    return SectorNewsResult(
      sectorId:     json['sector_id']    as String? ?? '',
      sectorName:   json['sector_name']  as String? ?? '',
      categoryId:   json['category_id']  as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      articles:     rawArticles.map((e) => NewsArticle.fromJson(e as Map<String, dynamic>)).toList(),
      newsVolume:   (json['news_volume'] as num?)?.toDouble() ?? 0.0,
      changeRate:   (json['change_rate'] as num?)?.toDouble() ?? 0.0,
      cachedAt:     json['cached_at'] as String?,
      sectorBriefing: json['sector_briefing'] as String?,
      risingKeywords: _parseStringList(json['rising_keywords']),
    );
  }
}

// ─── 카테고리 (상위) ──────────────────────────────
class CategoryHeatmap {
  final String categoryId;
  final String categoryName;
  final List<SectorNewsResult> subSectors;
  final double totalVolume;
  final double avgChangeRate;

  const CategoryHeatmap({
    required this.categoryId,
    required this.categoryName,
    required this.subSectors,
    required this.totalVolume,
    required this.avgChangeRate,
  });

  factory CategoryHeatmap.fromJson(Map<String, dynamic> json) {
    final rawSubs = json['sub_sectors'] as List<dynamic>? ?? [];
    return CategoryHeatmap(
      categoryId:    json['category_id']    as String? ?? '',
      categoryName:  json['category_name']  as String? ?? '',
      subSectors:    rawSubs.map((e) => SectorNewsResult.fromJson(e as Map<String, dynamic>)).toList(),
      totalVolume:   (json['total_volume']    as num?)?.toDouble() ?? 0.0,
      avgChangeRate: (json['avg_change_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ─── 히트맵 전체 응답 ─────────────────────────────
class HeatmapData {
  final String market;
  final String updatedAt;
  final List<CategoryHeatmap> categories;

  const HeatmapData({
    required this.market,
    required this.updatedAt,
    required this.categories,
  });

  factory HeatmapData.fromJson(Map<String, dynamic> json) {
    final rawCats = json['categories'] as List<dynamic>? ?? [];
    return HeatmapData(
      market:     json['market']     as String? ?? 'KR',
      updatedAt:  json['updated_at'] as String? ?? '',
      categories: rawCats.map((e) => CategoryHeatmap.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
