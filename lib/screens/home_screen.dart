import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_model.dart';
import '../models/stock_sector.dart';
import '../widgets/custom_tab_bar.dart';
import '../widgets/stock_treemap.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/home_header.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/sector_news_list_screen.dart';
import '../widgets/live_news_feed.dart';
import '../widgets/article_preview_sheet.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ["한국", "미국"];

  // ─── API 데이터 상태 ────────────────────────────
  HeatmapData? _heatmapData;
  bool _isLoading = true;
  String? _errorMessage;

  // ─── 네비게이션 상태 ────────────────────────────
  bool _isCategoryLevel = false;
  CategoryHeatmap? _selectedCategory;
  SectorNewsResult? _selectedSubSector;

  // ─── 현재 표시할 섹터 목록 (StockSector 로 변환) ──
  List<StockSector> _currentSectors = [];

  // ─── 무한 스크롤 상태 ────────────────────────────
  List<NewsArticle> _sectorArticles = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMorePages = true;
  final ScrollController _sectorScrollController = ScrollController();

  // ─── LIVE 펄스 애니메이션 ──────────────────────
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadHeatmapData();
    _sectorScrollController.addListener(_onSectorScroll);
  }

  @override
  void dispose() {
    _sectorScrollController.removeListener(_onSectorScroll);
    _sectorScrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onSectorScroll() {
    if (_sectorScrollController.position.pixels >=
        _sectorScrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMorePages && _selectedSubSector != null) {
        _loadSectorNews(_selectedSubSector!.sectorId, page: _currentPage + 1);
      }
    }
  }

  // ─── 데이터 로딩 ────────────────────────────────

  Future<void> _loadHeatmapData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final market = _selectedTabIndex == 0 ? 'KR' : 'US';
      final data = await ApiService.instance.fetchHeatmapData(market: market);
      if (!mounted) return;
      setState(() {
        _heatmapData = data;
        _isLoading = false;
        _loadTopLevelCategories();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '알 수 없는 오류: $e';
      });
    }
  }

  // ─── 네비게이션 로직 ────────────────────────────

  void _loadTopLevelCategories() {
    if (_heatmapData == null) return;
    _isCategoryLevel = false;
    _selectedCategory = null;
    _selectedSubSector = null;
    _currentSectors = _heatmapData!.categories
        .map((cat) => StockSector(
              id: cat.categoryId,
              name: cat.categoryName,
              newsVolume: cat.totalVolume,
              changeRate: cat.avgChangeRate,
            ))
        .toList();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
      _heatmapData = null;
      _currentSectors = [];
    });
    _loadHeatmapData();
  }

  void _onSectorTap(StockSector sector) {
    if (_heatmapData == null) return;
    setState(() {
      if (!_isCategoryLevel) {
        final category = _heatmapData!.categories.firstWhere(
          (c) => c.categoryId == sector.id,
          orElse: () => _heatmapData!.categories.first,
        );
        _selectedCategory = category;
        _currentSectors = category.subSectors
            .map((s) => StockSector(
                  id: s.sectorId,
                  name: s.sectorName,
                  newsVolume: s.newsVolume,
                  changeRate: s.changeRate,
                ))
            .toList();
        _isCategoryLevel = true;
        _selectedSubSector = null;
      } else {
        final sub = _selectedCategory!.subSectors.firstWhere(
          (s) => s.sectorId == sector.id,
          orElse: () => _selectedCategory!.subSectors.first,
        );
        _selectedSubSector = sub;
        
        // 무한 스크롤 상태 초기화 + 첫 페이지 로드 (히트맵에 포함된 뉴스 우선 표시)
        _sectorArticles = List<NewsArticle>.from(sub.articles);
        _currentPage = 1;
        _hasMorePages = true;
        _isLoadingMore = false;
      }
    });

    // 섹터 선택 시 추가 뉴스 로드 (2페이지부터)
    if (_selectedSubSector != null) {
      _loadSectorNews(_selectedSubSector!.sectorId, page: 2);
    }
  }

  // ─── 섹터 뉴스 페이지네이션 로드 ──────────────────

  Future<void> _loadSectorNews(String sectorId, {int page = 1}) async {
    if (_isLoadingMore || !_hasMorePages) return;
    setState(() => _isLoadingMore = true);

    try {
      final result = await ApiService.instance.fetchSectorNews(sectorId, page: page);
      if (!mounted) return;
      setState(() {
        if (result.articles.isEmpty) {
          _hasMorePages = false;
        } else {
          _sectorArticles.addAll(result.articles);
          _currentPage = page;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _hasMorePages = false;
      });
      debugPrint('섹터 뉴스 추가 로드 실패: $e');
    }
  }

  // ─── 빌드 ───────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title = _selectedSubSector != null
        ? _selectedSubSector!.sectorName
        : (_isCategoryLevel
            ? _selectedCategory!.categoryName
            : 'NewsMoa');
    final showBack = _isCategoryLevel || _selectedSubSector != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(
              title: title,
              showBackButton: showBack,
              onBack: () {
                setState(() {
                  if (_selectedSubSector != null) {
                    _selectedSubSector = null;
                  } else {
                    _loadTopLevelCategories();
                  }
                });
              },
              isLoading: _isLoading,
              onRefresh: _loadHeatmapData,
            ),
            if (_selectedSubSector == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTabBar(
                  tabs: _tabs,
                  selectedIndex: _selectedTabIndex,
                  onTabSelected: _onTabSelected,
                ),
              ),
            if (_selectedSubSector == null) const SizedBox(height: 16),
            if (_isLoading)
              const LoadingView()
            else if (_errorMessage != null)
              ErrorView(
                message: _errorMessage!,
                onRetry: _loadHeatmapData,
              )
            else if (_selectedSubSector != null)
              SectorNewsListScreen(
                selectedSubSector: _selectedSubSector!,
                articles: _sectorArticles,
                hasMorePages: _hasMorePages,
                isLoadingMore: _isLoadingMore,
                scrollController: _sectorScrollController,
                onArticleTap: (article, sectorName) =>
                    _showArticlePreview(article, sectorName: sectorName),
              )
            else ...[
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: StockTreemap(
                    sectors: _currentSectors,
                    onSectorTap: _onSectorTap,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LiveNewsFeed(
                items: _liveFeedItems,
                updatedAtDisplay: _heatmapData?.updatedAt.substring(11, 16),
                pulseAnimation: _pulseController,
                onArticleTap: (article, sectorName) =>
                    _showArticlePreview(article, sectorName: sectorName),
              ),
            ],
            const SafeArea(
              top: false,
              child: Center(child: BannerAdWidget()),
            ),
          ],
        ),
      ),
    );
  }

  List<({NewsArticle article, String sector})> get _liveFeedItems {
    final data = _heatmapData;
    if (data == null) return [];
    final list = <({NewsArticle article, String sector})>[];
    for (final cat in data.categories) {
      for (final s in cat.subSectors) {
        for (final a in s.articles) {
          list.add((article: a, sector: s.sectorName));
        }
      }
    }
    return list;
  }

  Future<void> _openArticleUrl(NewsArticle article) async {
    final urlStr = article.originalLink ?? article.link;
    if (urlStr.isEmpty) return;
    final uri = Uri.tryParse(urlStr);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('URL 열기 실패: $e');
    }
  }

  void _showArticlePreview(NewsArticle article, {String? sectorName}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (_, scrollController) => ArticlePreviewSheet(
          article: article,
          sectorName: sectorName,
          scrollController: scrollController,
          onOpenUrl: () => _openArticleUrl(article),
          onClose: () => Navigator.pop(ctx),
        ),
      ),
    );
  }
}
