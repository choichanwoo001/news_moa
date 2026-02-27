import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// 전체 화면 로딩 인디케이터
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: AppDimensions.rem(2.5),
              height: AppDimensions.rem(2.5),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
                strokeCap: StrokeCap.round,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              '뉴스 데이터를 불러오는 중...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppDimensions.fontSizeMd,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
