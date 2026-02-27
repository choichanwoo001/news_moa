import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// 홈 화면 상단 헤더 (제목, 뒤로가기, 새로고침)
class HomeHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool isLoading;
  final VoidCallback onRefresh;

  const HomeHeader({
    super.key,
    required this.title,
    required this.showBackButton,
    this.onBack,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
        AppDimensions.spacingMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showBackButton)
            Positioned(
              left: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: onBack,
              ),
            ),
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Noto Sans KR',
                fontSize: AppDimensions.fontSizeTitle,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.surfaceHighlight),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: isLoading ? null : onRefresh,
                tooltip: '데이터 새로고침',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
