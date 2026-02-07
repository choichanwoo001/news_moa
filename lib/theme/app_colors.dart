import 'package:flutter/material.dart';

class AppColors {
  // Background & Surface
  static const Color background = Color(0xFFF9FAFB); // Very light grey/off-white
  static const Color surface = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Deep dark grey, almost black
  static const Color textSecondary = Color(0xFF6B7280); // Medium grey
  static const Color divider = Color(0xFFE5E7EB); // Light grey for dividers

  // Accent & Brand
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color accent = Color(0xFF3B82F6); // Lighter Blue

  // Heatmap Colors (Sophisticated Palette)
  // Radiant Red -> Muted Cool Blue/Grey
  static const Color heatHigh = Color(0xFFEF4444); // Vivid Red
  static const Color heatMediumHigh = Color(0xFFF97316); // Bright Orange
  static const Color heatMediumLow = Color(0xFF84CC16); // Lime/Green
  static const Color heatLow = Color(0xFF60A5FA); // Soft Blue
  static const Color heatLowest = Color(0xFF94A3B8); // Cool Grey

  // Returns color based on volume (Design Requirement: High Volume = Hot/Red)
  static Color getColorForVolume(double volume) {
    if (volume >= 90) return heatHigh;
    if (volume >= 70) return heatMediumHigh;
    if (volume >= 50) return heatMediumLow;
    if (volume >= 30) return heatLow;
    return heatLowest;
  }
}
