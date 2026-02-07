import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Light grey background
        borderRadius: BorderRadius.circular(12), // Slightly more squared
        border: Border.all(color: const Color(0xFFE5E7EB)), // Subtle border
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double tabWidth = constraints.maxWidth / widget.tabs.length;
          
          return Stack(
            children: [
              // Animated Indicator
              AnimatedAlign(
                alignment: Alignment(
                  (widget.selectedIndex / (widget.tabs.length - 1)) * 2 - 1,
                  0,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: tabWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab Labels
              Row(
                children: widget.tabs.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final String title = entry.value;
                  final bool isSelected = index == widget.selectedIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onTabSelected(index),
                      child: Container(
                        // Transparent container to capture taps
                        color: Colors.transparent, 
                        alignment: Alignment.center,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontFamily: 'Noto Sans KR', // Explicitly use if available via main.dart theme
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                          child: Text(title),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
