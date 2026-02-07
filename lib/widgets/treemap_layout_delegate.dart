
import 'package:flutter/material.dart';

class TreemapLayoutDelegate extends MultiChildLayoutDelegate {
  final Map<String, double> weights;

  TreemapLayoutDelegate({required this.weights});

  @override
  void performLayout(Size size) {
    if (weights.isEmpty) return;

    // Use a simple Slice-and-Dice algorithm 
    // or a recursive binary split to fill the space.
    _layoutRects(
      Offset.zero & size,
      weights.keys.toList(),
      weights.values.reduce((a, b) => a + b),
    );
  }

  void _layoutRects(Rect area, List<String> ids, double totalWeight) {
    if (ids.isEmpty) return;

    if (ids.length == 1) {
      final String id = ids.first;
      if (hasChild(id)) {
        layoutChild(id, BoxConstraints.tight(area.size));
        positionChild(id, area.topLeft);
      }
      return;
    }

    // Split the list into two groups with roughly equal weight
    double currentSum = 0;
    int splitIndex = 0;
    
    // Try to find a split point that balances the weights
    for (int i = 0; i < ids.length; i++) {
        currentSum += weights[ids[i]]!;
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

    final double weight1 = group1.fold(0.0, (sum, id) => sum + weights[id]!);
    final double weight2 = group2.fold(0.0, (sum, id) => sum + weights[id]!);
    
    // Decide split direction based on aspect ratio of the area
    // If width > height, split vertically (result is two side-by-side rects)
    // If height > width, split horizontally (result is two top-bottom rects)
    
    final bool splitVertical = area.width > area.height;

    Rect area1, area2;

    if (splitVertical) {
      final double width1 = area.width * (weight1 / (weight1 + weight2));
      area1 = Rect.fromLTWH(area.left, area.top, width1, area.height);
      area2 = Rect.fromLTWH(area.left + width1, area.top, area.width - width1, area.height);
    } else {
      final double height1 = area.height * (weight1 / (weight1 + weight2));
      area1 = Rect.fromLTWH(area.left, area.top, area.width, height1);
      area2 = Rect.fromLTWH(area.left, area.top + height1, area.width, area.height - height1);
    }

    _layoutRects(area1, group1, weight1);
    _layoutRects(area2, group2, weight2);
  }

  @override
  bool shouldRelayout(TreemapLayoutDelegate oldDelegate) {
    return oldDelegate.weights != weights;
  }
}
