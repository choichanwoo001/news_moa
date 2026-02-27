import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../theme/app_colors.dart';
import 'tag_chip.dart';
import 'news_card.dart';

/// 섹터별 뉴스 전체 화면 (헤더 + 키워드/브리핑 + 무한 스크롤 리스트)
class SectorNewsListScreen extends StatelessWidget {
  final SectorNewsResult selectedSubSector;
  final List<NewsArticle> articles;
  final bool hasMorePages;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final void Function(NewsArticle article, String? sectorName) onArticleTap;

  const SectorNewsListScreen({
    super.key,
    required this.selectedSubSector,
    required this.articles,
    required this.hasMorePages,
    required this.isLoadingMore,
    required this.scrollController,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    final sub = selectedSubSector;
    final cachedTime = sub.cachedAt != null
        ? sub.cachedAt!.substring(11, 16)
        : null;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹터명 + 업데이트 시간
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${sub.sectorName} 관련 뉴스',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (cachedTime != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        cachedTime,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 급상승 키워드
            if (sub.risingKeywords.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '급상승 키워드',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: sub.risingKeywords
                            .map(
                              (keyword) => TagChip(
                                label: keyword,
                                bgColor: AppColors.primary.withValues(alpha: 0.12),
                                textColor: AppColors.primary,
                                fontSize: 11,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // AI 섹터 브리핑
            if (sub.sectorBriefing != null && sub.sectorBriefing!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 16,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sub.sectorBriefing!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: articles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            color: AppColors.textTertiary,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '관련된 최근 뉴스가 없습니다.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        scrollbars: false,
                      ),
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: articles.length + (hasMorePages ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= articles.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                              ),
                              child: Center(
                                child: isLoadingMore
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: AppColors.neonGlow,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            );
                          }
                          final article = articles[index];
                          return NewsCard(
                            article: article,
                            sectorName: sub.sectorName,
                            onTap: () => onArticleTap(
                              article,
                              sub.sectorName,
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
