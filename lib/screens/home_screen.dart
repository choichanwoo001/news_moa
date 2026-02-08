import 'package:flutter/material.dart';
import '../models/stock_sector.dart';
import '../models/sector_data.dart';
import '../widgets/custom_tab_bar.dart';
import '../widgets/stock_treemap.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ["전체 (Global)", "한국 (Korea)", "미국 (USA)", "중국 (China)"];
  
  // Dummy news data
  // Dummy news data
  final List<Map<String, String>> _newsItems = [
    // IT - 반도체, 소프트웨어, 하드웨어
    {"time": "11:30", "title": "삼성전자, 차세대 HBM 메모리 양산 발표", "sector": "반도체", "highlight": "true"},
    {"time": "11:10", "title": "SK하이닉스, AI 반도체 투자 확대", "sector": "반도체", "highlight": "true"},
    {"time": "10:50", "title": "네이버, 신규 AI 검색 서비스 공개 임박", "sector": "소프트웨어", "highlight": "true"},
    {"time": "10:45", "title": "카카오, 클라우드 부문 매출 20% 성장", "sector": "소프트웨어", "highlight": "false"},
    {"time": "09:30", "title": "애플, 차세대 아이폰 하드웨어 스펙 유출", "sector": "하드웨어", "highlight": "false"},

    // 헬스케어 - 바이오, 제약, 의료기기
    {"time": "11:25", "title": "셀트리온, 램시마SC 미국 FDA 승인 기대감", "sector": "바이오", "highlight": "true"},
    {"time": "10:20", "title": "삼성바이오로직스, 4공장 가동률 상승", "sector": "바이오", "highlight": "false"},
    {"time": "09:50", "title": "한미약품, 신약 기술수출 논의 중", "sector": "제약", "highlight": "false"},
    {"time": "09:10", "title": "오스템임플란트, 해외 매출 비중 확대", "sector": "의료기기", "highlight": "true"},

    // 금융 - 은행, 보험, 증권
    {"time": "11:15", "title": "KB금융, 주주환원 확대... 배당금 상향", "sector": "은행", "highlight": "false"},
    {"time": "10:40", "title": "신한지주, 상생금융 지원안 발표", "sector": "은행", "highlight": "false"},
    {"time": "10:05", "title": "삼성생명, 3분기 실적 컨센서스 상회", "sector": "보험", "highlight": "false"},
    {"time": "09:40", "title": "미래에셋증권, 해외 주식 수수료 인하 이벤트", "sector": "증권", "highlight": "true"},

    // 임의소비재 - 자동차, 의류, 호텔, 전자제품
    {"time": "11:28", "title": "현대차, 전기차 전용 공장 착공식 개최", "sector": "자동차", "highlight": "true"},
    {"time": "10:55", "title": "기아, SUV 판매 호조로 실적 개선", "sector": "자동차", "highlight": "true"},
    {"time": "09:20", "title": "F&F, 해외 의류 브랜드 인수설", "sector": "의류", "highlight": "false"},
    {"time": "10:15", "title": "호텔신라, 면세점 매출 회복세", "sector": "호텔", "highlight": "false"},
    {"time": "09:05", "title": "LG전자, 가전 구독 서비스 확대", "sector": "전자제품", "highlight": "false"},

    // 2차전지 (별도 카테고리 혹은 IT/소재 하위) -> 여기선 예시로 추가
    {"time": "11:00", "title": "LG에너지솔루션, 북미 배터리 공장 조기 가동", "sector": "2차전지", "highlight": "true"},
    {"time": "10:30", "title": "에코프로, 양극재 생산 능력 확대", "sector": "2차전지", "highlight": "true"},

    // 소재 - 화학, 금속
    {"time": "10:00", "title": "LG화학, 친환경 플라스틱 소재 개발", "sector": "화학", "highlight": "false"},
    {"time": "09:45", "title": "포스코홀딩스, 리튬 염호 투자 성과 가시화", "sector": "금속", "highlight": "true"},

    // 산업재 - 건설, 기계, 조선(운송)
    {"time": "10:10", "title": "현대건설, 중동 대형 플랜트 수주", "sector": "건설", "highlight": "true"},
    {"time": "09:55", "title": "두산에너빌리티, 소형모듈원전(SMR) 수주", "sector": "기계", "highlight": "true"},
    {"time": "09:35", "title": "HD현대중공업, LNG 운반선 2척 수주", "sector": "운송", "highlight": "false"},

    // 기타
    {"time": "09:15", "title": "SK텔레콤, 6G 기술 개발 협력", "sector": "통신", "highlight": "false"},
    {"time": "09:25", "title": "CJ ENM, 티빙 가입자 수 증가", "sector": "미디어", "highlight": "true"},
  ];
  
  
  late List<StockSector> _currentSectors;
  
  // Navigation State
  bool _isCategoryLevel = false;
  StockCategory? _selectedCategory;
  StockSector? _selectedSubSector; // For news filtering

  @override
  void initState() {
    super.initState();
    _loadTopLevelCategories();
  }

  void _loadTopLevelCategories() {
    _isCategoryLevel = false;
    _selectedCategory = null;
    _selectedSubSector = null;
    _currentSectors = SectorHierarchy.categories.map((c) => c.toSector()).toList();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
      _loadTopLevelCategories();
      // Dummy logic: Tabs just shuffle/modify top level for now, 
      // in real app they would filter regions. 
      // Resetting to top level on tab change is safer for UI flow.
    });
  }

  void _onSectorTap(StockSector sector) {
    setState(() {
      if (!_isCategoryLevel) {
        // Level 1 -> Level 2
        final category = SectorHierarchy.categories.firstWhere(
          (c) => c.id == sector.id, 
          orElse: () => SectorHierarchy.categories.first
        );
        _selectedCategory = category;
        _currentSectors = category.subSectors;
        _isCategoryLevel = true;
        _selectedSubSector = null; // Reset sub selection
      } else {
        // Level 2 -> Show News
        _selectedSubSector = sector;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Neon Glow Effect + Back Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 24, 16), // Adjusted padding
              child: Stack(
                alignment: Alignment.center,
                children: [
                   if (_isCategoryLevel)
                    Positioned(
                      left: 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
                        onPressed: () {
                          setState(() {
                            _loadTopLevelCategories();
                          });
                        },
                      ),
                    ),
                  Center(
                    child: Text(
                      _isCategoryLevel ? _selectedCategory!.name : 'NewsMoa',
                      style: TextStyle(
                        fontFamily: 'Noto Sans KR',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 0),
                            blurRadius: 10.0,
                            color: AppColors.neonGlow.withOpacity(0.6),
                          ),
                          Shadow(
                            offset: const Offset(0, 0),
                            blurRadius: 20.0,
                            color: AppColors.accent.withOpacity(0.4),
                          ),
                        ],
                        decoration: TextDecoration.none,
                        foreground: Paint()
                          ..style = PaintingStyle.fill
                          ..shader = const LinearGradient(
                            colors: [AppColors.neonGlow, AppColors.accent, AppColors.heatHigh],
                          ).createShader(const Rect.fromLTWH(0, 0, 300, 50)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Segmented Control (Dark Pill Style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomTabBar(
                tabs: _tabs,
                selectedIndex: _selectedTabIndex,
                onTabSelected: _onTabSelected,
              ),
            ),
            
            const SizedBox(height: 24),
            


            const SizedBox(height: 12),

            // Main Content Area (Treemap)
            Expanded(
              flex: 3, // Give more space to the map
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                // Removed explicit background color for cleaner look, 
                // allowing individual blocks to stand out against the dark bg
                child: StockTreemap(
                  sectors: _currentSectors,
                  onSectorTap: _onSectorTap,
                ),
              ),
            ),
            
            const SizedBox(height: 16),

             // Bottom Info / News Feed
            _buildLiveNewsFeed(),
          ],
        ),
      ),
    );
  }


  Widget _buildLiveNewsFeed() {
    return Expanded(
      flex: 2, // Allocate space for news
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceHighlight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.heatHigh,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '실시간 뉴스 속보',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _selectedSubSector != null 
                      ? '${_selectedSubSector!.name} 관련 뉴스' 
                      : '실시간 업데이트 중',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceHighlight),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: _selectedSubSector != null
                    ? _newsItems.where((item) => item['sector'] == _selectedSubSector!.name).length
                    : _newsItems.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1, 
                  color: AppColors.surfaceHighlight, 
                  indent: 16, 
                  endIndent: 16
                ),
                itemBuilder: (context, index) {
                  // Filtering logic
                  final filteredItems = _selectedSubSector != null
                      ? _newsItems.where((item) => item['sector'] == _selectedSubSector!.name).toList()
                      : _newsItems;
                  
                  if (filteredItems.isEmpty) {
                     return const Padding(
                       padding: EdgeInsets.all(16.0),
                       child: Center(child: Text("관련 뉴스가 없습니다.", style: TextStyle(color: AppColors.textSecondary))),
                     );
                  }

                  final item = filteredItems[index];
                  final isHighlight = item['highlight'] == "true";
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['time']!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: TextStyle(
                                  color: isHighlight ? AppColors.textPrimary : AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item['sector']!,
                                  style: TextStyle(
                                    color: AppColors.getSectorColor(item['sector']!), // Helper method usage assumption or fallback
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
