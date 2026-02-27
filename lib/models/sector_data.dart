/// 섹터 메타데이터 (정적 정보만 유지 - 실제 데이터는 백엔드 API에서 수신)
///
/// 이 파일에는 하드코딩된 뉴스 양/변화율 데이터가 없습니다.
/// 섹터 ID, 이름, 카테고리 정보만 클라이언트 표시용으로 유지합니다.
library;

class SectorMeta {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;

  const SectorMeta({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
  });
}

/// 앱 내 섹터 메타 정보 (표시 순서 포함)
class SectorRegistry {
  static const List<SectorMeta> all = [
    // IT
    SectorMeta(id: 'IT_1', name: '반도체',       categoryId: 'IT', categoryName: 'IT'),
    SectorMeta(id: 'IT_2', name: '소프트웨어',   categoryId: 'IT', categoryName: 'IT'),
    SectorMeta(id: 'IT_3', name: '하드웨어',     categoryId: 'IT', categoryName: 'IT'),
    // 헬스케어
    SectorMeta(id: 'HC_1', name: '바이오',       categoryId: 'HC', categoryName: '헬스케어'),
    SectorMeta(id: 'HC_2', name: '제약',         categoryId: 'HC', categoryName: '헬스케어'),
    SectorMeta(id: 'HC_3', name: '의료기기',     categoryId: 'HC', categoryName: '헬스케어'),
    // 금융
    SectorMeta(id: 'FN_1', name: '은행',         categoryId: 'FN', categoryName: '금융'),
    SectorMeta(id: 'FN_2', name: '보험',         categoryId: 'FN', categoryName: '금융'),
    SectorMeta(id: 'FN_3', name: '증권',         categoryId: 'FN', categoryName: '금융'),
    // 임의소비재
    SectorMeta(id: 'CD_1', name: '자동차',       categoryId: 'CD', categoryName: '임의소비재'),
    SectorMeta(id: 'CD_2', name: '의류',         categoryId: 'CD', categoryName: '임의소비재'),
    SectorMeta(id: 'CD_3', name: '호텔',         categoryId: 'CD', categoryName: '임의소비재'),
    SectorMeta(id: 'CD_4', name: '전자제품',     categoryId: 'CD', categoryName: '임의소비재'),
    // 필수소비재
    SectorMeta(id: 'CS_1', name: '음식료',       categoryId: 'CS', categoryName: '필수소비재'),
    SectorMeta(id: 'CS_2', name: '생활용품',     categoryId: 'CS', categoryName: '필수소비재'),
    // 커뮤니케이션
    SectorMeta(id: 'CM_1', name: '통신',         categoryId: 'CM', categoryName: '커뮤니케이션'),
    SectorMeta(id: 'CM_2', name: '미디어',       categoryId: 'CM', categoryName: '커뮤니케이션'),
    SectorMeta(id: 'CM_3', name: '엔터테인먼트', categoryId: 'CM', categoryName: '커뮤니케이션'),
    // 산업재
    SectorMeta(id: 'IN_1', name: '항공우주',     categoryId: 'IN', categoryName: '산업재'),
    SectorMeta(id: 'IN_2', name: '기계',         categoryId: 'IN', categoryName: '산업재'),
    SectorMeta(id: 'IN_3', name: '건설',         categoryId: 'IN', categoryName: '산업재'),
    SectorMeta(id: 'IN_4', name: '운송',         categoryId: 'IN', categoryName: '산업재'),
    // 에너지
    SectorMeta(id: 'EN_1', name: '석유',         categoryId: 'EN', categoryName: '에너지'),
    SectorMeta(id: 'EN_2', name: '가스',         categoryId: 'EN', categoryName: '에너지'),
    SectorMeta(id: 'EN_3', name: '대체에너지',   categoryId: 'EN', categoryName: '에너지'),
    // 소재
    SectorMeta(id: 'MT_1', name: '화학',         categoryId: 'MT', categoryName: '소재'),
    SectorMeta(id: 'MT_2', name: '금속',         categoryId: 'MT', categoryName: '소재'),
    SectorMeta(id: 'MT_3', name: '광물',         categoryId: 'MT', categoryName: '소재'),
    // 유틸리티
    SectorMeta(id: 'UT_1', name: '전력',         categoryId: 'UT', categoryName: '유틸리티'),
    SectorMeta(id: 'UT_2', name: '도시가스',     categoryId: 'UT', categoryName: '유틸리티'),
    SectorMeta(id: 'UT_3', name: '수도',         categoryId: 'UT', categoryName: '유틸리티'),
    // 부동산
    SectorMeta(id: 'RE_1', name: '개발',         categoryId: 'RE', categoryName: '부동산'),
    SectorMeta(id: 'RE_2', name: '관리',         categoryId: 'RE', categoryName: '부동산'),
    SectorMeta(id: 'RE_3', name: '투자',         categoryId: 'RE', categoryName: '부동산'),
  ];
}
