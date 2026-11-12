// lib/features/home/widgets/shop_aisles_section.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AisleData {
  final String id;
  final String title;
  final String subtitle;
  final String itemCount;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const AisleData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.itemCount,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class ShopAislesSection extends StatelessWidget {
  final ValueChanged<AisleData>? onAisleTap;

  const ShopAislesSection({
    super.key,
    this.onAisleTap,
  });

  static const List<AisleData> aisles = [
    AisleData(
      id: 'local_farm',
      title: 'Migori Farm Hub',
      subtitle: 'Greens & fruits straight from farms',
      itemCount: '120+ items',
      icon: Icons.eco_rounded,
      iconBgColor: Color(0xFFDCFCE7),
      iconColor: Color(0xFF16A34A),
    ),
    AisleData(
      id: 'bakery_oven',
      title: 'Warm Oven Bakery',
      subtitle: 'Artisan loaves, baguettes & pastries',
      itemCount: '45+ items',
      icon: Icons.bakery_dining_rounded,
      iconBgColor: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
    ),
    AisleData(
      id: 'express_butchery',
      title: 'Prime Butchery',
      subtitle: 'Premium beef, poultry & fresh fish',
      itemCount: '35+ cuts',
      icon: Icons.restaurant_rounded,
      iconBgColor: Color(0xFFFEE2E2),
      iconColor: Color(0xFFDC2626),
    ),
    AisleData(
      id: 'wholesale_pantry',
      title: 'Wholesale Pantry',
      subtitle: 'Flours, rice, oils & staples in bulk',
      itemCount: '200+ items',
      icon: Icons.inventory_2_rounded,
      iconBgColor: Color(0xFFE0E7FF),
      iconColor: Color(0xFF4F46E5),
    ),
    AisleData(
      id: 'wellness_care',
      title: 'Wellness & Care',
      subtitle: 'Baby care, personal hygiene & toiletries',
      itemCount: '80+ items',
      icon: Icons.favorite_rounded,
      iconBgColor: Color(0xFFFCE7F3),
      iconColor: Color(0xFFDB2777),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Aisle & Store',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: aisles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final aisle = aisles[index];
              return InkWell(
                onTap: () => onAisleTap?.call(aisle),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: aisle.iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              aisle.icon,
                              size: 18,
                              color: aisle.iconColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              aisle.itemCount,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.slateDark,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            aisle.title,
                            style: AppTextStyles.bodySemiBold.copyWith(
                              fontSize: 13,
                              color: AppColors.slateDark,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            aisle.subtitle,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
