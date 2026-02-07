
import 'package:flutter/material.dart';
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
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          background: AppColors.background,
        ),
        fontFamily: 'Roboto', // Default fallback, expecting Google Fonts in real usage if configured
      ),
      home: const HomeScreen(),
    );
  }
}
