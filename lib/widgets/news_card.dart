import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../theme/app_colors.dart';
import 'tag_chip.dart';

/// 섹터 뉴스 리스트용 뉴스 카드 (제목, 요약, 관련 기업 태그)
class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final String? sectorName;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.article,
    this.sectorName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.surfaceHighlight.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            if (article.displaySummary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                article.displaySummary,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
            if (article.relatedCompanies.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: article.relatedCompanies
                    .map(
                      (company) => TagChip(
                        label: company,
                        bgColor: AppColors.accent.withValues(alpha: 0.1),
                        textColor: AppColors.accent.withValues(alpha: 0.9),
                        fontSize: 10,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
