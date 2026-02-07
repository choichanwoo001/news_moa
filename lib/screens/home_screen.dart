import 'package:flutter/material.dart';
import '../models/stock_sector.dart';
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
  final List<String> _tabs = ["대한민국", "미국", "중국", "유럽"];
  
  // Dummy data variants for different countries to show interactivity
  late List<StockSector> _currentSectors;

  @override
  void initState() {
    super.initState();
    _currentSectors = StockSector.dummyData;
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
      
      // Simple simulation of different data for different tabs
      final baseData = StockSector.dummyData;
      if (index == 0) {
        _currentSectors = baseData;
      } else {
        // Shuffle and modify volume slightly to look different
        _currentSectors = List.of(baseData)..shuffle();
        _currentSectors = _currentSectors.map((s) => StockSector(
          id: s.id,
          name: s.name, 
          newsVolume: (s.newsVolume * (1.0 + (index * 0.1) * (s.id.hashCode % 2 == 0 ? 1 : -1))).abs(),
          changeRate: s.changeRate
        )).toList();
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
            // Custom Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Heatmap',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time visualization of market news volume',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            
            // Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CustomTabBar(
                tabs: _tabs,
                selectedIndex: _selectedTabIndex,
                onTabSelected: _onTabSelected,
              ),
            ),
            
            const SizedBox(height: 16),

            // Main Content Area (Treemap)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: StockTreemap(sectors: _currentSectors),
              ),
            ),
            
             // Bottom Info / Legend
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(AppColors.heatHigh, "High Volume"),
                  const SizedBox(width: 24),
                  _buildLegendItem(AppColors.heatMediumLow, "Med Volume"),
                  const SizedBox(width: 24),
                  _buildLegendItem(AppColors.heatLowest, "Low Volume"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
