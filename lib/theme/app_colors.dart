import 'package:flutter/material.dart';

class AppColors {
  // Background & Surface (Deep Dark Theme)
  static const Color background = Color(0xFF0F172A); // Slate 900 - Deep focused dark
  static const Color surface = Color(0xFF1E293B); // Slate 800 - Lighter relative to bg
  static const Color surfaceHighlight = Color(0xFF334155); // Slate 700 - For interactions
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF9FAFB); // Gray 50 - Almost white
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400 - Muted
  static const Color divider = Color(0xFF334155); // Slate 700

  // Accent & Brand (Neon Vibes)
  static const Color primary = Color(0xFF3B82F6); // Blue 500 - Vivid Blue
  static const Color accent = Color(0xFF8B5CF6); // Violet 500 - Electric Purple
  static const Color neonGlow = Color(0xFF60A5FA); // Blue 400 - For glow effects

  // Heatmap Colors (Neon/Vibrant Gradient Scale)
  // High Volume: Hot/Bright -> Low Volume: Cool/Darker
  static const Color heatHigh = Color(0xFFFF453A); // Neon Red/Orange
  static const Color heatMediumHigh = Color(0xFFFF9F0A); // Neon Orange
  static const Color heatMediumLow = Color(0xFF30D158); // Neon Green
  static const Color heatLow = Color(0xFF0A84FF); // Neon Blue
  static const Color heatLowest = Color(0xFF5E5CE6); // Neon Purple/Indigo

  // Returns color based on volume 
  static Color getColorForVolume(double volume) {
    if (volume >= 90) return heatHigh;
    if (volume >= 70) return heatMediumHigh;
    if (volume >= 30) return heatLow;
    return heatLowest;
  }

  static Color getSectorColor(String sectorName) {
    if (sectorName.contains("반도체")) return heatHigh;
    if (sectorName.contains("2차전지")) return heatMediumHigh;
    if (sectorName.contains("바이오") || sectorName.contains("자동차")) return heatMediumLow;
    if (sectorName.contains("IT") || sectorName.contains("SW")) return heatLow;
    if (sectorName.contains("금융") || sectorName.contains("건설") || sectorName.contains("유통")) return heatLowest;
    return textSecondary;
  }
}
