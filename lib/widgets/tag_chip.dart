import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';

/// 재사용 가능한 태그/칩 위젯 (섹터명, 키워드, 기업명 등)
class TagChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final bool bold;
  final double fontSize;

  const TagChip({
    super.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    this.bold = false,
    this.fontSize = AppDimensions.fontSizeSm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    );
  }
}
