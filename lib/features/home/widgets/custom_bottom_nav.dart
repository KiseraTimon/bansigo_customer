// lib/features/home/widgets/custom_bottom_nav.dart

import 'package:flutter/material.dart';

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
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom + 2
            : 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 0: Home
          _buildStandardNavItem(
            index: 0,
            icon: currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
            isActive: currentIndex == 0,
          ),
          // 1: Explore / Departments
          _buildStandardNavItem(
            index: 1,
            icon: currentIndex == 1 ? Icons.grid_view_rounded : Icons.grid_view_outlined,
            isActive: currentIndex == 1,
          ),
          // 2: Orders / Shopping Bag
          _buildStandardNavItem(
            index: 2,
            icon: currentIndex == 2 ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
            isActive: currentIndex == 2,
          ),
          // 3: More / Menu Button (Green Circle with white hamburger icon matching inspo)
          _buildMoreCircularButton(
            isActive: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStandardNavItem({
    required int index,
    required IconData icon,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => onIndexChanged(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF1E293B) : const Color(0xFF64748B),
          size: 26,
        ),
      ),
    );
  }

  Widget _buildMoreCircularButton({
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => onIndexChanged(3),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF65B307) : const Color(0xFF70C007),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF65B307).withValues(alpha: isActive ? 0.45 : 0.25),
              blurRadius: isActive ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.menu_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
