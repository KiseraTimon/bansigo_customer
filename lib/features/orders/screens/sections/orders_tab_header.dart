// lib/features/orders/screens/sections/orders_tab_header.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/order_model.dart';

class OrdersTabHeader extends StatelessWidget {
  final OrderTabType activeTab;
  final ValueChanged<OrderTabType> onTabSelected;

  const OrdersTabHeader({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            'Orders',
            style: AppTextStyles.h2.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.slateDark,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildTabItem(
                title: 'Ongoing',
                isSelected: activeTab == OrderTabType.ongoing,
                onTap: () => onTabSelected(OrderTabType.ongoing),
              ),
            ),
            Expanded(
              child: _buildTabItem(
                title: 'History',
                isSelected: activeTab == OrderTabType.history,
                onTap: () => onTabSelected(OrderTabType.history),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xFFF1F5F9),
        ),
      ],
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
              ),
            ),
          ),
          Container(
            height: 3,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
