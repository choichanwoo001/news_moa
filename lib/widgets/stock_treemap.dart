import 'package:flutter/material.dart';
import '../models/stock_sector.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../utils/format_utils.dart';
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
      borderRadius: BorderRadius.circular(AppDimensions.spacingMd),
      child: CustomMultiChildLayout(
        delegate: TreemapLayoutDelegate(weights: weights),
        children: sortedSectors.map((sector) {
          final baseColor = AppColors.getColorForChangeRate(sector.changeRate);

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
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Stack(
        children: [
          // 상단 글래스 하이라이트 (그라데이션 아님, 단순 반투명 오버레이)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 1.5 * 16,
            child: Container(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          // 콘텐츠
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double h = constraints.maxHeight;
                final double w = constraints.maxWidth;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 섹터 이름
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.25 * 16),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            sector.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 0.8125 * 16,  // 0.8125rem
                              height: 1.0,
                              letterSpacing: 0.3,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    // 뉴스 볼륨은 항상 표기 (FittedBox 로 크기 자동 조절)
                    SizedBox(height: 0.1875 * 16), // 0.1875rem
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${FormatUtils.formatVolume(sector.newsVolume)}건',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 0.625 * 16, // 0.625rem
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    // 더 넓은 공간일 때 변화율 표시
                    if (h > 70 && w > 75) ...[
                      SizedBox(height: 0.125 * 16), // 0.125rem
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            FormatUtils.formatChangeRate(sector.changeRate),
                            style: TextStyle(
                              color: sector.changeRate >= 0
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.white.withValues(alpha: 0.75),
                              fontSize: 0.5625 * 16, // 0.5625rem
                              fontWeight: FontWeight.w700,
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
          ),
        ],
      ),
    );
  }
}
