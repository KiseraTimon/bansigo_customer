// lib/features/home/widgets/category_slider.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CategoryFilterItem {
  final String id;
  final String label;
  final IconData icon;

  const CategoryFilterItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class CategorySlider extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  static const List<CategoryFilterItem> categories = [
    CategoryFilterItem(
      id: 'all',
      label: 'All',
      icon: Icons.apps_rounded,
    ),
    CategoryFilterItem(
      id: 'pharmacy',
      label: 'Pharmacy',
      icon: Icons.local_pharmacy_outlined,
    ),
    CategoryFilterItem(
      id: 'bakery',
      label: 'Bakery',
      icon: Icons.bakery_dining_outlined,
    ),
    CategoryFilterItem(
      id: 'deli',
      label: 'Deli',
      icon: Icons.restaurant_outlined,
    ),
    CategoryFilterItem(
      id: 'drinks',
      label: 'Drinks',
      icon: Icons.local_bar_outlined,
    ),
    CategoryFilterItem(
      id: 'electronics',
      label: 'Electronics',
      icon: Icons.devices_other_outlined,
    ),
    CategoryFilterItem(
      id: 'furniture',
      label: 'Furniture',
      icon: Icons.chair_outlined,
    ),
  ];

  const CategorySlider({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Transparent background syncing with UI perfectly
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = categories[index];
          final isSelected = item.id.toLowerCase() == selectedCategory.toLowerCase();

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onCategorySelected(item.id),
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 16.5,
                      color: isSelected ? Colors.white : AppColors.slateDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: AppTextStyles.bodySemiBold.copyWith(
                        fontSize: 12.5,
                        color: isSelected ? Colors.white : AppColors.slateDark,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
