import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../theme/app_colors.dart';
import 'tag_chip.dart';

/// 뉴스 기사 미리보기 바텀시트 본문 (모달 내용만 담당)
class ArticlePreviewSheet extends StatelessWidget {
  final NewsArticle article;
  final String? sectorName;
  final VoidCallback onOpenUrl;
  final VoidCallback onClose;
  final ScrollController? scrollController;

  const ArticlePreviewSheet({
    super.key,
    required this.article,
    this.sectorName,
    required this.onOpenUrl,
    required this.onClose,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = article.displayDate;
    final timeStr = article.displayTime;
    final dateTimeStr = [
      if (dateStr.isNotEmpty) dateStr,
      if (timeStr.isNotEmpty) timeStr,
    ].join(' ');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceHighlight, width: 1),
        ),
      ),
      child: Column(
        children: [
          // 드래그 핸들 + 닫기
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
            child: Row(
              children: [
                const Spacer(),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (sectorName != null)
                      TagChip(
                        label: sectorName!,
                        bgColor: AppColors.primary.withValues(alpha: 0.12),
                        textColor: AppColors.primary,
                        bold: true,
                      ),
                    ...article.relatedCompanies.map(
                      (company) => TagChip(
                        label: company,
                        bgColor: AppColors.accent.withValues(alpha: 0.1),
                        textColor: AppColors.accent.withValues(alpha: 0.9),
                        borderColor: AppColors.accent.withValues(alpha: 0.2),
                      ),
                    ),
                    if (dateTimeStr.isNotEmpty)
                      Text(
                        dateTimeStr,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  article.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 16),
                if (article.displaySummary.isNotEmpty)
                  Text(
                    article.displaySummary,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),
                if (article.displaySummary.isEmpty)
                  Text(
                    '요약 정보가 없습니다. 원본 기사에서 확인해주세요.',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onClose();
                      onOpenUrl();
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text(
                      '원본 기사 보기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
