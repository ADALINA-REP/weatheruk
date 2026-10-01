import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UhdBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const UhdBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: 12 + bottomPadding, left: 24, right: 24, top: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF151F38).withValues(alpha: 0.85),
                  const Color(0xFF0A0F1D).withValues(alpha: 0.75),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  isSelected: currentIndex == 0,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.favorite_rounded,
                  isSelected: currentIndex == 1,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.radar_rounded,
                  isSelected: currentIndex == 2,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.analytics_rounded,
                  isSelected: currentIndex == 3,
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.settings_rounded,
                  isSelected: currentIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isSelected
                ? [const Color(0xFF0170E3), const Color(0xFF06B6D4)]
                : [Colors.white.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.6)],
          ).createShader(bounds),
          child: Icon(
            icon,
            size: isSelected ? 26 : 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
