import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2.75 * AppDimensions.remBase, // 2.75rem
      padding: const EdgeInsets.all(AppDimensions.spacingXs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: AppColors.surfaceHighlight.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final int index = entry.key;
          final String title = entry.value;
          final bool isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.tabSelectedBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.tabSelectedBorder,
                          width: 1,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 선택된 탭에 도트 인디케이터
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppColors.tabSelectedText,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Noto Sans KR',
                        color: isSelected
                            ? AppColors.tabSelectedText
                            : AppColors.tabUnselectedText,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: AppDimensions.fontSizeMd,
                        letterSpacing: isSelected ? 0.5 : 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
