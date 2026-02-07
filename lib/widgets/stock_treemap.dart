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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CustomMultiChildLayout(
        delegate: TreemapLayoutDelegate(weights: weights),
        children: sortedSectors.map((sector) {
          final color = AppColors.getColorForVolume(sector.newsVolume);
          
          return LayoutId(
            id: sector.id,
            child: _buildBlock(context, sector, color),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBlock(BuildContext context, StockSector sector, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.surface, width: 1.0), // Cleaner, thinner gap
      ),
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double h = constraints.maxHeight;
          final double w = constraints.maxWidth;
          
          if (h < 30 || w < 40) {
            return const SizedBox.shrink(); 
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  sector.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: (w < 80 || h < 60) ? 12 : 15,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  maxLines: 2,
                ),
              ),
              if (h > 50 && w > 80) ...[
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    "${sector.newsVolume.toInt()} News",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
