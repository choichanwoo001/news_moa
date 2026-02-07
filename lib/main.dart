import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const NewsMoaApp());
}

class NewsMoaApp extends StatelessWidget {
  const NewsMoaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Moa',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.light();
    
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.notoSansKrTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      useMaterial3: true,
    );
  }
}
