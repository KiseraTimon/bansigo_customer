// lib/features/home/widgets/custom_bottom_nav.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_rounded,
            isActive: currentIndex == 0,
            useCircleBackground: true,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.grid_view_rounded,
            isActive: currentIndex == 1,
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.shopping_bag_outlined,
            isActive: currentIndex == 2,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.menu_rounded,
            isActive: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required bool isActive,
    bool useCircleBackground = false,
  }) {
    if (useCircleBackground && isActive) {
      return GestureDetector(
        onTap: () => onIndexChanged(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 26,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onIndexChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.slateDark,
          size: 26,
        ),
      ),
    );
  }
}
