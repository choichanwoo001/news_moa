
import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Colors.white;
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;

  // Heatmap Colors (Hot Red -> Cool Blue)
  static const Color heatHigh = Color(0xFFFF5252); // Bright Red
  static const Color heatMediumHigh = Color(0xFFFFAB40); // Orange
  static const Color heatMediumLow = Color(0xFFCDDC39); // Lime Green
  static const Color heatLow = Color(0xFF90CAF9); // Light Blue
  static const Color heatLowest = Color(0xFFB0BEC5); // Greyish Blue

  // Returns color based on change rate (for heatmap effect)
  // Logic: High positive change -> Red, Low/Negative -> Blue/Grey
  // Wait, user requirement: "Bright, hot reds and oranges... representing high news volume sectors".
  // Actually, usually heatmap color represents change (up/down), and size represents volume.
  // User request: "Largest blocks are colored in bright, hot reds... representing high news volume sectors".
  // User mapping: Size = Volume. Color = Volume too?
  // "The largest blocks are colored in bright, hot reds... The smallest blocks are muted blues and grays"
  // So Color is also mapped to News Volume in the user's description.
  
  static Color getColorForVolume(double volume) {
    if (volume >= 90) return heatHigh;
    if (volume >= 70) return heatMediumHigh;
    if (volume >= 50) return heatMediumLow;
    if (volume >= 30) return heatLow;
    return heatLowest;
  }
}
