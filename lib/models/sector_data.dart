
import 'stock_sector.dart';

class StockCategory {
  final String id;
  final String name;
  final List<StockSector> subSectors;

  const StockCategory({
    required this.id,
    required this.name,
    required this.subSectors,
  });

  // Calculate total volume for the category based on sub-sectors
  double get totalVolume => subSectors.fold(0, (sum, item) => sum + item.newsVolume);
  
  // Calculate average change rate
  double get averageChangeRate {
    if (subSectors.isEmpty) return 0.0;
    return subSectors.fold(0.0, (sum, item) => sum + item.changeRate) / subSectors.length;
  }

  StockSector toSector() {
    return StockSector(
      id: id,
      name: name,
      newsVolume: totalVolume,
      changeRate: averageChangeRate,
    );
  }
}

class SectorHierarchy {
  static List<StockCategory> get categories {
    return [
      StockCategory(
        id: 'IT',
        name: 'IT',
        subSectors: [
          StockSector(id: 'IT_1', name: '반도체', newsVolume: 95, changeRate: 2.5),
          StockSector(id: 'IT_2', name: '소프트웨어', newsVolume: 80, changeRate: 1.2),
          StockSector(id: 'IT_3', name: '하드웨어', newsVolume: 60, changeRate: 0.5),
        ],
      ),
      StockCategory(
        id: 'Healthcare',
        name: '헬스케어',
        subSectors: [
          StockSector(id: 'HC_1', name: '바이오', newsVolume: 70, changeRate: -0.5),
          StockSector(id: 'HC_2', name: '제약', newsVolume: 50, changeRate: 0.2),
          StockSector(id: 'HC_3', name: '의료기기', newsVolume: 40, changeRate: 0.8),
        ],
      ),
      StockCategory(
        id: 'Finance',
        name: '금융',
        subSectors: [
          StockSector(id: 'FN_1', name: '은행', newsVolume: 55, changeRate: 0.4),
          StockSector(id: 'FN_2', name: '보험', newsVolume: 45, changeRate: 0.1),
          StockSector(id: 'FN_3', name: '증권', newsVolume: 65, changeRate: 1.5),
        ],
      ),
      StockCategory(
        id: 'ConsDiscr',
        name: '임의소비재',
        subSectors: [
          StockSector(id: 'CD_1', name: '자동차', newsVolume: 85, changeRate: 0.9),
          StockSector(id: 'CD_2', name: '의류', newsVolume: 30, changeRate: -1.2),
          StockSector(id: 'CD_3', name: '호텔', newsVolume: 25, changeRate: 2.1),
          StockSector(id: 'CD_4', name: '전자제품', newsVolume: 40, changeRate: 0.3),
        ],
      ),
      StockCategory(
        id: 'ConsStap',
        name: '필수소비재',
        subSectors: [
          StockSector(id: 'CS_1', name: '음식료', newsVolume: 35, changeRate: 0.1),
          StockSector(id: 'CS_2', name: '생활용품', newsVolume: 20, changeRate: -0.5),
        ],
      ),
      StockCategory(
        id: 'Comm',
        name: '커뮤니케이션',
        subSectors: [
          StockSector(id: 'CM_1', name: '통신', newsVolume: 40, changeRate: 0.2),
          StockSector(id: 'CM_2', name: '미디어', newsVolume: 50, changeRate: -0.8),
          StockSector(id: 'CM_3', name: '엔터테인먼트', newsVolume: 60, changeRate: 1.8),
        ],
      ),
      StockCategory(
        id: 'Indus',
        name: '산업재',
        subSectors: [
          StockSector(id: 'IN_1', name: '항공우주', newsVolume: 45, changeRate: 2.2),
          StockSector(id: 'IN_2', name: '기계', newsVolume: 35, changeRate: -0.3),
          StockSector(id: 'IN_3', name: '건설', newsVolume: 30, changeRate: -1.5),
          StockSector(id: 'IN_4', name: '운송', newsVolume: 25, changeRate: 0.6),
        ],
      ),
      StockCategory(
        id: 'Energy',
        name: '에너지',
        subSectors: [
          StockSector(id: 'EN_1', name: '석유', newsVolume: 50, changeRate: 1.1),
          StockSector(id: 'EN_2', name: '가스', newsVolume: 40, changeRate: 0.9),
          StockSector(id: 'EN_3', name: '대체에너지', newsVolume: 55, changeRate: 3.5),
        ],
      ),
      StockCategory(
        id: 'Material',
        name: '소재',
        subSectors: [
          StockSector(id: 'MT_1', name: '화학', newsVolume: 45, changeRate: 0.7),
          StockSector(id: 'MT_2', name: '금속', newsVolume: 35, changeRate: -0.2),
          StockSector(id: 'MT_3', name: '광물', newsVolume: 20, changeRate: 0.4),
        ],
      ),
      StockCategory(
        id: 'Util',
        name: '유틸리티',
        subSectors: [
          StockSector(id: 'UT_1', name: '전력', newsVolume: 30, changeRate: 0.2),
          StockSector(id: 'UT_2', name: '가스', newsVolume: 25, changeRate: 0.1),
          StockSector(id: 'UT_3', name: '수도', newsVolume: 15, changeRate: 0.0),
        ],
      ),
      StockCategory(
        id: 'RealEstate',
        name: '부동산',
        subSectors: [
          StockSector(id: 'RE_1', name: '개발', newsVolume: 20, changeRate: -1.0),
          StockSector(id: 'RE_2', name: '관리', newsVolume: 15, changeRate: 0.5),
          StockSector(id: 'RE_3', name: '투자', newsVolume: 25, changeRate: -0.5),
        ],
      ),
    ];
  }
}
