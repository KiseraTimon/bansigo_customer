// lib/features/home/widgets/grocery_grid_section.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/illustrations/vector_illustrations.dart';

class GroceryItemData {
  final String id;
  final String title;
  final Widget illustration;
  final Color bgColor;
  final Color borderColor;

  const GroceryItemData({
    required this.id,
    required this.title,
    required this.illustration,
    required this.bgColor,
    required this.borderColor,
  });
}

class GroceryGridSection extends StatelessWidget {
  final ValueChanged<GroceryItemData>? onItemTap;

  const GroceryGridSection({
    super.key,
    this.onItemTap,
  });

  static const List<GroceryItemData> groceryItems = [
    GroceryItemData(
      id: 'fresh_produce',
      title: 'Fresh Produce',
      illustration: FreshProduceIllustration(size: 46),
      bgColor: Color(0xFFF0FDF4),
      borderColor: Color(0xFFDCFCE7),
    ),
    GroceryItemData(
      id: 'dairy_bread',
      title: 'Dairy & Bread',
      illustration: DairyIllustration(size: 46),
      bgColor: Color(0xFFFFFBEB),
      borderColor: Color(0xFFFEF3C7),
    ),
    GroceryItemData(
      id: 'oils_spices_condiments',
      title: 'Spices',
      illustration: SpicesIllustration(size: 46),
      bgColor: Color(0xFFFFF7ED),
      borderColor: Color(0xFFFFEDD5),
    ),
    GroceryItemData(
      id: 'drinks_juices',
      title: 'Drinks & Juices',
      illustration: BeveragesIllustration(size: 46),
      bgColor: Color(0xFFEFF6FF),
      borderColor: Color(0xFFDBEAFE),
    ),
    GroceryItemData(
      id: 'snacks',
      title: 'Snacks',
      illustration: SnacksIllustration(size: 46),
      bgColor: Color(0xFFFEF2F2),
      borderColor: Color(0xFFFEE2E2),
    ),
    GroceryItemData(
      id: 'ice_creams_more',
      title: 'Ice Creams & More',
      illustration: IceCreamIllustration(size: 46),
      bgColor: Color(0xFFFDF2F8),
      borderColor: Color(0xFFFCE7F3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Grocery',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slateDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'DAILY ESSENTIALS',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 6-item Grid (3 columns, 2 rows)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: groceryItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              final item = groceryItems[index];
              return InkWell(
                onTap: () => onItemTap?.call(item),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: item.bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: item.borderColor,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: item.illustration,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySemiBold.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slateDark,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
