import 'package:flutter/material.dart';
import '../models/stock_sector.dart';
import '../theme/app_colors.dart';
import 'treemap_layout_delegate.dart';

class StockTreemap extends StatelessWidget {
  final List<StockSector> sectors;
  final Function(StockSector)? onSectorTap;

  const StockTreemap({
    super.key, 
    required this.sectors,
    this.onSectorTap,
  });

  @override
  Widget build(BuildContext context) {
    final sortedSectors = List<StockSector>.from(sectors)
      ..sort((a, b) => b.newsVolume.compareTo(a.newsVolume));

    final Map<String, double> weights = {
      for (var s in sortedSectors) s.id: s.newsVolume
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CustomMultiChildLayout(
        delegate: TreemapLayoutDelegate(weights: weights),
        children: sortedSectors.map((sector) {
          final baseColor = AppColors.getColorForVolume(sector.newsVolume);
          
          return LayoutId(
            id: sector.id,
            child: GestureDetector(
              onTap: () => onSectorTap?.call(sector),
              child: _buildBlock(context, sector, baseColor),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBlock(BuildContext context, StockSector sector, Color baseColor) {
    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withOpacity(0.9),
            baseColor,
            baseColor.withOpacity(0.8),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        border: Border.all(color: AppColors.background, width: 2.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double h = constraints.maxHeight;
          final double w = constraints.maxWidth;
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      sector.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13, 
                        height: 1.0,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1, 
                    ),
                  ),
                ),
              ),
              // 공간이 충분할 때만 부가 정보 표시
              if (h > 45 && w > 60) ...[
                const SizedBox(height: 2),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${sector.newsVolume.toInt()}건', 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
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
