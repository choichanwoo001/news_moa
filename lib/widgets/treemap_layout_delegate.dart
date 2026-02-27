import 'package:flutter/material.dart';
import 'dart:math' as math;

class TreemapLayoutDelegate extends MultiChildLayoutDelegate {
  final Map<String, double> weights;

  TreemapLayoutDelegate({required this.weights});

  /// 원본 weights를 최소 비율(minRatio)이 보장되도록 정규화.
  /// 예: 10개 섹터, minRatio = 0.04 → 아무리 작아도 전체의 4% 차지.
  Map<String, double> _normalizeWeights() {
    if (weights.isEmpty) return weights;

    final n = weights.length;
    final double minRatio = math.max(0.03, 1.0 / (n * 3)); // 최소 ~3% 보장
    final totalOriginal = weights.values.reduce((a, b) => a + b);
    if (totalOriginal <= 0) return weights;

    // 1) 원본 비율 계산
    final Map<String, double> ratios = {
      for (var e in weights.entries) e.key: e.value / totalOriginal
    };

    // 2) 최소 비율 미달 항목 끌어올리기
    final Map<String, double> adjusted = {};
    double surplus = 0;
    int boostedCount = 0;

    for (var e in ratios.entries) {
      if (e.value < minRatio) {
        adjusted[e.key] = minRatio;
        surplus += (minRatio - e.value);
        boostedCount++;
      } else {
        adjusted[e.key] = e.value;
      }
    }

    // 3) 끌어올린 만큼 나머지에서 비례 차감 (합 = 1.0 유지)
    if (surplus > 0 && boostedCount < n) {
      final nonBoostedTotal = adjusted.entries
          .where((e) => ratios[e.key]! >= minRatio)
          .fold(0.0, (sum, e) => sum + e.value);
      if (nonBoostedTotal > surplus) {
        for (var key in adjusted.keys.toList()) {
          if (ratios[key]! >= minRatio) {
            adjusted[key] = adjusted[key]! - surplus * (adjusted[key]! / nonBoostedTotal);
          }
        }
      }
    }

    // 4) 정규화된 비율 → 새 weight (100 기준)
    return {for (var e in adjusted.entries) e.key: e.value * 100};
  }

  @override
  void performLayout(Size size) {
    if (weights.isEmpty) return;

    final normalized = _normalizeWeights();

    _layoutRects(
      Offset.zero & size,
      normalized.keys.toList(),
      normalized.values.reduce((a, b) => a + b),
      normalized,
    );
  }

  void _layoutRects(Rect area, List<String> ids, double totalWeight, Map<String, double> normalizedWeights) {
    if (ids.isEmpty) return;
    
    // 영역이 너무 작으면 레이아웃 스킵
    if (area.width < 1 || area.height < 1) {
      for (final id in ids) {
        if (hasChild(id)) {
          layoutChild(id, const BoxConstraints.tightFor(width: 0, height: 0));
          positionChild(id, area.topLeft);
        }
      }
      return;
    }

    if (ids.length == 1) {
      final String id = ids.first;
      if (hasChild(id)) {
        final constrainedWidth = math.max(0.0, area.width);
        final constrainedHeight = math.max(0.0, area.height);
        layoutChild(id, BoxConstraints.tight(Size(constrainedWidth, constrainedHeight)));
        positionChild(id, area.topLeft);
      }
      return;
    }

    // Split the list into two groups with roughly equal weight
    double currentSum = 0;
    int splitIndex = 0;
    
    // Try to find a split point that balances the weights
    for (int i = 0; i < ids.length; i++) {
        currentSum += normalizedWeights[ids[i]]!;
        if (currentSum >= totalWeight / 2) {
            splitIndex = i + 1;
            break;
        }
    }
    // Ensure at least one item in each group if possible
    if (splitIndex >= ids.length) splitIndex = ids.length - 1;
    if (splitIndex < 1) splitIndex = 1;

    final group1 = ids.sublist(0, splitIndex);
    final group2 = ids.sublist(splitIndex);

    final double weight1 = group1.fold(0.0, (sum, id) => sum + normalizedWeights[id]!);
    final double weight2 = group2.fold(0.0, (sum, id) => sum + normalizedWeights[id]!);
    
    // weight 합이 0이면 균등 분배
    final double totalWeightSum = weight1 + weight2;
    if (totalWeightSum <= 0) {
      for (final id in ids) {
        if (hasChild(id)) {
          layoutChild(id, const BoxConstraints.tightFor(width: 0, height: 0));
          positionChild(id, area.topLeft);
        }
      }
      return;
    }
    
    // Decide split direction based on aspect ratio of the area
    final bool splitVertical = area.width > area.height;

    Rect area1, area2;

    if (splitVertical) {
      final double ratio = weight1 / totalWeightSum;
      final double width1 = math.max(0.0, area.width * ratio);
      final double width2 = math.max(0.0, area.width - width1);
      area1 = Rect.fromLTWH(area.left, area.top, width1, area.height);
      area2 = Rect.fromLTWH(area.left + width1, area.top, width2, area.height);
    } else {
      final double ratio = weight1 / totalWeightSum;
      final double height1 = math.max(0.0, area.height * ratio);
      final double height2 = math.max(0.0, area.height - height1);
      area1 = Rect.fromLTWH(area.left, area.top, area.width, height1);
      area2 = Rect.fromLTWH(area.left, area.top + height1, area.width, height2);
    }

    _layoutRects(area1, group1, weight1, normalizedWeights);
    _layoutRects(area2, group2, weight2, normalizedWeights);
  }

  @override
  bool shouldRelayout(TreemapLayoutDelegate oldDelegate) {
    return oldDelegate.weights != weights;
  }
}
