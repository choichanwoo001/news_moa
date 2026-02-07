
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
      // In a real app, this would fetch data from an API
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'Market Heatmap',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            
            // Segmented Control
            CustomTabBar(
              tabs: _tabs,
              selectedIndex: _selectedTabIndex,
              onTabSelected: _onTabSelected,
            ),
            
            // Main Content Area (Treemap)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: StockTreemap(sectors: _currentSectors),
              ),
            ),
            
            // Bottom Info / Legend (Optional)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(AppColors.heatHigh, "High Vol"),
                  const SizedBox(width: 16),
                  _buildLegendItem(AppColors.heatMediumLow, "Med Vol"),
                  const SizedBox(width: 16),
                  _buildLegendItem(AppColors.heatLowest, "Low Vol"),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
