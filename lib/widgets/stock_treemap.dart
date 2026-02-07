
import 'package:flutter/material.dart';
import '../models/stock_sector.dart';
import '../theme/app_colors.dart';
import 'treemap_layout_delegate.dart';

class StockTreemap extends StatelessWidget {
  final List<StockSector> sectors;

  const StockTreemap({super.key, required this.sectors});

  @override
  Widget build(BuildContext context) {
    // Sort sectors by news volume (descending) for better layout
    final sortedSectors = List<StockSector>.from(sectors)
      ..sort((a, b) => b.newsVolume.compareTo(a.newsVolume));

    final Map<String, double> weights = {
      for (var s in sortedSectors) s.id: s.newsVolume
    };

    return Container(
      padding: const EdgeInsets.all(4), // Outer padding
      child: CustomMultiChildLayout(
        delegate: TreemapLayoutDelegate(weights: weights),
        children: sortedSectors.map((sector) {
          final color = AppColors.getColorForVolume(sector.newsVolume);
          
          return LayoutId(
            id: sector.id,
            child: _buildBlock(sector, color),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBlock(StockSector sector, Color color) {
    // Check if the block is too small to show text
    // We can't know the size here easily without LayoutBuilder inside layout,
    // but the CustomMultiChildLayout just places them.
    // We can wrap the content in a container that clips or scales text.
    
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8), // Rounded corners
        border: Border.all(color: Colors.white, width: 2), // Gap simulation
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available height
          final double h = constraints.maxHeight;
          final double w = constraints.maxWidth;
          
          if (h < 20 || w < 30) {
            return const SizedBox.shrink(); // Too small to show anything
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (h > 20)
                  Flexible(
                    child: Text(
                      sector.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: (h < 40) ? 12 : 16, // Adaptive font size
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                if (h > 40) ...[
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      "${sector.newsVolume.toInt()} News",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
