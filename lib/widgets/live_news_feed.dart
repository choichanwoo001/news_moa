import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../theme/app_colors.dart';
import 'tag_chip.dart';

/// 실시간 뉴스 피드 (하단 미니 리스트, LIVE 펄스)
class LiveNewsFeed extends StatelessWidget {
  final List<({NewsArticle article, String sector})> items;
  final String? updatedAtDisplay;
  final Animation<double> pulseAnimation;
  final void Function(NewsArticle article, String? sectorName) onArticleTap;

  const LiveNewsFeed({
    super.key,
    required this.items,
    this.updatedAtDisplay,
    required this.pulseAnimation,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.surfaceHighlight.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.negative.withValues(
                            alpha: 0.6 + pulseAnimation.value * 0.4,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.negative.withValues(
                                alpha: pulseAnimation.value * 0.3,
                              ),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '실시간 뉴스',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.negative.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'LIVE',
                      style: TextStyle(
                        color: AppColors.negative,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (updatedAtDisplay != null)
                    Text(
                      '$updatedAtDisplay 기준',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        '뉴스 없음',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    )
                  : ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        scrollbars: false,
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: AppColors.divider,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return InkWell(
                            onTap: () => onArticleTap(
                              item.article,
                              item.sector,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      item.article.displayTime,
                                      style: TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.article.title,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Wrap(
                                          spacing: 4,
                                          runSpacing: 4,
                                          children: [
                                            TagChip(
                                              label: item.sector,
                                              bgColor: AppColors.surfaceElevated,
                                              textColor:
                                                  AppColors.getSectorColor(
                                                      item.sector),
                                              fontSize: 9,
                                            ),
                                            ...item.article.relatedCompanies
                                                .map(
                                                  (company) => TagChip(
                                                    label: company,
                                                    bgColor: AppColors.primary
                                                        .withValues(alpha: 0.08),
                                                    textColor: AppColors
                                                        .primary
                                                        .withValues(
                                                            alpha: 0.8),
                                                    fontSize: 9,
                                                  ),
                                                ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
